    //
    //  DailyForecastView.swift
    //  SkylightWeather
    //

import SwiftUI

struct DailyForecastView: View {

    let days: [DailyViewData]
    @Environment(\.appSettings) private var settings

    private var visibleDays: [DailyViewData] { Array(days.prefix(7)) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
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
        VStack(spacing: 0) {
            mainRow(day)
            if day.windKph != nil || day.humidity != nil {
                statsRow(day)
                    .padding(.bottom, 6)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 6)
    }

    private func mainRow(_ day: DailyViewData) -> some View {
        HStack {
            Text(day.weekday)
                .font(.system(.body, design: .rounded))
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
            .font(.system(.body, design: .rounded))
            .frame(width: 80, alignment: .trailing)
        }
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func statsRow(_ day: DailyViewData) -> some View {
        let windPart = day.windKph.map {
            "\(Int($0)) \(settings.string(.windUnit))"
        }
        let humPart = day.humidity.map { "\($0)%" }

        HStack(spacing: 14) {
            Spacer()
            if let wind = windPart {
                Label(wind, systemImage: "wind")
            }
            if let hum = humPart {
                Label(hum, systemImage: "humidity.fill")
            }
        }
        .font(.system(.caption, design: .rounded))
        .foregroundStyle(.white.opacity(0.6))
        .minimumScaleFactor(0.85)
    }
}

    // MARK: - Preview

#Preview {
    DailyForecastView(days: PreviewWeatherData.daily)
        .padding()
        .frame(height: 340)
        .background(PreviewWeatherData.gradientBackground)
        .environment(\.appSettings, AppSettings.shared)
}
