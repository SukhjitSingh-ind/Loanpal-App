# LoanPal — Engineering Best Practices

This document provides actionable guidance for writing correct, maintainable Flutter code in the LoanPal project. It complements [`CODING_STANDARDS.md`](CODING_STANDARDS.md), which defines conventions and rules. This document explains *why* and *how*.

---

## 1. Writing Maintainable Flutter Code

**Extract, don't nest.**  
Deep widget nesting is the single biggest source of unreadable Flutter code. When `build` becomes hard to scan, extract named `Widget` methods or build private widget helpers, not anonymous closures.

**Keep `build` declarative.**  
`build` should describe what the UI looks like, not compute it. Move complex conditions and calculations into computed getters or local variables assigned before the `return`.

**Use `const` everywhere possible.**  
`const` constructors allow Flutter to skip widget reconciliation entirely. Mark widget constructors `const` and pass `const` to child widget constructors.

---

## 2. Separating Presentation and Business Logic

Services (`AuthService`, `UserProfileService`) and logic classes (`EMICalculationModel`) must have no dependency on Flutter widgets. They may depend on:

- Dart core libraries
- Firebase SDKs
- `package:flutter/foundation.dart` (e.g. `ChangeNotifier`, `debugPrint`)

They must not depend on:

- `package:flutter/widgets.dart`
- `package:flutter/material.dart`
- `BuildContext`

Screens coordinate between the user and services. They translate user gestures into service calls and translate service results into UI state.

---

## 3. Managing Asynchronous Operations

**Pattern for async event handlers:**

