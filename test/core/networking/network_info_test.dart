// test/core/networking/network_info_test.dart

import 'package:flutter_structure/core/networking/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker])
void main() {
  late MockInternetConnectionChecker mockChecker;
  late NetworkInfoImpl networkInfo;

  setUp(() {
    mockChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockChecker);
  });

  group('NetworkInfoImpl', () {
    // ─── isConnected ─────────────────────────────────────────
    group('isConnected', () {
      test('returns true when device is connected', () async {
        when(mockChecker.hasConnection).thenAnswer((final _) async => true);

        final result = await networkInfo.isConnected;

        expect(result, isTrue);
      });

      test('returns false when device is not connected', () async {
        when(mockChecker.hasConnection).thenAnswer((final _) async => false);

        final result = await networkInfo.isConnected;

        expect(result, isFalse);
      });
    });

    // ─── onStatusChange ──────────────────────────────────────
    group('onStatusChange', () {
      test('emits connected status', () async {
        when(
          mockChecker.onStatusChange,
        ).thenAnswer((final _) => Stream.value(InternetConnectionStatus.connected));

        expect(
          networkInfo.onStatusChange,
          emits(InternetConnectionStatus.connected),
        );
      });

      test('emits disconnected status', () async {
        when(mockChecker.onStatusChange).thenAnswer(
          (final _) => Stream.value(InternetConnectionStatus.disconnected),
        );

        expect(
          networkInfo.onStatusChange,
          emits(InternetConnectionStatus.disconnected),
        );
      });
    });
  });
}
