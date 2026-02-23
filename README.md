# Skylight Weather

iOS weather app (UIKit + SwiftUI) implemented fully programmatically (no Storyboards).

## Features

- Current weather for selected source (current location or city)
- Hourly forecast: remaining hours of today + all hours of tomorrow
- Daily forecast: up to 7 days
- Loading/error states with retry
- Invalid city handling with user-friendly warning
- Location permission request on start with Moscow fallback when denied/unavailable
- City search with suggestions (`MKLocalSearchCompleter`)
- Settings: theme, language, widget hint
- Home Screen widget (small/medium)
- Localization (`en`, `ru`)

## Architecture

Layered structure:

- `Presentation` (UIKit container + SwiftUI views, ViewModel, city search, settings)
- `Domain` (ViewData models, use case)
- `Data` (network client, DTOs, mappers, location, preferences)
- `Core` (localization, logging, runtime config, haptics)
- `SkylightWeatherShared` (App Group shared models/keys for widget)

Patterns and technologies:

- MVVM
- `@Observable`
- Swift Concurrency (`async/await`, `Task`, `async let`)
- `URLSession`
- `OSLog`

## Tech Stack

| Layer | Stack |
|-------|-------|
| UI | SwiftUI, UIKit, Lottie |
| State | `@Observable`, MVVM |
| Concurrency | Swift 6, async/await |
| Data | URLSession, WeatherAPI |
| Location | CoreLocation, MapKit (city suggestions) |
| Widget | WidgetKit |
| Storage | UserDefaults + App Group |

## Requirements

- iOS 17+
- Xcode (latest stable recommended)
- WeatherAPI key (set in Build Settings as `WEATHER_API_KEY`)

## Environment Configuration

`SkylightWeather` target uses build configurations as environments:

- `Debug` -> `dev`
- `Release` -> `prod`

Runtime values are injected through `Info.plist`:

- `APP_ENVIRONMENT`
- `WEATHER_API_SCHEME`
- `WEATHER_API_HOST`
- `WEATHER_API_KEY`

Where to configure:

1. Open target `SkylightWeather`
2. Go to `Build Settings`
3. Set `WEATHER_API_*` for `Debug` / `Release`

## Build & Run

```bash
open SkylightWeather.xcodeproj
```

In Xcode:

1. Select scheme `SkylightWeather`
2. Choose configuration (`Debug` or `Release`)
3. Run on iOS Simulator or device

Widget:

1. Install and run app once
2. Long press Home Screen
3. Tap `+`
4. Find `Skylight Weather`
5. Add widget

## Screenshots

| Light | Dark |
|---|---|
| ![Main Light](docs/screenshots/main.png) | ![Main Dark](docs/screenshots/main-dark.png) |

## Tests

Run tests:

```bash
xcodebuild -project SkylightWeather.xcodeproj -scheme SkylightWeather -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' test
```

## Permissions

- `NSLocationWhenInUseUsageDescription` is required to fetch weather by current location.

If denied/restricted, app automatically falls back to Moscow coordinates.