```dart
Future<void> _handleSomething() async {
  if (_isLoading) return;                     // prevent duplicate calls
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    await _someService.doSomething();
    if (mounted) {
      // success navigation or state update
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

Key points:
- `if (_isLoading) return` prevents duplicate concurrent calls.
- `finally` resets loading state even if an exception is thrown.
- `mounted` checks prevent `setState` calls after `dispose`.

**Do not** `await` in `build`. Use `FutureBuilder` or load data in `initState`.

---

## 4. Handling Errors

**Layers of error handling:**

1. **Service layer** — catches SDK-specific exceptions (e.g. `FirebaseAuthException`), maps them to domain-appropriate messages or typed exceptions, and rethrows.
2. **Screen layer** — catches exceptions thrown by services, shows user-visible feedback (SnackBar, dialog), and resets UI state.
3. **AuthGate** — catches `FutureBuilder` errors at the profile-loading level and presents a recoverable error screen.

**Do not swallow errors with empty catch blocks.** If you catch and do nothing, you hide bugs. At minimum, `debugPrint` the error with enough context to reproduce it.

**Do not expose raw SDK error messages to users.** Users should see plain language. Internal codes and stack traces belong in logs.

---

## 5. Validating User Input

- Validate locally with `Form` + `FormValidators` for instant feedback.
- Never rely solely on client-side validation for security. Firestore Security Rules enforce the same constraints server-side.
- Present validation errors inline (Flutter's `validator` function) rather than in dialogs.
- Trim whitespace before storing or sending user-provided strings. `AuthService` and `UserProfileService` trim all string inputs.

---

## 6. Managing Firebase Authentication State

`AuthGate` is the single source of truth for authentication routing. Do not check `FirebaseAuth.instance.currentUser` inside screens to make navigation decisions — that check is synchronous and does not react to state changes.

The pattern is:
1. Listen to `authStateChanges` stream in `AuthGate`.
2. Stream emits → `AuthGate` rebuilds → correct screen is shown.
3. Screens call service methods. They do not navigate based on auth state themselves.

**Always clear the profile cache before signing out.** Failing to do so leaves stale profile data in memory, which the next user to log in on the same device could see momentarily.

---

## 7. Persisting User Profiles

**Write order matters during registration:**

1. Create the Firebase Auth account.
2. Pre-set the cache (so the next `getUserProfile` call returns immediately without a Firestore read).
3. Write to Firestore.
4. If step 3 fails, clear the cache and throw `ProfileCreationException`.

**Why pre-cache?** Firebase Auth emits an `authStateChanges` event immediately after account creation. If `AuthGate`'s profile `FutureBuilder` runs before the Firestore write completes, it would find no document and incorrectly show `ProfileCompletionScreen`. The cache prevents this race.

**Cache Ownership and State Isolation:**
Avoid static mutable fields on instantiable classes. `UserProfileService` is implemented as an explicit singleton with an instance-level cache (`_cachedProfile`). This guarantees:
- Clear ownership bounded by the service instance lifecycle.
- Isolated test instances when injecting custom mock `firestore` instances.
- Cache queries verify `_cachedProfile.uid == uid`, preventing cross-account contamination when switching users.

**`SetOptions(merge: true)` on all profile updates** preserves server-side fields (e.g. `createdAt`) that the client did not include in the write.

---

## 8. Protecting User Data

- User documents in Firestore are readable and writable only by the document owner (enforced by Security Rules).
- `uid` and `createdAt` are immutable once set (enforced by Security Rules).
- No password or credential is ever written to Firestore or logged.
- Client-side PINs must never be used for authorization. The developer settings screen is restricted to debug builds (`kDebugMode`) for testing in-memory calculator limits. Privileged operations require server-side Firebase Authentication custom claims.

---

## 9. Writing Meaningful Automated Tests

**What to test:**

- Domain logic (`EMICalculationModel`) with precise numerical assertions and edge-case inputs.
- Serialisation and deserialization (`UserProfile.toMap`, `UserProfile.fromMap`) with all field variants including missing/null fields.
- Form validators with boundary values (empty, too short, too long, invalid characters, valid examples).
- UI rendering: does the correct screen render? Are required widgets present?
- UI validation: does tapping submit with empty fields show the right error messages?
- UI state: does a toggle or button interaction produce the expected state change?

**What not to test:**

- Firestore write/read round trips in widget tests (they require the Firebase Emulator Suite or mocking).
- Firebase Auth flows end-to-end (these are integration tests that require a running Firebase project or emulator).

---

## 10. Avoiding Unnecessary Dependencies and Abstractions

Before adding a dependency:
1. Can the standard library or Flutter SDK do it?
2. Is the dependency actively maintained?
3. Does it pull in incompatible transitive dependencies?

Before adding an abstraction:
1. Do you have at least two concrete use-cases for it?
2. Does it reduce duplication, or does it just add indirection?

---

## 11. Reviewing Changes Before Merging

Checklist before opening a pull request:

- [ ] `flutter analyze` passes with zero issues.
- [ ] `flutter test` passes with zero failures.
- [ ] `dart format lib test` shows no changes (code is already formatted).
- [ ] `git diff` has been reviewed — no unrelated changes are included.
- [ ] New behaviour has at least one test.
- [ ] Documentation is updated if architecture, public APIs, or setup steps changed.

---

## 12. Investigating and Fixing Bugs

1. Reproduce the bug reliably before touching code.
2. Identify the layer where the bug originates (UI, service, model, Firestore rules).
3. Write a failing test that demonstrates the bug.
4. Fix the code so the test passes.
5. Verify that existing tests still pass.

---

## 13. Avoiding Fragile Workarounds

If a workaround is genuinely necessary (e.g. a platform limitation, a timing issue), document it with a `// INFO:` comment explaining:
- What the underlying problem is.
- Why this approach was chosen over alternatives.
- Under what conditions it may stop working.

Do not silently swallow errors to make tests pass. If a test is flaky due to a real timing issue, address the root cause.

---

## 14. Keeping Dependencies and Platform Configuration Maintainable

- `lib/firebase_options.dart` is generated by the FlutterFire CLI. Do not edit it manually.
- Platform registration files (`android/app/google-services.json`, `ios/GoogleService-Info.plist`) are generated during `flutterfire configure`. Do not commit real Firebase service-account keys.
- Generated plugin registrant files (`generated_plugin_registrant.cc`, `generated_plugins.cmake`) are managed by `flutter pub get`. Do not edit them manually.
- Run `flutter pub upgrade` periodically and verify tests still pass after any package version bump.
