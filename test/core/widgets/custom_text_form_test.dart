// test/core/widgets/custom_text_form_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_structure/core/widgets/custom_text_form_.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(final Widget child) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(body: child),
    );
  }

  group('CustomTextForm', () {
    // ─── rendering ───────────────────────────────────────────
    group('rendering', () {
      testWidgets('renders with hint text', (final WidgetTester tester) async {
        await tester.pumpWidget(
          buildTestWidget(const CustomTextForm(hintText: 'Email')),
        );

        expect(find.text('Email'), findsOneWidget);
      });

      testWidgets('does not accept input when disabled', (
        final WidgetTester tester,
      ) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          buildTestWidget(
            CustomTextForm(
              hintText: 'Email',
              enabled: false,
              controller: controller,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'hello');
        await tester.pump();

        expect(controller.text, isEmpty);
      });

      testWidgets('does not accept input when readOnly', (
        final WidgetTester tester,
      ) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          buildTestWidget(
            CustomTextForm(
              hintText: 'Email',
              readOnly: true,
              controller: controller,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'hello');
        await tester.pump();

        expect(controller.text, isEmpty);
      });
    });

    // ─── password ────────────────────────────────────────────
    group('password', () {
      testWidgets('shows visibility_off icon when isPassword is true', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const CustomTextForm(hintText: 'Password', isPassword: true),
          ),
        );

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      });

      testWidgets('toggles to visibility icon when toggle is tapped', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const CustomTextForm(hintText: 'Password', isPassword: true),
          ),
        );

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('hides text when isPassword is true', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(
            const CustomTextForm(hintText: 'Password', isPassword: true),
          ),
        );

        // check obscureText is true on the underlying EditableText
        final field = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(field.obscureText, isTrue);
      });
      testWidgets('shows text when isPassword is false', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(const CustomTextForm(hintText: 'Email')),
        );

        final field = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(field.obscureText, isFalse);
      });
    });

    // ─── callbacks ───────────────────────────────────────────
    group('callbacks', () {
      testWidgets('calls onChanged when text is entered', (
        final WidgetTester tester,
      ) async {
        String? changedValue;

        await tester.pumpWidget(
          buildTestWidget(
            CustomTextForm(
              hintText: 'Email',
              onChanged: (final value) => changedValue = value,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'hello');
        expect(changedValue, equals('hello'));
      });

      testWidgets('calls onTap when field is tapped', (
        final WidgetTester tester,
      ) async {
        bool tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            CustomTextForm(hintText: 'Email', onTap: () => tapped = true),
          ),
        );

        await tester.tap(find.byType(TextFormField));
        expect(tapped, isTrue);
      });
    });

    // ─── validator ───────────────────────────────────────────
    group('validator', () {
      testWidgets('shows error message when validator returns error', (
        final WidgetTester tester,
      ) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildTestWidget(
            Form(
              key: formKey,
              child: CustomTextForm(
                hintText: 'Email',
                validator: (final _) => 'Email is required',
              ),
            ),
          ),
        );

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('shows no error when validator returns null', (
        final WidgetTester tester,
      ) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          buildTestWidget(
            Form(
              key: formKey,
              child: CustomTextForm(
                  hintText: 'Email', validator: (final _) => null),
            ),
          ),
        );

        formKey.currentState!.validate();
        await tester.pump();

        expect(find.text('Email is required'), findsNothing);
      });
    });

    // ─── RTL ─────────────────────────────────────────────────
    group('RTL', () {
      testWidgets('aligns text to right when isRTL is true', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(const CustomTextForm(hintText: 'Email', isRTL: true)),
        );

        final field = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(field.textAlign, equals(TextAlign.right));
      });

      testWidgets('aligns text to left when isRTL is false', (
        final WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          buildTestWidget(const CustomTextForm(hintText: 'Email')),
        );

        final field = tester.widget<EditableText>(
          find.byType(EditableText).first,
        );
        expect(field.textAlign, equals(TextAlign.left));
      });
    });
  });
}
