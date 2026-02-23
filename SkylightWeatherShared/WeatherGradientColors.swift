//
//  WeatherGradientColors.swift
//  SkylightWeatherShared
//

import SwiftUI

/// Shared gradient colors for weather condition codes.
/// Used by main app (WeatherDashboardView) and widget (WeatherWidgetEntryView).
public enum WeatherGradientColors {

    public static func colors(for conditionCode: Int) -> [Color] {
        switch conditionCode {
        case 1000:
            return [Color(red: 0.12, green: 0.44, blue: 0.84), Color(red: 0.11, green: 0.64, blue: 0.90)]
        case 1063, 1180...1201:
            return [Color(red: 0.16, green: 0.24, blue: 0.48), Color(red: 0.22, green: 0.39, blue: 0.64)]
        case 1066, 1210...1225:
            return [Color(red: 0.31, green: 0.47, blue: 0.65), Color(red: 0.58, green: 0.72, blue: 0.84)]
        default:
            return [Color(red: 0.20, green: 0.26, blue: 0.44), Color(red: 0.31, green: 0.43, blue: 0.66)]
        }
    }
}
