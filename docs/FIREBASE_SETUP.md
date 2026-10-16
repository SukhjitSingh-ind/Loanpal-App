# LoanPal — Firebase Setup Guide

This document explains how to configure Firebase for LoanPal and how to understand the Firestore Security Rules.

---

## 1. Required Firebase Services

| Service | Purpose |
|---|---|
| Firebase Authentication | Email/password sign-in and identity management |
| Cloud Firestore | User profile persistence |

No other Firebase services (Storage, Functions, Hosting, etc.) are required for the current feature set.

---

## 2. Creating a Firebase Project

1. Go to <https://console.firebase.google.com> and click **Add project**.
2. Choose a project name (e.g. `loanpal-prod`).
3. Disable Google Analytics if you do not need it.
4. Click **Create project**.

---

## 3. Enabling Email/Password Authentication

1. In the Firebase Console, open your project.
2. Navigate to **Authentication → Sign-in method**.
3. Click **Email/Password** and enable the **Email/Password** provider.
4. Leave **Email link (passwordless sign-in)** disabled unless you add support for it.
5. Click **Save**.

---

## 4. Creating Cloud Firestore

1. Navigate to **Firestore Database → Create database**.
2. Choose **Start in production mode** (not test mode).
3. Select a Firestore location close to your primary user base.
4. Click **Enable**.

Production mode starts with a deny-all rule. You will deploy the project's Security Rules in a later step.

---

## 5. FlutterFire CLI Setup

Install the FlutterFire CLI if you have not already:

```bash
dart pub global activate flutterfire_cli
```

Ensure `~/.pub-cache/bin` (or `%APPDATA%\Pub\Cache\bin` on Windows) is in your `PATH`.

Also ensure the Firebase CLI is installed and you are logged in:

```bash
npm install -g firebase-tools
firebase login
```

---

## 6. Registering Platforms and Generating Configuration

From the project root, run:

```bash
flutterfire configure
```

The CLI will:

1. Ask which Firebase project to use.
2. Ask which platforms to support.
3. Generate `lib/firebase_options.dart` with per-platform configuration.
4. Register each platform (Android, iOS, etc.) in the Firebase project if not already registered.
5. For Android, download and save `android/app/google-services.json`.
6. For iOS/macOS, download and save `ios/Runner/GoogleService-Info.plist`.

> **Important:** Never commit real Firebase service-account keys or admin SDK credentials to source control. The values in `firebase_options.dart` and `google-services.json` are client-facing identifiers, not server secrets, but you should not publish them in a public repository without understanding the implications.

---

## 7. Required Dependencies

The following packages are already declared in `pubspec.yaml`:

```yaml
dependencies:
  cloud_firestore: ^6.10.0
  firebase_auth: ^6.7.0
  firebase_core: ^4.15.0
```

Install them:

```bash
flutter pub get
```

---

## 8. Firebase Initialization

