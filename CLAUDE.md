# BrewCalc - Project Conventions

## Overview
BrewingCalc is an iOS 26+ brewing calculator app built with SwiftUI. It provides unit conversions, ABV calculations, IBU (bitterness), calorie estimation, and refractometer (Brix) calculations for homebrewers.

## Architecture
- **SwiftUI** with `@Observable` view models and `NavigationSplitView` for iPhone+iPad
- **Services layer**: Pure static functions for all brewing calculations (no side effects)
- **Models**: Value types (structs) conforming to `Sendable`, `Identifiable`, `Equatable`
- **No persistence**: All data is in-memory, resets on launch
- **No external dependencies**: Pure Apple frameworks only

## Build & Test
```bash
xcodebuild -scheme BrewCalc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcodebuild test -scheme BrewCalcTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Code Style
- Swift 6 with strict concurrency (`Sendable` everywhere, `@MainActor` on view models)
- No force unwraps (`!`) — use `guard let` or `if let`
- No force casts (`as!`) — use `as?` with optional binding
- Value types (structs) over reference types (classes) unless `@Observable` requires class
- Caseless enums as namespaces for static utility functions
- `String(localized:)` for localization (keys in `Localizable.strings`)

## Folder Structure
```
BrewCalc/
  App/           — @main entry point
  Models/        — Calculator, CalculatorInput, CalculatorCategory
  Services/      — Pure calculation functions (UnitConverter, IBU, ABV, etc.)
  ViewModels/    — @Observable @MainActor view models
  Views/         — SwiftUI views
  Components/    — Reusable UI components (NumberInputField, etc.)
  Theme/         — Colors, typography
  Helpers/       — Localization utilities
  Resources/     — Localizable.strings, HTML instruction files
```

## Localization
- English and Russian via `Localizable.strings`
- Instruction HTML files selected by locale at runtime
- Use `String(localized:)` API, helper `l()` wraps `NSLocalizedString`

## Key Business Logic (do not modify formulas)
- **IBU**: Glenn Tinseth formula in `IBUCalculator`
- **ABV Table**: 60-point SG/ABV interpolation in `ABVCalculator`
- **ABV Formula**: Temperature-dependent polynomial in `ABVCalculator`
- **Calories**: Real Extract (RE) formula in `CalorieCalculator`
- **Brix**: Refractometer conversions in `BrixCalculator`
- **Gravity**: Plato <-> SG in `UnitConverter.Gravity`
