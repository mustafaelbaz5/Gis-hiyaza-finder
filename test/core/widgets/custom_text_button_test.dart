// test/core/widgets/custom_text_button_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_structure/core/widgets/custom_text_button.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(final Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (final context, final _) => MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(body: child),
      ),
    );
  }

  group('CustomTextButton', () {
    // ─── rendering ───────────────────────────────────────────
    group('rendering', () {
      testWidgets('renders button text', (final WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestWidget(CustomTextButton(text: 'Submit', onPressed: () {})),
        );

        expect(find.text('Submit'), findsOneWidget);
      });

      testWidgets('shows prefix icon when provided', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(
              text: 'Login',
              onPressed: () {},
              prefixIcon: const Icon(Icons.login),
            ),
          ),
        );

        expect(find.byIcon(Icons.login), findsOneWidget);
      });

      testWidgets('shows suffix icon when provided', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(
              text: 'Next',
              onPressed: () {},
              suffixIcon: const Icon(Icons.arrow_forward),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });

      testWidgets('shows loading indicator when isLoading is true', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(text: 'Submit', onPressed: () {}, isLoading: true),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Submit'), findsNothing);
      });
    });

    // ─── styles ──────────────────────────────────────────────
    group('styles', () {
      testWidgets('renders filled style by default', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(CustomTextButton(text: 'Submit', onPressed: () {})),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders outlined style', (final WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton.outlined(text: 'Cancel', onPressed: () {}),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('renders text only style', (final WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton.text(text: 'Skip', onPressed: () {}),
          ),
        );

        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
      });
    });

    // ─── sizes ───────────────────────────────────────────────
    group('sizes', () {
      testWidgets('renders small size with correct height', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(
              text: 'Submit',
              onPressed: () {},
              size: CustomButtonSize.small,
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.height, equals(40));
      });

      testWidgets('renders medium size with correct height', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(
              text: 'Submit',
              onPressed: () {},
              size: CustomButtonSize.medium,
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.height, equals(52));
      });

      testWidgets('renders large size with correct height', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(
              text: 'Submit',
              onPressed: () {},
              size: CustomButtonSize.large,
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.height, equals(56));
      });
    });

    // ─── states ──────────────────────────────────────────────
    group('states', () {
      testWidgets('does not call onPressed when isDisabled is true', (
        final WidgetTester tester,
      ) async {
        bool pressed = false;

        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(
              text: 'Submit',
              onPressed: () => pressed = true,
              isDisabled: true,
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        expect(pressed, isFalse);
      });

      testWidgets('does not call onPressed when isLoading is true', (
        final WidgetTester tester,
      ) async {
        bool pressed = false;

        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(
              text: 'Submit',
              onPressed: () => pressed = true,
              isLoading: true,
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        expect(pressed, isFalse);
      });

      testWidgets('does not call onPressed when onPressed is null', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const CustomTextButton(text: 'Submit', onPressed: null),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      });
    });

    // ─── callbacks ───────────────────────────────────────────
    group('callbacks', () {
      testWidgets('calls onPressed when tapped', (
        final WidgetTester tester,
      ) async {
        bool pressed = false;

        await tester.pumpWidget(
          buildTestWidget(
            CustomTextButton(text: 'Submit', onPressed: () => pressed = true),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        expect(pressed, isTrue);
      });
    });
  });
}
