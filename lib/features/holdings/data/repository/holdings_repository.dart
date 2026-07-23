import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/services/border_navigator_service.dart';
import '../../logic/services/holding_search_service.dart';
import '../excel/holdings_excel_parser.dart';
import '../models/cached_file_entry.dart';
import '../models/parcel.dart';
import 'parcel_edits_store.dart';

/// Runs the (potentially heavy) Excel parse in a background isolate via
/// [compute] so the UI thread never freezes while reading a large workbook.
/// Must be a top-level function — [compute] cannot capture closures.
List<Parcel> _parseHoldingsBytes(final Uint8List bytes) =>
    const HoldingsExcelParser().parse(bytes);

/// Owns the in-memory dataset and the on-device cache of picked workbooks,
/// so the app can reload any of them offline without re-prompting the file
/// picker (SAF/URI permissions on the original pick can expire, so each
/// file is copied into app storage instead of just remembering its path).
///
/// Keeps a small history of every distinct file that has been loaded, so
/// the user can switch back to a previous one from the History screen.
class HoldingsRepository {
  HoldingsRepository({
    final HoldingSearchService searchService = const HoldingSearchService(),
    final BorderNavigatorService borderNavigatorService =
        const BorderNavigatorService(),
    final ParcelEditsStore editsStore = const ParcelEditsStore(),
  }) : _searchService = searchService,
       _borderNavigatorService = borderNavigatorService,
       _editsStore = editsStore;

  static const String _activeFilePathKey = 'holdings_active_file_path';
  static const String _historyKey = 'holdings_file_history';
  static const String _cacheDirName = 'holdings_cache';
  static const int _maxHistoryEntries = 15;

  final HoldingSearchService _searchService;
  final BorderNavigatorService _borderNavigatorService;
  final ParcelEditsStore _editsStore;

  List<Parcel> _parcels = <Parcel>[];

  /// Path of the file whose edits are currently loaded — the key under
  /// which corrections are persisted.
  String? _activeFilePath;

  /// Original (unedited) parcels by id, so edits can be reset.
  Map<String, Parcel> _originalById = <String, Parcel>{};

  /// Per-parcel edit snapshots for the active file.
  Map<String, Map<String, dynamic>> _edits = <String, Map<String, dynamic>>{};

  List<Parcel> get parcels => _parcels;

