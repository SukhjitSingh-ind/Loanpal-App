# LoanPal — Testing Guide

---

## 1. Running the Full Test Suite

```bash
flutter test
```

Expected output: all tests pass with no failures.

---

## 2. Running Individual Test Files

```bash
flutter test test/emi_calculator_test.dart
flutter test test/form_validators_test.dart
flutter test test/user_profile_test.dart
flutter test test/auth_ui_flow_test.dart
flutter test test/widget_test.dart
```

---

## 3. Test Categories

### Unit Tests

Pure Dart tests. No widget rendering, no Firebase connections.

| File | What it tests |
|---|---|
| `test/emi_calculator_test.dart` | EMI formula, amortisation schedule generation, burden level computation, edge cases (0% interest, single payment, rounding) |
| `test/form_validators_test.dart` | All `FormValidators` static methods: username, first/last name, email, password, confirm-password |
| `test/user_profile_test.dart` | `UserProfile.toMap`, `UserProfile.fromMap` (all field types including missing fields), `copyWith`, `UserProfileService` in-memory cache |

### Widget Tests

Flutter widget tests that render screens in a test environment. They use `MaterialApp` with `LoanPalTheme` as the test host.

| File | What it tests |
|---|---|
| `test/widget_test.dart` | `CalculatorScreen` renders title and primary sliders |
| `test/auth_ui_flow_test.dart` | `LoginScreen` rendering, validation, password toggle; `RegisterScreen` rendering, validation errors, password mismatch; `CalculatorScreen` greeting personalisation; sign-out dialog |

---

## 4. How Firebase-Dependent Functionality Is Tested

The current test suite does **not** connect to Firebase. Firebase-dependent behaviour is tested in the following ways:

- **`UserProfileService` caching** — tests set the in-memory cache directly via `setCachedProfile` and verify that `getUserProfile` returns the cached result without making a network call.
- **`UserProfile` serialisation** — tests create `Timestamp` objects directly from `cloud_firestore` (no network required) to verify `toMap`/`fromMap` round-trips.
- **Auth screen behaviour** — screens that call `AuthService` in response to user actions are not tested end-to-end because the auth call would fail without a real Firebase project or emulator. Only the UI state before submission is tested (rendering, validation, dialogs).

---

## 5. Firebase Emulator Suite (Not Currently Used)

The project does not currently use the Firebase Emulator Suite. Integration tests that cover the full auth and Firestore write path would require it.

To set up the emulator for future integration tests:

```bash
npm install -g firebase-tools
firebase emulators:start --only auth,firestore
```

In test code, connect to the emulator before the first Firebase call:

```dart
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

---

## 6. Adding Tests for New Features

### Adding a unit test

1. Create a file in `test/` named `<feature>_test.dart`.
2. Import `package:flutter_test/flutter_test.dart`.
3. Group related tests with `group(...)` and individual cases with `test(...)`.
4. Use `expect(actual, matcher)` for assertions.

### Adding a widget test

1. Create or add to a test file in `test/`.
2. Use `testWidgets('description', (WidgetTester tester) async { ... })`.
3. Wrap the widget under test in `MaterialApp(theme: LoanPalTheme.lightTheme, home: ...)`.
4. Use `tester.pumpWidget(...)` to render, `tester.pump()` to trigger a single frame, and `tester.pumpAndSettle()` to wait for all animations.
5. Use `find.text(...)`, `find.byType(...)`, `find.byIcon(...)`, `find.byTooltip(...)` to locate widgets.
6. Use `tester.tap(...)`, `tester.enterText(...)` to simulate interactions.

### Teardown for tests using `UserProfileService`

`UserProfileService._cachedProfile` is a static field. Tests that write to the cache must clear it in `tearDown` to avoid interfering with other tests:

```dart
tearDown(() {
  UserProfileService().clearCache();
});
```

---

## 7. What Must Be Verified Before Merging

- [ ] `flutter test` passes with zero failures.
- [ ] `flutter analyze` reports zero issues.
- [ ] New behaviour introduced by the change has at least one test.
- [ ] No existing test was weakened or deleted without justification.

---

## 8. Recommended Future Testing Improvements

- **Firebase Emulator Suite integration tests** — end-to-end tests covering registration → login → profile read → sign-out using a local emulator.
- **`AuthService` unit tests** — mock `FirebaseAuth` to test `_handleAuthException` code-to-message mapping exhaustively.
- **`UserProfileService` Firestore tests** — mock `FirebaseFirestore` to test the `createUserProfile` `createdAt`-preservation logic and the error path.
- **Golden tests** — snapshot tests for `BurdenIndicator`, `PrincipalInterestBar`, and `ResultCard` to prevent unintended visual regressions.