Firebase is initialized in `lib/main.dart` before `runApp`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }
  runApp(const LoanPalApp());
}
```

Initialization errors are caught and logged rather than crashing the app, so the UI can display a meaningful error message. The app will not function without a successful Firebase init; the catch block is a safety net, not a means of ignoring failures.

---

## 9. Firestore Collection and Document Structure

Collection: `users`  
Document ID: Firebase Authentication UID

Example document at `/users/abc123`:

```json
{
  "uid": "abc123",
  "username": "johndoe",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "createdAt": "2026-10-12T10:00:00Z"
}
```

Field constraints (enforced by both client validation and Security Rules):

| Field | Type | Constraints |
|---|---|---|
| `uid` | string | Equals Firebase Auth UID; immutable after creation |
| `username` | string | 3–20 chars, `[a-zA-Z0-9_]` only |
| `firstName` | string | 2–50 chars, Unicode letters/hyphens/apostrophes |
| `lastName` | string | 2–50 chars, Unicode letters/hyphens/apostrophes |
| `email` | string | >3 chars (basic length check in rules) |
| `createdAt` | timestamp | Server timestamp; immutable after creation |

---

## 10. Firestore Security Rules

The project's Security Rules are in `firestore.rules` at the project root. They:

- Allow users to **read** only their own document (`/users/{userId}` where `userId == request.auth.uid`).
- Allow users to **create** their own document only if:
  - They are authenticated and own the document (`request.auth.uid == userId`).
  - The document contains all required fields with valid types and lengths.
  - The `uid` field in the document equals `request.auth.uid`.
  - `createdAt` is a timestamp.
- Allow users to **update** their own document only if:
  - All create conditions are met.
  - `uid` in the written data equals `uid` in the existing document (immutable).
  - `createdAt` in the written data equals `createdAt` in the existing document (immutable).
- **Delete** is denied for all clients.
- All other document paths are denied.

### Deploying Security Rules

Install and use the Firebase CLI:

```bash
firebase deploy --only firestore:rules
```

Or deploy from the Firebase Console: **Firestore → Rules → Edit rules → Publish**.

> **Note:** The rules file at `firestore.rules` in this repository has not been verified as deployed to the live Firebase project. Always confirm deployed rules in the Firebase Console match the file in source control.

---

## 11. Supported Platforms

The project has been tested on **Android** and **Windows**. Generated plugin registrant files exist for macOS (`macos/Flutter/GeneratedPluginRegistrant.swift`) and Windows (`windows/flutter/generated_plugin_registrant.cc`).

Web and Linux targets exist in the project skeleton but are not verified deployment targets for the Firebase Auth feature.

---

## 12. Local Development and Testing

The project does **not** currently use the Firebase Emulator Suite. All tests that exercise the `UserProfileService` cache work in memory without a real Firestore connection. Tests that would require real Firestore calls (e.g. `getUserProfile` with a cache miss) are not present in the test suite.

If you add tests that require Firestore, configure the Firebase Emulator Suite:

```bash
firebase emulators:start --only auth,firestore
```

Then configure the test to connect to the emulator before the first Firebase call:

```dart
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

---

## 13. Common Configuration Problems

| Problem | Likely Cause | Fix |
|---|---|---|
| `[core/no-app]` crash on startup | `Firebase.initializeApp` not called, or `firebase_options.dart` missing | Run `flutterfire configure` |
| `[auth/operation-not-allowed]` on sign-in | Email/Password provider not enabled | Enable it in Firebase Console → Authentication |
| Firestore permission denied | Security Rules deployed deny the operation, or user is not authenticated | Check rules; check auth state |
| `google-services.json` missing | `flutterfire configure` not run for Android | Run `flutterfire configure` |
| Build fails on Windows due to missing plugin | Plugin registrant not updated | Run `flutter pub get` |

---

## 14. Sensitive Configuration and Credential Handling

- **Never** commit Firebase Admin SDK service-account JSON files.
- **Never** commit `GOOGLE_APPLICATION_CREDENTIALS` or any server-side secret.
- `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` contain client-identifiable configuration values. They identify the project to Firebase SDKs but are not equivalent to server credentials. They should be excluded from public repositories or protected with Firebase App Check if the project is publicly hosted.
- Add Firebase client config files to `.gitignore` if the repository is public.

---

## 15. Administrator Custom Claims (Backend Configuration)

If production administrator privileges or shared settings are implemented, administrator authorization must be managed through **Firebase Authentication Custom Claims** issued by a trusted backend environment or Firebase Cloud Function, rather than client-side PINs or flags.

### Assigning Custom Claims (Server-side Admin SDK)

A trusted administrative environment can assign the `admin` claim using the Firebase Admin SDK:

```javascript
// Trusted server or Cloud Function environment only
const admin = require('firebase-admin');

async function grantAdminRole(uid) {
  await admin.auth().setCustomUserClaims(uid, { admin: true });
}
```

### Verifying Claims in Firestore Security Rules

Firestore Security Rules verify the token claim authoritatively on every database request:

```javascript
match /admin_settings/{settingId} {
  allow read, write: if request.auth != null && request.auth.token.admin == true;
}
```
