import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../models/parcel.dart';

/// Thrown when the workbook is missing one or more required columns.
class HoldingsParseException implements Exception {
  HoldingsParseException(this.missingColumns);

  final List<String> missingColumns;

  @override
  String toString() =>
      'HoldingsParseException(missingColumns: $missingColumns)';
}

/// Parses the `.xlsx` produced by the desktop tool into a flat [Parcel] list.
///
/// Mirrors `output_file_reader.py`: columns are located by header text (not
/// fixed index), data starts on row 2, blank/totals rows are skipped, and
/// holding/national IDs are read as text to preserve leading zeros.
class HoldingsExcelParser {
  const HoldingsExcelParser();

  static const String sheetName = 'البيانات المجمعة';
  static const String _totalsMarker = 'الإجمالي';

  static const _headers = <String>[
    'رقم الحيازة',
    'رقم الصفحة بالسجل',
    'المديريه',
    'الأداره',
    'اسم الحوض',
    'كود الحوض',
    'اسم الحائز',
    'الرقم القومي',
    'الحد الشرقى',
    'الحد القبلى',
    'الحد الغربى',
    'الحد البحرى',
    'رقم الأرض',
    'فدان',
    'قيراط',
    'سهم',
    'إجمالي المساحة (م²)',
  ];

  List<Parcel> parse(final Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final table = excel.tables[sheetName];
    if (table == null) {
      throw HoldingsParseException([sheetName]);
    }

    final rows = table.rows;
    if (rows.isEmpty) {
      throw HoldingsParseException(_headers);
    }

    final headerRow = rows.first;
    final columnIndex = <String, int>{};
    for (var i = 0; i < headerRow.length; i++) {
      final text = _cellText(headerRow[i])?.trim();
      if (text != null && text.isNotEmpty) {
        columnIndex[text] = i;
      }
    }

    final missing =
        _headers.where((final h) => !columnIndex.containsKey(h)).toList();
    if (missing.isNotEmpty) {
      throw HoldingsParseException(missing);
    }

    String? textAt(final List<Data?> row, final String header) {
      final idx = columnIndex[header]!;
      if (idx >= row.length) return null;
      return _cellText(row[idx]);
    }

    double? numAt(final List<Data?> row, final String header) {
      final idx = columnIndex[header]!;
      if (idx >= row.length) return null;
      return _cellNumber(row[idx]);
    }

    final parcels = <Parcel>[];
    for (var r = 1; r < rows.length; r++) {
      final row = rows[r];
      if (_isBlankRow(row)) continue;

      final holdingId = textAt(row, 'رقم الحيازة')?.trim();
      if (holdingId == null || holdingId.isEmpty) continue;
      if (holdingId == _totalsMarker) continue;

      parcels.add(
        Parcel(
          holdingId: holdingId,
          pageNumber: textAt(row, 'رقم الصفحة بالسجل'),
          directorate: textAt(row, 'المديريه'),
          administration: textAt(row, 'الأداره'),
          basinName: textAt(row, 'اسم الحوض'),
          basinCode: textAt(row, 'كود الحوض'),
          holderName: textAt(row, 'اسم الحائز'),
          nationalId: textAt(row, 'الرقم القومي'),
          borderEast: textAt(row, 'الحد الشرقى'),
          borderSouth: textAt(row, 'الحد القبلى'),
          borderWest: textAt(row, 'الحد الغربى'),
          borderNorth: textAt(row, 'الحد البحرى'),
          landNumber: textAt(row, 'رقم الأرض'),
          feddan: numAt(row, 'فدان'),
          qirat: numAt(row, 'قيراط'),
          sahm: numAt(row, 'سهم'),
          totalSqm: numAt(row, 'إجمالي المساحة (م²)'),
        ),
      );
    }

    return parcels;
  }

  bool _isBlankRow(final List<Data?> row) {
    return row.every((final cell) {
      final text = _cellText(cell);
      return text == null || text.trim().isEmpty;
    });
  }

  String? _cellText(final Data? cell) {
    final value = cell?.value;
    if (value == null) return null;
    return switch (value) {
      final TextCellValue v => v.value.toString(),
      final IntCellValue v => v.value.toString(),
      final DoubleCellValue v => v.value.toString(),
      final BoolCellValue v => v.value.toString(),
      _ => value.toString(),
    };
  }

  double? _cellNumber(final Data? cell) {
    final value = cell?.value;
    if (value == null) return null;
    return switch (value) {
      final IntCellValue v => v.value.toDouble(),
      final DoubleCellValue v => v.value,
      final TextCellValue v => double.tryParse(v.value.toString().trim()),
      _ => null,
    };
  }
}
