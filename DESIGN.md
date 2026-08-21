---
name: LoanPal
colors:
  surface: '#f7f9fc'
  surface-dim: '#d8dadd'
  surface-bright: '#f7f9fc'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f7'
  surface-container: '#eceef1'
  surface-container-high: '#e6e8eb'
  surface-container-highest: '#e0e3e6'
  on-surface: '#191c1e'
  on-surface-variant: '#43474f'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f4'
  outline: '#737780'
  outline-variant: '#c3c6d1'
  surface-tint: '#3c5f95'
  primary: '#002956'
  on-primary: '#ffffff'
  primary-container: '#173f73'
  on-primary-container: '#8aace6'
  inverse-primary: '#a9c7ff'
  secondary: '#006b58'
  on-secondary: '#ffffff'
  secondary-container: '#93f5d9'
  on-secondary-container: '#00725d'
  tertiary: '#002855'
  on-tertiary: '#ffffff'
  tertiary-container: '#003e7c'
  on-tertiary-container: '#7fabf4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#a9c7ff'
  on-primary-fixed: '#001b3d'
  on-primary-fixed-variant: '#21477b'
  secondary-fixed: '#93f5d9'
  secondary-fixed-dim: '#77d8bd'
  on-secondary-fixed: '#002019'
  on-secondary-fixed-variant: '#005141'
  tertiary-fixed: '#d6e3ff'
  tertiary-fixed-dim: '#a9c7ff'
  on-tertiary-fixed: '#001b3d'
  on-tertiary-fixed-variant: '#074688'
  background: '#f7f9fc'
  on-background: '#191c1e'
  surface-variant: '#e0e3e6'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  data-num:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-padding: 24px
  gutter: 16px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
---

## Brand & Style
The design system for this financial utility focuses on clarity, reliability, and emotional calm. Given the potential stress associated with debt management, the UI adopts a **Corporate / Modern** style heavily influenced by Material 3 principles. It prioritizes functional minimalism over decorative flair, using whitespace and a structured tonal system to make complex financial data feel manageable.

The aesthetic is defined by "Soft Utility"—combining the precision of a professional banking tool with the approachable friendliness of a personal assistant. Surfaces are layered logically to guide the user's focus, while the color system provides immediate, intuitive feedback on loan health and financial burden levels.

## Colors
The palette is anchored by **Deep Navy Blue**, signifying institutional trust. This is balanced by a **Teal/Green** secondary color used for primary actions and growth-oriented indicators. 

A specific semantic scale is used to represent "Financial Burden":
- **Low (Success):** Green (#168A5B) for healthy ratios.
- **Moderate:** Amber (#F4C430) for caution.
- **High:** Orange (#F28C28) for increasing pressure.
- **Heavy:** Red (#D64545) for critical intervention.

The background uses a soft, off-white blue-gray to reduce eye strain and provide a clean canvas for the tonal surface layers.

## Typography
This design system utilizes **Inter** for its exceptional legibility and neutral, systematic tone. A strong hierarchy is established through weight and scale. 

- **Numerical Data:** Financial values utilize `data-num` with tabular lining to ensure numbers align vertically in tables and lists, making comparisons easier.
- **Display Styles:** Reserved for high-level summaries (e.g., "Total Debt" or "Monthly Savings").
- **Labels:** Uppercase with slight tracking to differentiate metadata from body content.

## Layout & Spacing
The layout follows a **Fluid Grid** system based on an 8px square rhythm.
- **Mobile:** 4-column grid with 16px margins and 16px gutters.
- **Tablet/Desktop:** 12-column grid with a max-width of 1200px and 24px margins.

Spacing is categorized into "Stacks" (vertical) and "Inlines" (horizontal). Use `stack-lg` to separate distinct logical sections or cards, and `stack-sm` for related label-value pairs. Large data dashboards should utilize the full width of the screen to prevent information density issues.

## Elevation & Depth
Depth is communicated through **Tonal Layers** rather than heavy shadows. The background is the lowest level (Level 0).
- **Level 1 (Cards):** Slightly elevated using a very soft, diffused shadow (10% opacity) or a subtle 1px border in a slightly darker neutral tone.
- **Level 2 (Active States/Dialogs):** Increased shadow spread and a pure white background to pop against the blue-gray canvas.

Shadows should inherit a tiny hint of the primary navy (#173F73) to maintain color harmony across the interface.

## Shapes
In alignment with Material 3, the shape language is distinctly rounded to project a "softened professional" vibe.
- **Standard Cards:** 16px corner radius (`rounded-lg`).
- **Input Fields/Small Buttons:** 8px corner radius.
- **Controls:** Pill-shaped (fully rounded) for segmented buttons, chips, and toggles to differentiate them from static content containers.
- **Progress Bars:** Fully rounded ends to represent fluidity and progress.

## Components
- **Cards:** White or very light gray background, 16px radius. Used for loan summaries, amortization schedules, and calculators.
- **Sliders:** Utilize a thick track and a prominent pill-shaped thumb. The track should change color dynamically (Green to Red) based on the "Burden" scale as the user adjusts values.
- **Segmented Buttons:** Pill-shaped container with a subtle tonal background; the active segment uses the Primary Navy color with white text.
- **Data Tables:** Clean, no vertical borders. Use horizontal rules in a very light neutral. Row height is generous (min 48px) to accommodate touch targets and legibility.
- **Input Fields:** Outlined style with 8px radius. Label floats to the top border on focus.
- **Action Buttons:** Primary actions are filled (Teal/Green). Secondary actions use the Ghost (outline) or Tonal style.
