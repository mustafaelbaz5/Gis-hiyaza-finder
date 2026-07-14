// test/core/utils/extensions/num_ext_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_structure/core/utils/extensions/num_ext.dart';

void main() {
  group('NumExt', () {
    // ─── toCurrency ──────────────────────────────────────────
    group('toCurrency', () {
      test('formats with default dollar symbol', () {
        expect(10.toCurrency(), equals('\$10.00'));
      });

      test('formats with custom symbol', () {
        expect(10.toCurrency(symbol: '€'), equals('€10.00'));
      });

      test('formats zero correctly', () {
        expect(0.toCurrency(), equals('\$0.00'));
      });

      test('formats negative value correctly', () {
        expect((-5.5).toCurrency(), equals('\$-5.50'));
      });

      test('formats decimal value correctly', () {
        expect(9.99.toCurrency(), equals('\$9.99'));
      });
    });

    // ─── toFileSize ──────────────────────────────────────────
    group('toFileSize', () {
      test('returns bytes when less than 1024', () {
        expect(500.toFileSize(), equals('500 B'));
      });

      test('returns KB when less than 1MB', () {
        expect(1024.toFileSize(), equals('1.00 KB'));
      });

      test('returns MB when less than 1GB', () {
        expect((1024 * 1024).toFileSize(), equals('1.00 MB'));
      });

      test('returns GB when 1GB or more', () {
        expect((1024 * 1024 * 1024).toFileSize(), equals('1.00 GB'));
      });

      test('returns correct decimal for KB', () {
        expect(2048.toFileSize(), equals('2.00 KB'));
      });
    });
  });
}
