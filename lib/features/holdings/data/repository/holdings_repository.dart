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
  }) : _searchService = searchService,
       _borderNavigatorService = borderNavigatorService;

  static const String _activeFilePathKey = 'holdings_active_file_path';
  static const String _historyKey = 'holdings_file_history';
  static const String _cacheDirName = 'holdings_cache';
  static const int _maxHistoryEntries = 15;

  final HoldingSearchService _searchService;
  final BorderNavigatorService _borderNavigatorService;

  List<Parcel> _parcels = <Parcel>[];

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

    _parcels = parsed;
    return parsed;
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
    _parcels = parsed;
    return parsed;
  }

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
  /// `null` if no confident match exists.
  String? resolveBorder(final String borderText) =>
      _borderNavigatorService.resolve(borderText, _parcels);
}

class HoldingsFilePickCancelled implements Exception {
  const HoldingsFilePickCancelled();
}
