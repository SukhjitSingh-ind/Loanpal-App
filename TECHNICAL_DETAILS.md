# LoanPal — Technical Documentation (Legacy Notice)

> **NOTICE: This document is legacy documentation and has been superseded.**
>
> For the authoritative, current system architecture—including Firebase Authentication, Cloud Firestore profile persistence, recovery flows, security boundaries, and startup error handling—refer directly to:
>
> 📖 [**`docs/ARCHITECTURE.md`**](docs/ARCHITECTURE.md)
>
> For project coding conventions and comments standards, see [**`docs/CODING_STANDARDS.md`**](docs/CODING_STANDARDS.md).
> For engineering principles and state isolation, see [**`docs/ENGINEERING_BEST_PRACTICES.md`**](docs/ENGINEERING_BEST_PRACTICES.md).
> For Firebase configuration and security rules, see [**`docs/FIREBASE_SETUP.md`**](docs/FIREBASE_SETUP.md).

---

## Historical Overview (Pre-Firebase Baseline)

The sections below preserve the original technical design of the standalone EMI calculation engine for historical reference:

### 1. Mathematical Logic (`lib/logic/`)
- `emi_calculator.dart`: Core computational engine for financial amortization schedules and debt burden scaling.
- `app_config.dart`: Local in-memory singleton `ChangeNotifier` providing UI sliders boundary limits (e.g., tenure type and maximum caps).

### 2. User Interface (`lib/ui/`)
- `calculator_screen.dart`: Main interactive EMI calculator with reactive sliders and amortization breakdown.
- `theme.dart`: Material 3 design system tokens and color palette.
- `admin_dashboard_screen.dart`: Local developer testing utility for adjusting in-memory `AppConfig` limits during development.

### 3. Reusable Financial Widgets (`lib/widgets/`)
- `input_slider.dart`: Labelled numerical slider with live text editing.
- `amortization_table.dart`: Repayment schedule breakdown table.
- `burden_indicator.dart`: Color-coded debt burden visualization (Low / Moderate / High / Heavy).
- `principal_interest_bar.dart`: Visual ratio breakdown of principal against cumulative interest.
- `result_card.dart`: High-level EMI calculation summary card.
