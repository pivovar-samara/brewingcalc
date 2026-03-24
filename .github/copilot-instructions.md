# BrewCalc — Copilot Instructions

Trust these instructions. Only search the codebase if specific information is missing or appears incorrect.

## Project Summary

BrewingCalc is an iOS 26+ homebrewing calculator app (~34 Swift files, ~2,910 LOC). It provides gravity/ABV/IBU/calorie/Brix/unit-conversion calculators. Stack: SwiftUI, Swift 6 strict concurrency, `@Observable` view models, zero external dependencies (except Firebase Analytics/Crashlytics which is analytics-only).

**Requirements:** Xcode 26+, iOS 26.0+ deployment target, Swift 6.

## Build & Test

**Build (always use this exact command):**
```bash
xcodebuild -scheme BrewCalc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

**Run unit tests (always use `-only-testing:BrewCalcTests`):**
```bash
xcodebuild test -scheme BrewCalc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:BrewCalcTests
```

- The only scheme is `BrewCalc`. `BrewCalcTests` and `BrewCalcUITests` are targets, not schemes — do not use them as the `-scheme` value.
- No `npm install`, no `pod install`, no `swift package resolve` — there are no external package dependencies to bootstrap.
- `Configs/Secrets.xcconfig` is gitignored. For local builds it may be absent or empty; Firebase is not initialized when running tests (app detects `XCTestConfigurationFilePath` env var or `-RunningTests` launch arg and uses `NoOpAnalyticsService`).

## Adding New Test Files

The project uses Xcode file-system synchronization (`PBXFileSystemSynchronizedBuildFileExceptionSet`). Simply creating a `.swift` file under `BrewCalcTests/` will compile it into the **app** target and fail. Every new test file **must** be added to **two** exception sets inside `BrewCalc.xcodeproj/project.pbxproj`:

1. Exceptions for `BrewCalcTests` folder in the **`BrewCalc`** target — to exclude it from the app.
2. Exceptions for `BrewCalcTests` folder in the **`BrewCalcTests`** target — to include it in tests.

Both lists use paths relative to `BrewCalcTests/` (e.g. `ViewModels/MyTests.swift`). Search `project.pbxproj` for `BrewCalcTests` to find these sections.

## Code Style Rules (enforced — builds fail if violated)

- Swift 6 strict concurrency: all view models are `@Observable @MainActor final class`; models are `struct` + `Sendable`
- No force unwraps (`!`) — use `guard let` / `if let`
- No force casts (`as!`) — use `as?`
- All user-facing strings use `String(localized:)` with keys in `BrewCalc/Resources/en.lproj/Localizable.strings` and `ru.lproj/Localizable.strings`
- Caseless enums as namespaces for static utility functions (see all `Services/` files)

## Architecture & Key File Locations

```
BrewCalc/App/BrewCalcApp.swift              — @main entry; Firebase init; analytics wiring
BrewCalc/Models/Calculator.swift            — all 9 calculator model structs + BrewCalculator protocol
BrewCalc/Models/CalculatorCategory.swift    — CalculatorCategory; allCategories() factory
BrewCalc/ViewModels/AppViewModel.swift      — category/selection state; analytics for open events
BrewCalc/ViewModels/CalculatorDetailViewModel.swift — inputs, calculation, persistence, debounced analytics
BrewCalc/Services/Analytics/               — AnalyticsService protocol, NoOpAnalyticsService, FirebaseAnalyticsService
BrewCalc/Services/ABVCalculator.swift       — table (60-pt interpolation) + formula (polynomial)
BrewCalc/Services/IBUCalculator.swift       — Glenn Tinseth formula (DO NOT modify)
BrewCalc/Services/BrixCalculator.swift      — refractometer conversions
BrewCalc/Services/CalorieCalculator.swift   — Real Extract (RE) formula
BrewCalc/Services/UnitConverter.swift       — Gravity/Volume/Weight/Temperature
BrewCalc/Services/CalculatorPersistence.swift — UserDefaults save/restore for 9 calculator types
BrewCalc/Helpers/Localization.swift         — l() helper wrapping NSLocalizedString
BrewCalc/Theme/BrewCalcTheme.swift          — colors, typography
BrewCalcTests/ViewModels/AppViewModelTests.swift — defines SpyAnalyticsService (visible to all test files)
ci_scripts/ci_pre_xcodebuild.sh             — Xcode Cloud pre-build: generates Configs/Secrets.xcconfig
Configs/Secrets.xcconfig.example            — template for local Firebase config
CITests.xctestplan                          — unit tests only (used in CI)
FullTests.xctestplan                        — unit + UI tests
```

## Analytics Testing Helpers

- `SpyAnalyticsService` is defined in `BrewCalcTests/ViewModels/AppViewModelTests.swift` and is visible to all test files in the module — do not redefine it.
- `CalculatorDetailViewModel` accepts `debounceDelay: Duration` (default `.seconds(1.5)`) — pass `.zero` or `.milliseconds(1)` in tests to avoid async waits.

## Business Logic — Do Not Modify Without Justification

These formulas are well-established; modifying them requires updated test cases and source references:
- IBU: Glenn Tinseth formula (`IBUCalculator.swift`)
- ABV Table: 60-point SG/ABV interpolation (`ABVCalculator.swift`)
- ABV Formula: temperature-dependent polynomial (`ABVCalculator.swift`)
- Calories: Real Extract formula (`CalorieCalculator.swift`)
- Brix: refractometer conversions (`BrixCalculator.swift`)
- Gravity: Plato ↔ SG (`UnitConverter.Gravity`)

## CI / Validation

No GitHub Actions workflows exist. CI runs via Xcode Cloud using `CITests.xctestplan`. To replicate locally, run the unit test command above. All tests must pass before submitting a PR. The test framework is Apple's `Testing` framework (not XCTest) — use `@Test`, `#expect`, `#require`.
