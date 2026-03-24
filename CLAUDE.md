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
xcodebuild test -scheme BrewCalc -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
> There is only one scheme (`BrewCalc`); `BrewCalcTests` is a target, not a scheme.

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

## Adding New Test Files
The project uses Xcode file-system synchronization (`PBXFileSystemSynchronizedBuildFileExceptionSet`).
Simply creating a `.swift` file under `BrewCalcTests/` is **not enough** — it will be compiled into the
`BrewCalc` app target by default and fail. Every new test file must be added to **two** exception sets
inside `BrewCalc.xcodeproj/project.pbxproj`:

1. **"Exceptions for 'BrewCalcTests' folder in 'BrewCalc' target"** — add the path to exclude it from the app.
2. **"Exceptions for 'BrewCalcTests' folder in 'BrewCalcTests' target"** — add the path to include it in the test target.

Both lists use relative paths from the `BrewCalcTests/` root (e.g. `ViewModels/MyTests.swift`).

## Analytics Infrastructure
- `AnalyticsService` protocol + `NoOpAnalyticsService` stub in `Services/Analytics/`
- `FirebaseAnalyticsService` is only instantiated in `BrewCalcApp.init`; unit/UI test runs use `NoOpAnalyticsService` (detected via `XCTestConfigurationFilePath` env var or `-RunningTests` launch arg)
- Firebase keys come from `Bundle.main.infoDictionary` (populated by CI script), **not** from `GoogleService-Info.plist`
- For analytics unit tests use `SpyAnalyticsService` (a `final class` with `@unchecked Sendable`) defined in `BrewCalcTests/ViewModels/AppViewModelTests.swift`; it is visible to all other test files in the same module
- `CalculatorDetailViewModel` accepts a `debounceDelay: Duration` parameter (default `.seconds(1.5)`) to allow fast debounce tests

## Key Business Logic (do not modify formulas)
- **IBU**: Glenn Tinseth formula in `IBUCalculator`
- **ABV Table**: 60-point SG/ABV interpolation in `ABVCalculator`
- **ABV Formula**: Temperature-dependent polynomial in `ABVCalculator`
- **Calories**: Real Extract (RE) formula in `CalorieCalculator`
- **Brix**: Refractometer conversions in `BrixCalculator`
- **Gravity**: Plato <-> SG in `UnitConverter.Gravity`
