// test/core/service/secure_storage_test.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_structure/core/service/secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'secure_storage_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorage secureStorage;

  // runs before each test — fresh mock every time
  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorage(mockStorage);
  });

  group('SecureStorage', () {
    // ─── write ───────────────────────────────────────────────
    group('write', () {
      test('calls storage.write with correct key and value', () async {
        // tell the mock: when write is called, return normally
        when(mockStorage.write(key: 'token', value: 'abc123')).thenAnswer((
          final _,
        ) async {
          return;
        });

        await secureStorage.write(key: 'token', value: 'abc123');

        // verify it was actually called once with the right arguments
        verify(mockStorage.write(key: 'token', value: 'abc123')).called(1);
      });
    });

    // ─── read ────────────────────────────────────────────────
    group('read', () {
      test('returns value when key exists', () async {
        when(mockStorage.read(key: 'token'))
            .thenAnswer((final _) async => 'abc123');

        final result = await secureStorage.read(key: 'token');

        expect(result, equals('abc123'));
      });

      test('returns null when key does not exist', () async {
        when(mockStorage.read(key: 'token'))
            .thenAnswer((final _) async => null);

        final result = await secureStorage.read(key: 'token');

        expect(result, isNull);
      });
    });

    // ─── delete ──────────────────────────────────────────────
    group('delete', () {
      test('calls storage.delete with correct key', () async {
        when(mockStorage.delete(key: 'token')).thenAnswer((final _) async {
          return;
        });

        await secureStorage.delete(key: 'token');

        verify(mockStorage.delete(key: 'token')).called(1);
      });
    });

    // ─── clearAll ────────────────────────────────────────────
    group('clearAll', () {
      test('calls storage.deleteAll', () async {
        when(mockStorage.deleteAll()).thenAnswer((final _) async {
          return;
        });

        await secureStorage.clearAll();

        verify(mockStorage.deleteAll()).called(1);
      });
    });
  });
}
