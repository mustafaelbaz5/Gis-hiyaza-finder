// test/core/utils/extensions/datetime_ext_test.dart

import 'package:flutter_structure/core/utils/extensions/datetime_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExt', () {
    // ─── formattedDate ───────────────────────────────────────
    group('formattedDate', () {
      test('formats date with leading zeros', () {
        final date = DateTime(2026, 1, 5);
        expect(date.formattedDate, equals('05/01/2026'));
      });

      test('formats date without leading zeros needed', () {
        final date = DateTime(2026, 12, 25);
        expect(date.formattedDate, equals('25/12/2026'));
      });
    });

    // ─── formattedTime ───────────────────────────────────────
    group('formattedTime', () {
      test('formats time with leading zeros', () {
        final date = DateTime(2026, 1, 1, 9, 5);
        expect(date.formattedTime, equals('09:05'));
      });

      test('formats time without leading zeros needed', () {
        final date = DateTime(2026, 1, 1, 14, 30);
        expect(date.formattedTime, equals('14:30'));
      });
    });

    // ─── formattedDateTime ───────────────────────────────────
    group('formattedDateTime', () {
      test('combines date and time correctly', () {
        final date = DateTime(2026, 3, 15, 9, 5);
        expect(date.formattedDateTime, equals('15/03/2026 09:05'));
      });
    });

    // ─── isToday ─────────────────────────────────────────────
    group('isToday', () {
      test('returns true for today', () {
        final now = DateTime.now();
        expect(now.isToday, isTrue);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isToday, isFalse);
      });

      test('returns false for tomorrow', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        expect(tomorrow.isToday, isFalse);
      });
    });

    // ─── isYesterday ─────────────────────────────────────────
    group('isYesterday', () {
      test('returns true for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(yesterday.isYesterday, isTrue);
      });

      test('returns false for today', () {
        final now = DateTime.now();
        expect(now.isYesterday, isFalse);
      });

      test('returns false for two days ago', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        expect(twoDaysAgo.isYesterday, isFalse);
      });
    });

    // ─── timeAgo ─────────────────────────────────────────────
    group('timeAgo', () {
      test('returns Just now for recent time', () {
        final now = DateTime.now();
        expect(now.timeAgo, equals('Just now'));
      });

      test('returns minutes ago', () {
        final date = DateTime.now().subtract(const Duration(minutes: 5));
        expect(date.timeAgo, equals('5 minutes ago'));
      });

      test('returns singular minute ago', () {
        final date = DateTime.now().subtract(const Duration(minutes: 1));
        expect(date.timeAgo, equals('1 minute ago'));
      });

      test('returns hours ago', () {
        final date = DateTime.now().subtract(const Duration(hours: 3));
        expect(date.timeAgo, equals('3 hours ago'));
      });

      test('returns singular hour ago', () {
        final date = DateTime.now().subtract(const Duration(hours: 1));
        expect(date.timeAgo, equals('1 hour ago'));
      });

      test('returns days ago', () {
        final date = DateTime.now().subtract(const Duration(days: 5));
        expect(date.timeAgo, equals('5 days ago'));
      });

      test('returns singular day ago', () {
        final date = DateTime.now().subtract(const Duration(days: 1));
        expect(date.timeAgo, equals('1 day ago'));
      });

      test('returns months ago', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        expect(date.timeAgo, equals('2 months ago'));
      });

      test('returns years ago', () {
        final date = DateTime.now().subtract(const Duration(days: 400));
        expect(date.timeAgo, equals('1 year ago'));
      });
    });
  });
}