  /// Picks a `.xlsx` file, copies it into app storage under a unique name,
  /// records it in the file history, parses it (off the UI thread), and
  /// makes it the active dataset.
  Future<List<Parcel>> loadFromPickedFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['xlsx'],
      withData: true,
    );
    final PlatformFile? picked = result?.files.single;
    if (picked == null) {
      throw const HoldingsFilePickCancelled();
    }

    final Uint8List bytes =
        picked.bytes ?? await File(picked.path!).readAsBytes();
    final List<Parcel> parsed = await compute(_parseHoldingsBytes, bytes);

    final String fileName = picked.name;
    final String cachedPath = await _cacheBytes(bytes, fileName);
    await _rememberInHistory(
      CachedFileEntry(
        fileName: fileName,
        filePath: cachedPath,
        cachedAt: DateTime.now(),
        holdingCount: parsed.map((final Parcel p) => p.holdingId).toSet().length,
      ),
    );
    await _setActivePath(cachedPath);

    return _finalizeLoad(parsed, cachedPath);
  }

  /// Loads the previously active file, if any. Returns `null` when nothing
  /// has been cached yet (caller should show the Empty state).
  Future<List<Parcel>?> loadCachedFileIfAny() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString(_activeFilePathKey);
    if (path == null) return null;
    return _loadFromPath(path);
  }

  /// Switches the active dataset to a previously-loaded file from history.
  Future<List<Parcel>> loadFromHistoryEntry(
    final CachedFileEntry entry,
  ) async {
    final List<Parcel>? parsed = await _loadFromPath(entry.filePath);
    if (parsed == null) {
      throw const HoldingsFilePickCancelled();
    }
    await _setActivePath(entry.filePath);
    return parsed;
  }

  Future<List<Parcel>?> _loadFromPath(final String path) async {
    final File file = File(path);
    if (!file.existsSync()) return null;

    final Uint8List bytes = await file.readAsBytes();
    final List<Parcel> parsed = await compute(_parseHoldingsBytes, bytes);
    return _finalizeLoad(parsed, path);
  }

  /// Assigns stable ids, remembers the originals, and overlays any saved
  /// edits for [filePath] before exposing the dataset.
  Future<List<Parcel>> _finalizeLoad(
    final List<Parcel> parsed,
    final String filePath,
  ) async {
    _activeFilePath = filePath;
    final List<Parcel> withIds = <Parcel>[
      for (var i = 0; i < parsed.length; i++)
        parsed[i].copyWith(id: i.toString()),
    ];
    _originalById = <String, Parcel>{
      for (final Parcel p in withIds) p.id: p,
    };
    _edits = await _editsStore.load(filePath);
    _parcels = withIds.map(_applyEdit).toList();
    return _parcels;
  }

  Parcel _applyEdit(final Parcel p) {
    final Map<String, dynamic>? e = _edits[p.id];
    if (e == null) return p;
    double? d(final String key) => (e[key] as num?)?.toDouble();
    return Parcel(
      id: p.id,
      holdingId: p.holdingId,
      pageNumber: p.pageNumber,
      borderEast: p.borderEast,
      borderSouth: p.borderSouth,
      borderWest: p.borderWest,
      borderNorth: p.borderNorth,
      directorate: e['directorate'] as String?,
      administration: e['administration'] as String?,
      basinName: e['basinName'] as String?,
      basinCode: e['basinCode'] as String?,
      holderName: e['holderName'] as String?,
      nationalId: e['nationalId'] as String?,
      landNumber: e['landNumber'] as String?,
      feddan: d('feddan'),
      qirat: d('qirat'),
      sahm: d('sahm'),
      totalSqm: d('totalSqm'),
    );
  }

  Map<String, dynamic> _snapshot(final Parcel p) => <String, dynamic>{
    'directorate': p.directorate,
    'administration': p.administration,
    'basinName': p.basinName,
    'basinCode': p.basinCode,
    'holderName': p.holderName,
    'nationalId': p.nationalId,
    'landNumber': p.landNumber,
    'feddan': p.feddan,
    'qirat': p.qirat,
    'sahm': p.sahm,
    'totalSqm': p.totalSqm,
  };

  /// Persists an edited parcel and reflects it in the in-memory dataset so
  /// search, detail, and border navigation immediately use the new values.
  Future<void> updateParcel(final Parcel edited) async {
    final int idx = _parcels.indexWhere((final Parcel p) => p.id == edited.id);
    if (idx < 0) return;
    _parcels[idx] = edited;
    _edits[edited.id] = _snapshot(edited);
    if (_activeFilePath != null) {
      await _editsStore.save(_activeFilePath!, _edits);
    }
  }

  /// Reverts a parcel to its original parsed values.
  Future<void> resetParcel(final String id) async {
    final Parcel? original = _originalById[id];
    if (original == null) return;
    final int idx = _parcels.indexWhere((final Parcel p) => p.id == id);
    if (idx >= 0) _parcels[idx] = original;
    _edits.remove(id);
    if (_activeFilePath != null) {
      await _editsStore.save(_activeFilePath!, _edits);
    }
  }

  bool isParcelEdited(final String id) => _edits.containsKey(id);

  Future<String> _cacheBytes(
    final Uint8List bytes,
    final String originalFileName,
  ) async {
    final Directory docsDir = await getApplicationDocumentsDirectory();
    final Directory cacheDir = Directory(
      '${docsDir.path}/$_cacheDirName',
    );
    if (!cacheDir.existsSync()) {
      cacheDir.createSync(recursive: true);
    }

    final String safeName = originalFileName.replaceAll(
      RegExp(r'[^\w.\-؀-ۿ]'),
      '_',
    );
    final String uniqueName =
        '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final File cached = File('${cacheDir.path}/$uniqueName');
    await cached.writeAsBytes(bytes, flush: true);
    return cached.path;
  }

  Future<void> _setActivePath(final String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeFilePathKey, path);
  }

  Future<void> _rememberInHistory(final CachedFileEntry entry) async {
    final List<CachedFileEntry> history = await getHistory();

    // Replace any earlier entry for the same file name so re-picking the
    // same workbook doesn't accumulate duplicate cached copies.
    CachedFileEntry? previous;
    for (final CachedFileEntry e in history) {
      if (e.fileName == entry.fileName) {
        previous = e;
        break;
      }
    }
    if (previous != null) {
      history.remove(previous);
      final File oldFile = File(previous.filePath);
      if (oldFile.existsSync() && previous.filePath != entry.filePath) {
        await oldFile.delete();
      }
    }

    history.insert(0, entry);
    while (history.length > _maxHistoryEntries) {
      final CachedFileEntry removed = history.removeLast();
      final File removedFile = File(removed.filePath);
      if (removedFile.existsSync()) {
        await removedFile.delete();
      }
    }

    await _saveHistory(history);
  }

  /// All previously loaded files, most recently added first.
  Future<List<CachedFileEntry>> getHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return <CachedFileEntry>[];

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (final dynamic e) =>
              CachedFileEntry.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  /// Removes a stale history entry (e.g. its cached file was deleted
  /// outside the app) without touching the currently active dataset.
  Future<void> removeHistoryEntry(final CachedFileEntry entry) async {
    final List<CachedFileEntry> history = await getHistory();
    history.removeWhere(
      (final CachedFileEntry e) => e.filePath == entry.filePath,
    );
    await _saveHistory(history);
  }

  Future<void> _saveHistory(final List<CachedFileEntry> history) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      history.map((final CachedFileEntry e) => e.toJson()).toList(),
    );
    await prefs.setString(_historyKey, encoded);
  }

  /// Searches within [basin] (اسم الحوض) if given, otherwise the whole
  /// dataset — narrowing the scope keeps fuzzy matching fast on large files.
  List<SearchResult> search(final String query, {final String? basin}) {
    final List<Parcel> scope = basin == null
        ? _parcels
        : _parcels.where((final Parcel p) => p.basinName == basin).toList();
    return _searchService.search(scope, query);
  }

  /// Distinct اسم الحوض values in the active dataset, sorted.
  List<String> get availableBasins {
    final Set<String> basins = <String>{};
    for (final Parcel p in _parcels) {
      final String? name = p.basinName?.trim();
      if (name != null && name.isNotEmpty) basins.add(name);
    }
    final List<String> sorted = basins.toList()..sort();
    return sorted;
  }

  List<Parcel> parcelsForHolding(final String holdingId) =>
      _parcels.where((final Parcel p) => p.holdingId == holdingId).toList();

  /// Resolves a border's free-text name to a navigable holding ID, or
  /// `null` if no confident match exists. [basinName] scopes the match to
  /// parcels in the same basin as the parcel whose border is being resolved.
  String? resolveBorder(final String borderText, {final String? basinName}) =>
      _borderNavigatorService.resolve(
        borderText,
        _parcels,
        basinName: basinName,
      );
}

class HoldingsFilePickCancelled implements Exception {
  const HoldingsFilePickCancelled();
}
