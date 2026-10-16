# LoanPal

LoanPal is a Flutter mobile application that provides an interactive EMI (Equated Monthly Installment) calculator with amortization schedules, financial burden visualisation, and full Firebase Authentication with Firestore-backed user profiles.

---

## Features

- **EMI Calculator** — Computes monthly payment, total interest, and total payable amount in real time.
- **Amortization Schedule** — Full month-by-month breakdown of principal, interest, and outstanding balance.
- **Financial Burden Indicator** — Colour-coded semantic scale (Low / Moderate / High / Heavy) derived from the interest-to-principal ratio.
- **Firebase Authentication** — Email/password registration and login with profile persistence.
- **Profile Recovery** — Authenticated users with missing Firestore profiles are guided through a one-time completion screen rather than being locked out.
- **Admin Dashboard** — Accessible via a long-press PIN to adjust global calculator limits (principal cap, APR cap, and allowed tenure units).
- **Responsive Layout** — Adapts from a single-column mobile layout to a two-column desktop/tablet layout at 800 px.

---

## Technology Stack

| Concern | Library / Tool |
|---|---|
| Framework | Flutter (SDK `^3.9.0`) |
| Language | Dart |
| Authentication | `firebase_auth ^6.7.0` |
| Database | `cloud_firestore ^6.10.0` |
| Firebase bootstrap | `firebase_core ^4.15.0` |
| Design system | Custom Material 3 |

---

## Prerequisites

- **Flutter SDK** ≥ 3.27.0 (matches the resolved lockfile)
- **Dart SDK** `^3.9.0`
- A **Firebase project** with Email/Password authentication enabled and Cloud Firestore in production mode
- **FlutterFire CLI** (`dart pub global activate flutterfire_cli`) for generating `firebase_options.dart`
- An Android or iOS device / emulator, or a supported desktop target (Windows, macOS, Linux)

> The project **does not** target the Flutter Web target for Firebase Auth because some Firebase Auth web flows differ from native. Web is present in the project skeleton but is not a tested deployment target.

---

## Setup

### 1. Clone and install dependencies

```bash
flutter pub get
```

### 2. Configure Firebase

See [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md) for the complete setup guide.

In brief:

1. Create a Firebase project at <https://console.firebase.google.com>.
2. Enable **Email/Password** authentication.
3. Create a **Cloud Firestore** database in production mode.
4. Run `flutterfire configure` from the project root to generate `lib/firebase_options.dart`.
5. Deploy `firestore.rules` from the project root.

### 3. Run the application

```bash
flutter run
```

For a specific target:

```bash
flutter run -d android
flutter run -d windows
```

---

## Running Tests

```bash
flutter test
```

See [`docs/TESTING.md`](docs/TESTING.md) for details on what is tested and how to add new tests.

---

## Documentation Index

| Document | Purpose |
|---|---|
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Application structure, flows, and component responsibilities |
| [`docs/CODING_STANDARDS.md`](docs/CODING_STANDARDS.md) | Dart/Flutter conventions and project-specific rules |
| [`docs/ENGINEERING_BEST_PRACTICES.md`](docs/ENGINEERING_BEST_PRACTICES.md) | Practical guidance for maintainable Flutter development |
| [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md) | Firebase project configuration and security rules |
| [`docs/TESTING.md`](docs/TESTING.md) | Testing strategy, how to run tests, and how to add new ones |
| [`DESIGN.md`](DESIGN.md) | Visual design system tokens and aesthetic guidelines |
| [`TECHNICAL_DETAILS.md`](TECHNICAL_DETAILS.md) | Legacy technical overview (superseded by `docs/ARCHITECTURE.md`) |
