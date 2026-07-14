import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/services/border_navigator_service.dart';
import '../../logic/services/holding_search_service.dart';
import '../excel/holdings_excel_parser.dart';
import '../models/parcel.dart';

/// Owns the in-memory dataset and the on-device cache of the last picked
/// workbook, so the app can reload it offline on the next launch without
/// re-prompting the file picker (SAF/URI permissions on the original pick
/// can expire, so the file is copied into app storage instead of just
/// remembering its original path).
class HoldingsRepository {
  HoldingsRepository({
    final HoldingsExcelParser parser = const HoldingsExcelParser(),
    final HoldingSearchService searchService = const HoldingSearchService(),
    final BorderNavigatorService borderNavigatorService =
        const BorderNavigatorService(),
  }) : _parser = parser,
       _searchService = searchService,
       _borderNavigatorService = borderNavigatorService;

  static const String _cachedFilePathKey = 'holdings_cached_file_path';
  static const String _cachedFileName = 'holdings_cache.xlsx';

  final HoldingsExcelParser _parser;
  final HoldingSearchService _searchService;
  final BorderNavigatorService _borderNavigatorService;

  List<Parcel> _parcels = <Parcel>[];

  List<Parcel> get parcels => _parcels;

  /// Picks a `.xlsx` file, copies it into app storage, remembers its path,
  /// parses it, and returns the resulting dataset.
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
    final List<Parcel> parsed = _parser.parse(bytes);

    await _cacheBytes(bytes);
    _parcels = parsed;
    return parsed;
  }

  /// Loads the previously cached file, if any. Returns `null` when nothing
  /// has been cached yet (caller should show the Empty state).
  Future<List<Parcel>?> loadCachedFileIfAny() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? path = prefs.getString(_cachedFilePathKey);
    if (path == null) return null;

    final File file = File(path);
    if (!file.existsSync()) return null;

    final Uint8List bytes = await file.readAsBytes();
    final List<Parcel> parsed = _parser.parse(bytes);
    _parcels = parsed;
    return parsed;
  }

  Future<void> _cacheBytes(final Uint8List bytes) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File cached = File('${dir.path}/$_cachedFileName');
    await cached.writeAsBytes(bytes, flush: true);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedFilePathKey, cached.path);
  }

  List<SearchResult> search(final String query) =>
      _searchService.search(_parcels, query);

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
