// test/core/utils/extensions/string_ext_test.dart

import 'package:flutter_structure/core/utils/extensions/string_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExt', () {
    // ─── capitalize ──────────────────────────────────────────
    group('capitalize', () {
      test('returns empty string unchanged', () {
        expect(''.capitalize(), equals(''));
      });

      test('capitalizes first letter only', () {
        expect('hello'.capitalize(), equals('Hello'));
      });

      test('does not change already capitalized string', () {
        expect('Hello'.capitalize(), equals('Hello'));
      });

      test('handles single character', () {
        expect('a'.capitalize(), equals('A'));
      });
    });

    // ─── capitalizeWords ─────────────────────────────────────
    group('capitalizeWords', () {
      test('returns empty string unchanged', () {
        expect(''.capitalizeWords(), equals(''));
      });

      test('capitalizes single word', () {
        expect('hello'.capitalizeWords(), equals('Hello'));
      });

      test('capitalizes every word', () {
        expect('hello world'.capitalizeWords(), equals('Hello World'));
      });

      test('handles already capitalized words', () {
        expect('Hello World'.capitalizeWords(), equals('Hello World'));
      });
    });

    // ─── removeWhitespace ────────────────────────────────────
    group('removeWhitespace', () {
      test('returns string without spaces unchanged', () {
        expect('hello'.removeWhitespace(), equals('hello'));
      });

      test('removes all spaces', () {
        expect('hello world'.removeWhitespace(), equals('helloworld'));
      });

      test('removes tabs and newlines', () {
        expect('hello\tworld\n'.removeWhitespace(), equals('helloworld'));
      });

      test('removes multiple consecutive spaces', () {
        expect('hello   world'.removeWhitespace(), equals('helloworld'));
      });
    });

    // ─── truncate ────────────────────────────────────────────
    group('truncate', () {
      test('returns string unchanged when shorter than max', () {
        expect('hello'.truncate(10), equals('hello'));
      });

      test('returns string unchanged when equal to max', () {
        expect('hello'.truncate(5), equals('hello'));
      });

      test('truncates with default ellipsis when longer than max', () {
        expect('hello world'.truncate(5), equals('hello...'));
      });

      test('truncates with custom ellipsis', () {
        expect('hello world'.truncate(5, ellipsis: '---'), equals('hello---'));
      });
    });

    // ─── isValidEmail ────────────────────────────────────────
    group('isValidEmail', () {
      test('returns true for valid email', () {
        expect('user@example.com'.isValidEmail, isTrue);
      });

      test('returns false for missing @', () {
        expect('userexample.com'.isValidEmail, isFalse);
      });

      test('returns false for missing domain', () {
        expect('user@'.isValidEmail, isFalse);
      });
    });

    // ─── isValidPhone ────────────────────────────────────────
    group('isValidPhone', () {
      test('returns true for valid phone', () {
        expect('1234567890'.isValidPhone, isTrue);
      });

      test('returns true for valid phone with + prefix', () {
        expect('+1234567890'.isValidPhone, isTrue);
      });

      test('returns false for too short phone', () {
        expect('123'.isValidPhone, isFalse);
      });

      test('returns false for phone with letters', () {
        expect('123abc7890'.isValidPhone, isFalse);
      });
    });

    // ─── isValidUrl ──────────────────────────────────────────
    group('isValidUrl', () {
      test('returns true for valid http url', () {
        expect('http://example.com'.isValidUrl, isTrue);
      });

      test('returns true for valid https url', () {
        expect('https://example.com/path?q=1'.isValidUrl, isTrue);
      });

      test('returns false for missing protocol', () {
        expect('example.com'.isValidUrl, isFalse);
      });

      test('returns false for invalid protocol', () {
        expect('ftp://example.com'.isValidUrl, isFalse);
      });
    });
  });
}
