// test/core/api/dio_factory_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_structure/core/api/api_interceptors.dart';
import 'package:flutter_structure/core/api/dio_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // helper: creates a dio instance with default test values
  Dio buildDio({final bool enableLogging = true}) {
    return DioFactory.create(
      baseUrl: 'https://api.test.com',
      getToken: () async => 'test-token',
      enableLogging: enableLogging,
    );
  }

  group('DioFactory', () {
    // ─── baseUrl ─────────────────────────────────────────────
    group('baseUrl', () {
      test('sets baseUrl correctly', () {
        final dio = buildDio();
        expect(dio.options.baseUrl, equals('https://api.test.com'));
      });
    });

    // ─── timeout ─────────────────────────────────────────────
    group('timeout', () {
      test('sets default timeout to 30 seconds', () {
        final dio = buildDio();
        expect(dio.options.connectTimeout, equals(const Duration(seconds: 30)));
        expect(dio.options.receiveTimeout, equals(const Duration(seconds: 30)));
      });

      test('sets custom timeout correctly', () {
        final dio = DioFactory.create(
          baseUrl: 'https://api.test.com',
          getToken: () async => 'test-token',
          timeout: const Duration(seconds: 60),
        );
        expect(dio.options.connectTimeout, equals(const Duration(seconds: 60)));
        expect(dio.options.receiveTimeout, equals(const Duration(seconds: 60)));
      });
    });

    // ─── headers ─────────────────────────────────────────────
    group('headers', () {
      test('sets Accept header to application/json', () {
        final dio = buildDio();
        expect(dio.options.headers['Accept'], equals('application/json'));
      });

      test('sets Content-Type header to application/json', () {
        final dio = buildDio();
        expect(dio.options.headers['Content-Type'], equals('application/json'));
      });
    });

    // ─── interceptors ────────────────────────────────────────
    group('interceptors', () {
      test('always adds AuthInterceptor', () {
        final dio = buildDio();
        final hasAuth = dio.interceptors.any((final i) => i is AuthInterceptor);
        expect(hasAuth, isTrue);
      });

      test('adds LoggerInterceptor when enableLogging is true', () {
        final dio = buildDio(enableLogging: true);
        final hasLogger = dio.interceptors.any(
          (final i) => i is LoggerInterceptor,
        );
        expect(hasLogger, isTrue);
      });

      test('does not add LoggerInterceptor when enableLogging is false', () {
        final dio = buildDio(enableLogging: false);
        final hasLogger = dio.interceptors.any(
          (final i) => i is LoggerInterceptor,
        );
        expect(hasLogger, isFalse);
      });
    });
  });
}
