// test/core/utils/extensions/list_ext_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_structure/core/utils/extensions/list_ext.dart';

void main() {
  group('ListExt', () {
    // ─── firstOrNull ─────────────────────────────────────────
    group('firstOrNull', () {
      test('returns null for empty list', () {
        expect(<int>[].firstOrNull, isNull);
      });

      test('returns first element for non-empty list', () {
        expect([1, 2, 3].firstOrNull, equals(1));
      });
    });

    // ─── lastOrNull ──────────────────────────────────────────
    group('lastOrNull', () {
      test('returns null for empty list', () {
        expect(<int>[].lastOrNull, isNull);
      });

      test('returns last element for non-empty list', () {
        expect([1, 2, 3].lastOrNull, equals(3));
      });
    });
  });
}
