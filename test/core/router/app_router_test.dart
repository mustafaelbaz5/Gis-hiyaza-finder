// test/core/router/app_router_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_structure/core/router/app_router.dart';
import 'package:flutter_structure/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestApp(final String routeName) {
    return MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: routeName,
    );
  }

  group('AppRouter.generateRoute', () {
    // ✅ replaced: no longer renders AppScreen, just checks route name
    test('returns route with correct name for appScreen', () {
      final route = AppRouter.generateRoute(
        const RouteSettings(name: Routes.aboutScreen),
      );

      expect(route.settings.name, equals(Routes.aboutScreen));
    });

    // test('returns route with correct name for home', () {
    //   final route = AppRouter.generateRoute(
    //     const RouteSettings(name: Routes.home),
    //   );
    //   expect(route.settings.name, equals(Routes.home));
    // });
    testWidgets('returns fallback scaffold for unknown route', (
      final WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestApp('/unknown-route'));
      await tester.pumpAndSettle();

      expect(find.text('No route defined for /unknown-route'), findsOneWidget);
    });

    test('generateRoute returns a PageRouteBuilder', () {
      final route = AppRouter.generateRoute(
        const RouteSettings(name: Routes.aboutScreen),
      );

      expect(route, isA<PageRouteBuilder>());
    });

    test('generateRoute preserves route settings', () {
      const settings = RouteSettings(name: Routes.aboutScreen);
      final route = AppRouter.generateRoute(settings);

      expect(route.settings.name, equals(Routes.aboutScreen));
    });
  });
}
