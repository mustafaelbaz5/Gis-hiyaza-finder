# ✅ Testing Guide

This guide covers everything you need to know about writing,
organizing, and running tests in this project.

---

## Overview

This project follows the **testing pyramid**:

```
        ▲
       /  \
      / E2E \          ← few — full app flows
     /────────\
    /  Widget  \       ← moderate — UI components
   /────────────\
  /  Unit Tests  \     ← many — logic, functions, classes
 /────────────────\
```

**Rule:** write many unit tests, moderate widget tests,
and only a few integration tests.

---

## Test Types

| Type        | What it tests               | Speed  | Tool                 |
| ----------- | --------------------------- | ------ | -------------------- |
| Unit        | functions, classes, logic   | Fast   | `test()`           |
| Widget      | UI components, interactions | Medium | `testWidgets()`    |
| Integration | full app flows on device    | Slow   | `integration_test` |

---

## Folder Structure

Tests mirror the `lib/` folder structure exactly:

```
test/
  core/
    api/
      dio_factory_test.dart
    networking/
      network_info_test.dart
      network_info_test.mocks.dart      ← auto-generated
    router/
      app_router_test.dart
    service/
      secure_storage_test.dart
      secure_storage_test.mocks.dart    ← auto-generated
    utils/
      extensions/
        datetime_ext_test.dart
        list_ext_test.dart
        num_ext_test.dart
        string_ext_test.dart
      validators_test.dart
    widgets/
      custom_text_button_test.dart
      custom_text_form_test.dart
  features/
    auth/                               ← added when feature is built
      data/
        models/
          login_request_body_test.dart
        remote/
          auth_remote_api_test.dart
        repo/
          auth_repo_impl_test.dart
      logic/
        cubit/
          auth_cubit_test.dart
      ui/
        widgets/
          login_form_test.dart

integration_test/
  app_test.dart
```

---

## Running Tests

```bash
# Run all tests
make test

# Run all tests with each test name shown
make test-verbose

# Run with coverage report
make test-coverage

# Run core layer only
make test-core

# Run features only
make test-features

# Run a specific file
make test-file FILE=test/core/utils/validators_test.dart
```

---

## Writing Tests

### Unit Test — pure logic

Use `test()` when there is no UI involved:

```dart
// test/core/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
      });
    });
  });
}
```

### Widget Test — UI components

Use `testWidgets()` when testing a widget:

```dart
// test/core/widgets/custom_text_button_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/core/widgets/custom_text_button.dart';

void main() {
  // always wrap with MaterialApp
  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(body: child),
    );
  }

  group('CustomTextButton', () {
    testWidgets('renders button text', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          CustomTextButton(text: 'Submit', onPressed: () {}),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          CustomTextButton(
            text: 'Submit',
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });
  });
}
```

### Unit Test with Mocking — external dependencies

Use `mockito` when the class depends on something external
(network, storage, device):

```dart
// test/core/service/secure_storage_test.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/core/service/secure_storage.dart';

import 'secure_storage_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorage secureStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = SecureStorage(mockStorage);
  });

  group('SecureStorage', () {
    test('returns value when key exists', () async {
      when(
        mockStorage.read(key: 'token'),
      ).thenAnswer((_) async => 'abc123');

      final result = await secureStorage.read(key: 'token');
      expect(result, equals('abc123'));
    });
  });
}
```

After adding `@GenerateMocks`, run:

```bash
make generate
```

---

## Testing a New Feature

When you build a new feature follow this order:

### 1. Models — test JSON serialization

```dart
group('LoginRequestBody', () {
  test('toJson returns correct map', () {
    final body = LoginRequestBody(
      email: 'user@example.com',
      password: 'Password1!',
    );

    expect(body.toJson(), equals({
      'email': 'user@example.com',
      'password': 'Password1!',
    }));
  });

  test('fromJson parses correctly', () {
    final body = LoginRequestBody.fromJson({
      'email': 'user@example.com',
      'password': 'Password1!',
    });

    expect(body.email, equals('user@example.com'));
  });
});
```

### 2. Repository — test success and failure

