# LoanPal — Coding Standards

This document describes the conventions contributors must follow. It distinguishes official Dart and Flutter conventions from project-specific rules.

---

## 1. Dart Naming Conventions

Follow the [official Dart style guide](https://dart.dev/effective-dart/style).

| Element | Convention | Example |
|---|---|---|
| Classes, enums, typedefs | `UpperCamelCase` | `UserProfile`, `AuthService` |
| Variables, parameters, functions | `lowerCamelCase` | `isLoading`, `handleLogin` |
| Constants | `lowerCamelCase` | `minPasswordLength` |
| Private members | `_lowerCamelCase` | `_formKey`, `_authService` |
| Files and directories | `snake_case` | `auth_service.dart`, `lib/ui/auth/` |
| Enum values | `lowerCamelCase` | `AllowedTenure.monthsOnly` |

---

## 2. File and Directory Organisation

```
lib/
├── core/           # Shared utilities with no Flutter dependency (validators, constants)
├── logic/          # Business logic and domain computation (no UI)
├── models/         # Domain data models (serialisation/deserialisation only)
├── services/       # External data access (Firebase Auth, Firestore)
├── ui/             # Screens and theme
│   └── auth/       # Authentication screens
├── utils/          # Formatting helpers
└── widgets/        # Reusable UI components (no business logic)
```

- Each file contains a single primary class.
- Tests mirror the `lib/` structure under `test/`.

---

## 3. Widget Composition

- **Screens** (`StatefulWidget` or `StatelessWidget`) orchestrate layout, form state, and event handling.
- **Widgets** under `lib/widgets/` are reusable components. They receive data through constructor parameters and communicate upward through callbacks. They must not contain Firebase or service calls.
- **Do not** inline complex logic inside `build`. Extract to named methods or computed getters.
- Prefer `const` constructors wherever possible to allow Flutter to skip unnecessary rebuilds.

---

## 4. Class and Method Responsibilities

- A service class (e.g. `AuthService`, `UserProfileService`) handles a single external concern.
- A screen class handles a single screen's state, validation, and user events.
- Keep `build` methods focused on structure and layout, not computation.
- Keep methods short. If a method grows beyond ~30 lines, consider extracting a named helper.

---

## 5. Null Safety and Type Safety

- Never use `dynamic` unless there is a specific unavoidable reason (e.g. Firestore map values).
- Prefer `as Type?` over `as Type` when casting from dynamic maps; handle the null case explicitly.
- **Do not** use the null-assertion operator (`!`) on `User?` or other nullable objects after a `?.property != null` check. Dart does not flow-narrow through `?.`. Instead, assign the nullable property to a local variable and check that:

  ```dart
  // WRONG — analyser may not narrow user after user?.email != null
  if (user?.email != null && user!.email!.isNotEmpty) { ... }

  // CORRECT — local variable is properly narrowed
  final email = user?.email;
  if (email != null && email.isNotEmpty) { ... }
  ```

---

## 6. State Management

LoanPal uses **built-in Flutter state** only. Do not introduce Provider, Riverpod, Bloc, or any other third-party state-management library without a concrete technical justification and team agreement.

- Use `setState` for local screen state.
- Use `StreamBuilder` for reactive Firebase auth state.
- Use `FutureBuilder` for one-shot async data loading.
- Use `ChangeNotifier` + `addListener/removeListener` for simple global configuration (see `AppConfig`).

---

## 7. Asynchronous Programming

- Mark async event handlers `Future<void>`.
- Guard against widget disposal with `mounted` checks before calling `setState` or `ScaffoldMessenger`:

  ```dart
  if (mounted) {
    setState(() => _isLoading = false);
  }
  ```

- Use a guard at the top of event handlers to prevent duplicate submissions:

  ```dart
  if (_isLoading) return;
  ```

- Always use `finally` to reset loading state so that a thrown exception does not leave the UI stuck.

---

## 8. Error Handling

- Service methods translate low-level exceptions into meaningful messages before rethrowing.
- UI handlers catch errors and display them via `SnackBar`. They do not swallow errors silently.
- Use specific exception types where meaningful (e.g. `ProfileCreationException`) rather than `Exception` or plain strings for errors that carry recoverable data.
- Do not use `print` or `debugPrint` to swallow exceptions. Log with `debugPrint` only for non-critical warnings where the failure is truly inconsequential.

---

## 9. Dependency Management

- Firebase dependencies (`firebase_core`, `firebase_auth`, `cloud_firestore`) are the only runtime dependencies beyond Flutter itself.
- Do not add dependencies without justification. Prefer Flutter and Dart built-in capabilities.
- Keep `pubspec.yaml` and `pubspec.lock` in source control.

---

## 10. Code Reuse

- Validation rules are defined once in `ValidationConstants` and used by `FormValidators`.
- `FormValidators` methods are reused across `RegisterScreen` and `ProfileCompletionScreen`.
- Theme colours and styles are defined once in `LoanPalTheme` and referenced by name throughout the UI.

---

## 11. Resource Disposal

- Dispose every `TextEditingController` and `ScrollController` in `dispose()`.
- Call `removeListener` on any `ChangeNotifier` in `dispose()`.
- Never hold a reference to a `BuildContext` across async gaps without a `mounted` check.

---

## 12. Form Validation

- Every form field that requires validation must have a `validator` attached.
- Validator functions conform to the `FormFieldValidator<String?>` signature (`String? Function(String?)`).
- Validators live in `FormValidators`; they reference `ValidationConstants` for limits and patterns.
- Client-side validation is a UX convenience. Authoritative rules are in Firestore Security Rules.

---

## 13. Firebase Access Patterns

- Firebase is accessed **only** through service classes (`AuthService`, `UserProfileService`). Screens and widgets must never import `firebase_auth` or `cloud_firestore` directly, with the exception of type annotations where the Flutter type system requires it (e.g. `User` in `ProfileCompletionScreen`).
- Use `SetOptions(merge: true)` when updating existing Firestore documents to avoid overwriting unrelated fields.
- Preserve server-generated fields (e.g. `createdAt`) on subsequent writes by reading the existing value before writing.

---

## 14. Authentication and Profile Handling

- The authenticated user's UID is always the Firestore document ID.
- Passwords and credentials are **never** written to Firestore.
- Clear the in-memory profile cache before signing out.
- Profile creation must be atomic from the user's perspective: the in-memory cache is pre-set optimistically, then cleared if the Firestore write fails.

---

## 15. Security Requirements

- Do not store any secret or credential in source code.
- `firebase_options.dart` contains client-identifiable Firebase configuration values (API keys, project IDs). These are **not** server secrets; they identify the Firebase project to Firebase SDKs. They should not be committed if the project is publicly hosted, but their exposure is not equivalent to a credential leak.
- Hardcoded client-side PINs or credentials must never be used. The developer settings dashboard is restricted to debug builds (`kDebugMode`) for local in-memory adjustments. Production administrative privileges must be authorized server-side via Firebase Authentication custom claims and Firestore Security Rules.
- Firestore Security Rules are the authoritative access-control mechanism. See [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md).

---

## 16. Unit and Widget Testing

- Unit tests cover: EMI calculation, `UserProfile` serialisation, `FormValidators`, `UserProfileService` cache behaviour.
- Widget tests cover: screen rendering, validation error display, password toggle, greeting fallback behaviour, sign-out dialog.
- Tests that depend on Firebase services use injected fakes or test only the in-memory behaviour (e.g. cache tests bypass Firestore by testing the cached-hit path).
- See [`TESTING.md`](TESTING.md) for full details.

---

## 17. Formatting and Linting

- Run `dart format lib test` before committing.
- Run `flutter analyze` and resolve all warnings and errors before committing. Do not suppress warnings with `// ignore:` unless there is a documented unavoidable reason.
- Lint configuration is in `analysis_options.yaml` (based on `flutter_lints`).

---

## 18. Git Workflow

- Feature work happens on branches named `feature/<short-description>` (e.g. `feature/firebase-authentication`).
- Do not commit directly to `main`.
- Do not commit build artefacts, IDE files, or generated platform files.
- See [`CONTRIBUTING.md`](../CONTRIBUTING.md) (if present) or this document's Git section below.

---

## 19. Code Review Expectations

- Changes must pass `flutter analyze` (zero warnings) and `flutter test` before review.
- Every meaningful behaviour change should have a corresponding test.
- Review the full `git diff` before opening a pull request to avoid unrelated changes.

---

## 20. Documentation Comments

### Dart Documentation Comments (`///`)

Use `///` for public API documentation on classes, public methods, and public properties. Follow the [Dart documentation comment conventions](https://dart.dev/effective-dart/documentation).

```dart
/// Validates a username field.
///
/// Returns `null` if the value is valid, or an error string otherwise.
static String? validateUsername(String? value) { ... }
```

### Project Explanatory Comments (`// INFO:`)

Use `// INFO:` for inline comments that explain **non-obvious** decisions, constraints, or behaviour. Do not use `// INFO:` to restate what the code already says clearly.

**Appropriate uses:**

```dart
// INFO: Tenure is always stored as months internally. Years/months is a
// display-only toggle; switching units does not reset the loan tenure.
int _tenureMonths = 180;
```

```dart
// INFO: Zero-interest case: EMI is a flat equal principal repayment.
if (monthlyRate == 0) { ... }
```

**Avoid this:**

```dart
// INFO: Set loading to true.   <-- restates the obvious; do not do this
_isLoading = true;
```

### Redundant Comments

Do not add comments that simply restate the code. Prefer self-explanatory names and straightforward implementations over comments.
