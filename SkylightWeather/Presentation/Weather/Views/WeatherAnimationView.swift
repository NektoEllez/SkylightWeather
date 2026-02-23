//
//  WeatherAnimationView.swift
//  SkylightWeather
//

import SwiftUI

#if canImport(Lottie)
import Lottie
#endif

struct WeatherAnimationView: View {

    let conditionCode: Int
    let isDay: Bool

    init(conditionCode: Int, isDay: Bool = true) {
        self.conditionCode = conditionCode
        self.isDay = isDay
    }

    var body: some View {
        #if canImport(Lottie)
        lottieOrFallback
        #else
        sfSymbolView
        #endif
    }

    // MARK: - Lottie

    #if canImport(Lottie)
    @ViewBuilder
    private var lottieOrFallback: some View {
        if let name = animationName {
            LottieView(animation: .named(name))
                .playing(loopMode: .loop)
        } else {
            sfSymbolView
        }
    }
    #endif

    // MARK: - SF Symbol Fallback

    private var sfSymbolView: some View {
        Image(systemName: sfSymbol)
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(.white)
    }

    // MARK: - Animation Mapping (conditionCode + isDay → Lottie file name)

    private var animationName: String? {
        switch conditionCode {
        case 1000:
            return isDay ? "clear-day" : "clear-night"
        case 1003:
            return isDay ? "partly-cloudy-day" : "partly-cloudy-night"
        case 1006:
            return "cloudy"
        case 1009:
            return isDay ? "overcast-day" : "overcast-night"
        case 1030:
            return "mist"
        case 1063, 1180...1201:
            return isDay ? "partly-cloudy-day-rain" : "partly-cloudy-night-rain"
        case 1066, 1210...1225:
            return isDay ? "partly-cloudy-day-snow" : "partly-cloudy-night-snow"
        case 1069, 1249, 1252, 1261, 1264:
            return "sleet"
        case 1087, 1273...1276:
            return isDay ? "thunderstorms-day" : "thunderstorms-night"
        case 1279, 1282:
            return isDay ? "thunderstorms-day-snow" : "thunderstorms-night-snow"
        case 1114, 1117:
            return "wind"
        case 1135, 1147:
            return isDay ? "fog-day" : "fog-night"
        case 1150, 1153, 1168, 1171:
            return "drizzle"
        default:
            return isDay ? "overcast-day" : "overcast-night"
        }
    }

    private var sfSymbol: String {
        switch conditionCode {
        case 1000:
            return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1003, 1006, 1009:
            return "cloud.fill"
        case 1063, 1180...1201:
            return "cloud.rain.fill"
        case 1066, 1210...1225:
            return "snowflake"
        case 1087, 1273...1282:
            return "cloud.bolt.rain.fill"
        default:
            return "cloud.fill"
        }
    }
}

// MARK: - Preview

#Preview("Sun") {
    WeatherAnimationView(conditionCode: 1000, isDay: true)
        .frame(width: 64, height: 64)
}

#Preview("Rain") {
    WeatherAnimationView(conditionCode: 1180, isDay: true)
        .frame(width: 64, height: 64)
}

#Preview("Snow") {
    WeatherAnimationView(conditionCode: 1210, isDay: false)
        .frame(width: 64, height: 64)
}