```dart
@GenerateMocks([AuthRemoteApi])
void main() {
  late MockAuthRemoteApi mockApi;
  late AuthRepoImpl repo;

  setUp(() {
    mockApi = MockAuthRemoteApi();
    repo = AuthRepoImpl(mockApi);
  });

  group('AuthRepoImpl', () {
    test('returns user on successful login', () async {
      when(mockApi.login(any)).thenAnswer(
        (_) async => LoginResponseBody(token: 'abc123'),
      );

      final result = await repo.login(
        LoginRequestBody(email: 'u@e.com', password: 'Pass1!'),
      );

      expect(result.token, equals('abc123'));
    });

    test('throws failure on error', () async {
      when(mockApi.login(any)).thenThrow(ServerException());

      expect(
        () => repo.login(LoginRequestBody(email: '', password: '')),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
```

### 3. Cubit — test state emissions

```dart
@GenerateMocks([AuthRepo])
void main() {
  late MockAuthRepo mockRepo;
  late AuthCubit cubit;

  setUp(() {
    mockRepo = MockAuthRepo();
    cubit = AuthCubit(mockRepo);
  });

  tearDown(() => cubit.close());

  group('AuthCubit', () {
    test('emits loading then success on login', () async {
      when(mockRepo.login(any)).thenAnswer(
        (_) async => LoginResponseBody(token: 'abc123'),
      );

      expect(
        cubit.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ]),
      );

      await cubit.login(email: 'u@e.com', password: 'Pass1!');
    });

    test('emits loading then error on failure', () async {
      when(mockRepo.login(any)).thenThrow(ServerException());

      expect(
        cubit.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthError>(),
        ]),
      );

      await cubit.login(email: 'u@e.com', password: 'Pass1!');
    });
  });
}
```

### 4. Widgets — test forms and interactions

```dart
group('LoginForm', () {
  testWidgets('shows error when email is empty', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: const LoginForm(),
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
  });
});
```

---

## What to Test vs Skip

### ✅ Always test

- Functions with logic (validators, extensions, formatters)
- Repository implementations (success + failure cases)
- Cubit/Bloc state emissions
- Widget interactions (tap, input, validation)
- Classes that wrap external dependencies

### ❌ Skip

- Abstract classes and interfaces — no logic
- State classes — just data holders
- Screen widgets that only compose other widgets
- `NavigationExt` — just wraps Flutter's Navigator
- Theme/color files — no logic

---

## The Golden Rules

**1. One test — one thing**
Each test checks exactly one behavior.
If a test fails you know immediately what broke.

**2. Tests must be independent**
Never let one test depend on another.
Use `setUp` to reset state before each test.

**3. Name tests like sentences**

```dart
// ✅ good
test('returns null when email is valid', ...);

// ❌ bad
test('test3', ...);
```

**4. Test behavior not implementation**
Test what the code does, not how it does it internally.

**5. Run tests before every commit**

```bash
make test
```

**6. One new feature = tests alongside it**
Never leave testing for later — write tests as you build.

---

## Useful Matchers

```dart
// values
expect(value, equals(42));
expect(value, isNull);
expect(value, isNotNull);
expect(value, isTrue);
expect(value, isFalse);
expect(value, isA<String>());

// numbers
expect(value, greaterThan(0));
expect(value, lessThan(100));

// strings
expect(text, contains('hello'));
expect(text, startsWith('Hello'));

// collections
expect(list, hasLength(3));
expect(list, isEmpty);
expect(list, contains('item'));

// async
expect(future, throwsA(isA<Exception>()));
expect(stream, emits(42));
expect(stream, emitsInOrder([1, 2, 3]));

// widgets
expect(find.text('hello'), findsOneWidget);
expect(find.byType(TextField), findsWidgets);
expect(find.byKey(Key('my_key')), findsNothing);
```

---

## ✅ Testing Checklist

### Per file

- [ ] Test file mirrors `lib/` folder structure
- [ ] All logic branches covered
- [ ] Both success and failure cases tested
- [ ] Tests are independent (use `setUp`)
- [ ] Test names are descriptive sentences

### Per feature

- [ ] Models — `fromJson` and `toJson`
- [ ] Repository — success, failure, error handling
- [ ] Cubit — all state emissions
- [ ] Widgets — validation, interactions, callbacks

### Before every commit

- [ ] `make test` passes
- [ ] `make analyze` passes
- [ ] `make format` applied

---

## Next Steps

| Guide                              | What's next                           |
| ---------------------------------- | ------------------------------------- |
| [Troubleshooting](TROUBLESHOOTING.md) | Fix common test issues                |
| [CI/CD Workflow](CICD.md)             | Tests run automatically on every push |
