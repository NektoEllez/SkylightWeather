//
//  DailyForecastView.swift
//  SkylightWeather
//

import SwiftUI

struct DailyForecastView: View {

    let days: [DailyViewData]
    private var visibleDays: [DailyViewData] { Array(days.prefix(7)) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(visibleDays.enumerated()), id: \.element.id) { index, day in
                    dayRow(day)
                    if index < visibleDays.count - 1 {
                        Rectangle()
                            .fill(Color.white.opacity(0.34))
                            .frame(height: 1)
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private func dayRow(_ day: DailyViewData) -> some View {
        HStack {
            Text(day.weekday)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 0.8, y: 0.8)
                .frame(width: 80, alignment: .leading)

            Spacer()

            WeatherAnimationView(conditionCode: day.conditionCode, isDay: day.isDay)
                .frame(width: 28, height: 28)

            Spacer()

            HStack(spacing: 8) {
                Text(day.minTemp)
                    .foregroundStyle(.white.opacity(0.86))
                Text(day.maxTemp)
                    .foregroundStyle(.white)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
    }
}

// MARK: - Preview

#Preview {
    let settings = AppSettings.shared
    let sampleDays: [DailyViewData] = [
        .init(id: "1", weekday: settings.string(.today), minTemp: "10°", maxTemp: "18°", conditionCode: 1003, isDay: true),
        .init(id: "2", weekday: "Пн", minTemp: "8°", maxTemp: "16°", conditionCode: 1180, isDay: true),
        .init(id: "3", weekday: "Вт", minTemp: "5°", maxTemp: "12°", conditionCode: 1066, isDay: true)
    ]
    return DailyForecastView(days: sampleDays)
        .padding()
        .frame(height: 250)
        .background(WeatherGradientColors.colors(for: 1003).first ?? .blue)
}
