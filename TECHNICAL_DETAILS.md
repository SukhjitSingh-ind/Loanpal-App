# LoanPal — Technical Documentation

## Overview
LoanPal is a Flutter-based EMI (Equated Monthly Installment) calculator application that features comprehensive amortization schedules and interactive financial burden indicators. The application is built with a strong focus on clean architecture, reusable UI components, and a custom design system based on Material 3 principles.

## Tech Stack
- **Framework:** Flutter (SDK: ^3.9.0)
- **Language:** Dart
- **Design System:** Custom Material 3 Implementation

## Project Structure
The project follows a modular, feature-based directory structure to separate concerns and improve maintainability:

```text
lib/
├── logic/        # Business logic and state management
├── ui/           # Screens and overarching theme configurations
├── utils/        # Helper functions and utilities
├── widgets/      # Reusable UI components
└── main.dart     # Application entry point
```

### 1. Business Logic (`lib/logic/`)
This directory contains the core mathematical and configuration logic of the application, keeping it decoupled from the UI.
- `emi_calculator.dart`: The core engine responsible for complex financial mathematics, including EMI calculation, total interest generation, and building the step-by-step amortization schedule.
- `app_config.dart`: Handles global application configurations and state.

### 2. User Interface (`lib/ui/`)
Contains the primary screens and the central theme definition.
- `calculator_screen.dart`: The main interactive screen where users input loan parameters and view immediate EMI results.
- `admin_dashboard_screen.dart`: A dashboard view, likely for overview statistics or configuration.
- `theme.dart`: Implements the `DESIGN.md` specifications, translating design tokens (colors, typography) into Flutter's `ThemeData`.

### 3. Reusable Widgets (`lib/widgets/`)
A collection of modular, custom-built UI components tailored for financial data presentation.
- `input_slider.dart`: A custom slider with dynamic track coloring that changes based on the "financial burden" level.
- `amortization_table.dart`: Renders the detailed, row-by-row breakdown of the loan repayment schedule.
- `burden_indicator.dart`: A visual indicator that translates the debt ratio into a semantic scale (Low/Moderate/High/Heavy).
- `principal_interest_bar.dart`: A visual bar chart/progress indicator showing the ratio of principal versus interest.
- `result_card.dart`: Elevated cards displaying high-level summaries (e.g., Total EMI).

### 4. Utilities (`lib/utils/`)
- `currency_utils.dart`: Helper functions for formatting numbers into readable currency strings (e.g., handling commas, decimal places).

## Design System & UI Architecture
The application strictly follows the specifications outlined in `DESIGN.md`, which defines a "Soft Utility" aesthetic.

### Typography
- **Font Family:** Inter
- **Hierarchy:** Strict usage of Display, Headline, Title, Body, and Label styles. Notably utilizes a `data-num` style with tabular lining for precise numerical alignment in tables.

### Color Semantics & Burden Scale
The app uses Deep Navy Blue as a primary trust-building color, paired with a semantic color scale for financial burden:
- **Low (Success):** Green (#168A5B)
- **Moderate:** Amber (#F4C430)
- **High:** Orange (#F28C28)
- **Heavy (Critical):** Red (#D64545)

### Layout & Shape
- **Grid:** 8px rhythm, fluid grid scaling from mobile (4-column) to desktop (12-column).
- **Shapes:** Heavily utilizes rounded corners (16px for standard cards, 8px for inputs) and pill shapes for controls to soften the UI.
- **Elevation:** Uses tonal layering (Level 0 to Level 2) with subtle 10% opacity shadows rather than harsh drop shadows.

## State Management
While the specific state management library (e.g., Provider, Riverpod, Bloc) is encapsulated within the structure, the separation of `lib/logic` from `lib/ui` ensures that state changes in `emi_calculator.dart` propagate efficiently to `calculator_screen.dart` and the associated `widgets`.

## Future Extensibility
- The modular nature of `lib/widgets` allows for easy addition of new financial calculators (e.g., SIP, FD calculators).
- The `theme.dart` centralizes all styling, meaning dark mode or brand pivots can be executed with minimal changes to the widget tree.
