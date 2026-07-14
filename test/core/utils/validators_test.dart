// test/core/utils/validators_test.dart

import 'package:flutter_structure/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    // ─── required ───────────────────────────────────────────
    group('required', () {
      test('returns error when value is null', () {
        expect(Validators.required(null), isNotNull);
      });

      test('returns error when value is empty', () {
        expect(Validators.required(''), isNotNull);
      });

      test('returns error when value is only spaces', () {
        expect(Validators.required('   '), isNotNull);
      });

      test('returns null when value is valid', () {
        expect(Validators.required('hello'), isNull);
      });

      test('uses custom fieldName in error message', () {
        expect(
          Validators.required(null, fieldName: 'Username'),
          equals('Username is required'),
        );
      });
    });

    // ─── email ──────────────────────────────────────────────
    group('email', () {
      test('returns error when value is null', () {
        expect(Validators.email(null), isNotNull);
      });

      test('returns error when value is empty', () {
        expect(Validators.email(''), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('missing@domain'), isNotNull);
        expect(Validators.email('@nodomain.com'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
        expect(Validators.email('user.name+tag@domain.co'), isNull);
      });
    });

    // ─── password ───────────────────────────────────────────
    group('password', () {
      test('returns error when value is null', () {
        expect(Validators.password(null), isNotNull);
      });

      test('returns error when value is empty', () {
        expect(Validators.password(''), isNotNull);
      });

      test('returns error when too short', () {
        expect(Validators.password('Ab1!'), isNotNull);
      });

      test('returns error when no uppercase letter', () {
        expect(Validators.password('abcdef1!'), isNotNull);
      });

      test('returns error when no lowercase letter', () {
        expect(Validators.password('ABCDEF1!'), isNotNull);
      });

      test('returns error when no number', () {
        expect(Validators.password('Abcdefg!'), isNotNull);
      });

      test('returns error when no special character', () {
        expect(Validators.password('Abcdef12'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('Abcdef1!'), isNull);
      });

      test('respects custom minLength', () {
        expect(Validators.password('Ab1!', minLength: 4), isNull);
      });
    });

    // ─── confirmPassword ────────────────────────────────────
    group('confirmPassword', () {
      test('returns error when value is empty', () {
        expect(Validators.confirmPassword('', 'Abcdef1!'), isNotNull);
      });

      test('returns error when passwords do not match', () {
        expect(
          Validators.confirmPassword('Abcdef1!', 'Different1!'),
          isNotNull,
        );
      });

      test('returns null when passwords match', () {
        expect(Validators.confirmPassword('Abcdef1!', 'Abcdef1!'), isNull);
      });
    });

    // ─── phone ──────────────────────────────────────────────
    group('phone', () {
      test('returns error when value is empty', () {
        expect(Validators.phone(''), isNotNull);
      });

      test('returns error for invalid phone number', () {
        expect(Validators.phone('123'), isNotNull);
        expect(Validators.phone('abcdefghij'), isNotNull);
      });

      test('returns null for valid phone with + prefix', () {
        expect(Validators.phone('+1234567890'), isNull);
      });

      test('returns null for valid phone with spaces', () {
        expect(Validators.phone('123 456 7890'), isNull);
      });
    });

    // ─── minLength ──────────────────────────────────────────
    group('minLength', () {
      test('returns error when value is empty', () {
        expect(Validators.minLength('', 5), isNotNull);
      });

      test('returns error when value is too short', () {
        expect(Validators.minLength('abc', 5), isNotNull);
      });

      test('returns null when value meets exact length', () {
        expect(Validators.minLength('abcde', 5), isNull);
      });

      test('returns null when value exceeds minimum length', () {
        expect(Validators.minLength('abcdefgh', 5), isNull);
      });

      test('uses custom fieldName in error message', () {
        expect(
          Validators.minLength('ab', 5, fieldName: 'Username'),
          equals('Username must be at least 5 characters'),
        );
      });
    });

    // ─── maxLength ──────────────────────────────────────────
    group('maxLength', () {
      test('returns null when value is empty', () {
        expect(Validators.maxLength('', 5), isNull);
      });

      test('returns error when value exceeds max length', () {
        expect(Validators.maxLength('abcdefgh', 5), isNotNull);
      });

      test('returns null when value meets exact length', () {
        expect(Validators.maxLength('abcde', 5), isNull);
      });
    });

    // ─── numeric ────────────────────────────────────────────
    group('numeric', () {
      test('returns error when value is empty', () {
        expect(Validators.numeric(''), isNotNull);
      });

      test('returns error for non-numeric value', () {
        expect(Validators.numeric('abc'), isNotNull);
      });

      test('returns null for valid integer', () {
        expect(Validators.numeric('42'), isNull);
      });

      test('returns null for valid decimal', () {
        expect(Validators.numeric('3.14'), isNull);
      });
    });

    // ─── url ────────────────────────────────────────────────
    group('url', () {
      test('returns error when value is empty', () {
        expect(Validators.url(''), isNotNull);
      });

      test('returns error for invalid url', () {
        expect(Validators.url('notaurl'), isNotNull);
        expect(Validators.url('ftp://invalid.com'), isNotNull);
      });

      test('returns null for valid http url', () {
        expect(Validators.url('http://example.com'), isNull);
      });

      test('returns null for valid https url', () {
        expect(Validators.url('https://example.com/path?q=1'), isNull);
      });
    });

    // ─── creditCard ─────────────────────────────────────────
    group('creditCard', () {
      test('returns error when value is empty', () {
        expect(Validators.creditCard(''), isNotNull);
      });

      test('returns error for invalid card number', () {
        expect(Validators.creditCard('1234567890123456'), isNotNull);
      });

      test('returns null for valid card number (Luhn)', () {
        // 4111111111111111 is a standard Visa test number
        expect(Validators.creditCard('4111111111111111'), isNull);
      });
    });

    // ─── date ───────────────────────────────────────────────
    group('date', () {
      test('returns error when value is empty', () {
        expect(Validators.date(''), isNotNull);
      });

      test('returns error for wrong format', () {
        expect(Validators.date('2026-03-15'), isNotNull);
        expect(Validators.date('15-03-2026'), isNotNull);
      });

      test('returns error for invalid month', () {
        expect(Validators.date('15/13/2026'), isNotNull);
      });

      test('returns error for invalid day', () {
        expect(Validators.date('32/01/2026'), isNotNull);
      });

      test('returns null for valid date', () {
        expect(Validators.date('15/03/2026'), isNull);
      });
    });

    // ─── combine ────────────────────────────────────────────
    group('combine', () {
      test('stops at first error', () {
        final validator = Validators.combine([
          (final v) => Validators.required(v),
          (final v) => Validators.email(v),
        ]);

        // required fires first
        expect(validator(null), equals('This field is required'));
      });

      test('returns null when all validators pass', () {
        final validator = Validators.combine([
          (final v) => Validators.required(v),
          (final v) => Validators.email(v),
        ]);

        expect(validator('user@example.com'), isNull);
      });

      test('returns second validator error when first passes', () {
        final validator = Validators.combine([
          (final v) => Validators.required(v),
          (final v) => Validators.email(v),
        ]);

        // required passes, email fails
        expect(validator('notanemail'), isNotNull);
      });
    });
  });
}
