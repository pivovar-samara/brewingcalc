# BrewingCalc

A modern iOS brewing calculator app for homebrewers. Built with SwiftUI for iOS 26+, supporting both iPhone and iPad with adaptive `NavigationSplitView` layout and Liquid Glass design.

## Features

- **Unit Conversions** — Volume (litres, gallons, pints, fl oz), Weight (kg, g, oz, lb), Temperature (C, F, K)
- **Gravity Conversion** — Plato to Specific Gravity (SG) and back
- **ABV Calculator (Table)** — Alcohol by volume via 60-point interpolation lookup table
- **ABV Calculator (Formula)** — Temperature-dependent polynomial ABV calculation
- **Calorie Calculator** — Beer calories from original/final gravity and volume
- **IBU Calculator** — International Bitterness Units using Glenn Tinseth formula (up to 5 hops)
- **Refractometer (Brix)** — Brix to gravity conversion with correction factor support

## Requirements

- iOS 26.0+
- Xcode 26+
- Swift 6

## Building

```bash
open BrewCalc.xcodeproj
```

Or from the command line:

```bash
xcodebuild -scheme BrewCalc -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Running Tests

```bash
xcodebuild test -scheme BrewCalcTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Architecture

- **SwiftUI** with `NavigationSplitView` for adaptive iPhone/iPad layout
- **@Observable** view models with `@MainActor` isolation
- **Pure function services** for all brewing calculations
- **Value types** throughout (structs, enums)
- **Swift 6** strict concurrency
- **Zero external dependencies**

## Localization

Available in English and Russian.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
