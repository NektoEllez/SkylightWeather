# Skylight Weather

Weather app for iOS. Current conditions, hourly forecast (24h), 7-day forecast. Home screen widget.

## Tech Stack

| Layer | Stack |
|-------|-------|
| UI | SwiftUI, UIKit (navigation), Lottie |
| State | `@Observable`, MVVM |
| Concurrency | Swift 6, async/await |
| Data | URLSession, WeatherAPI |
| Location | CoreLocation |
| Extensions | WidgetKit |
| Storage | UserDefaults (App Group) |

## Requirements

- iOS 17+
- Xcode 15+
- WeatherAPI key in Build Settings (`WEATHER_API_KEY`)

## Environments

- `Debug` -> `dev` (`APP_ENVIRONMENT=dev`)
- `Release` -> `prod` (`APP_ENVIRONMENT=prod`)

Environment values are injected into `Info.plist` and read at runtime:
- `APP_ENVIRONMENT`
- `WEATHER_API_SCHEME`
- `WEATHER_API_HOST`
- `WEATHER_API_KEY`

Where to change:
- Target `SkylightWeather` -> `Build Settings`
- Update `WEATHER_API_*` per configuration (`Debug` / `Release`)

## Run

```bash
open SkylightWeather.xcodeproj
```

Select scheme `SkylightWeather` → Run. For widget: add via Home Screen long-press.
