//
//  HourlyForecastView.swift
//  SkylightWeather
//

import SwiftUI

struct HourlyForecastView: View {

    let hours: [HourlyViewData]
    var onInteractionChanged: ((Bool) -> Void)?

    @Environment(\.appSettings) private var settings
    @State private var isInteracting = false
    @State private var centeredHourId: String?

    private let rowHeight: CGFloat = 52
    private let edgeScale: CGFloat = 0.72
    private let centerInfluenceRows: CGFloat = 2.5

    private var visibleHours: [HourlyViewData] { Array(hours.prefix(24)) }

    private var nowIndex: Int? { visibleHours.firstIndex(where: { $0.isNow }) }

    private var pastHours: [HourlyViewData] {
        guard let idx = nowIndex, idx > 0 else { return [] }
        return Array(visibleHours.prefix(idx))
    }

    private var currentAndFutureHours: [HourlyViewData] {
        guard let idx = nowIndex else { return visibleHours }
        return Array(visibleHours.suffix(from: idx))
    }

    private var centeredIndex: Int {
        guard let id = centeredHourId else { return 0 }
        return currentAndFutureHours.firstIndex(where: { $0.id == id }) ?? 0
    }

    var body: some View {
        GeometryReader { geometry in
            let scrollAreaHeight = geometry.size.height - (pastHours.isEmpty ? 0 : (pastStripHeight + 1))
            VStack(spacing: 0) {
                if !pastHours.isEmpty {
                    pastHoursStrip
                    stripSeparator
                }
                futureScroll(containerHeight: scrollAreaHeight)
            }
        }
        .onAppear {
            if centeredHourId == nil {
                centeredHourId = currentAndFutureHours.first?.id
            }
        }
    }

    private var pastStripHeight: CGFloat { 56 }

    // MARK: - Past hours (outside scroll, gray)

    private var pastHoursStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(pastHours) { hour in
                    pastChip(hour)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }

    private func pastChip(_ hour: HourlyViewData) -> some View {
        VStack(spacing: 3) {
            Text(hour.time)
                .font(.system(.caption2, design: .rounded))
            WeatherAnimationView(conditionCode: hour.conditionCode, isDay: hour.isDay)
                .frame(width: 22, height: 22)
            Text(hour.temperature)
                .font(.system(.caption2, design: .rounded, weight: .medium))
        }
        .foregroundStyle(.white.opacity(0.45))
    }

    private var stripSeparator: some View {
        Rectangle()
            .fill(.white.opacity(0.15))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
    }

    // MARK: - Current + future (vertical scroll, drum)

    private func futureScroll(containerHeight: CGFloat) -> some View {
        let verticalInset = max((containerHeight - rowHeight) / 2, 0)
        return ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                ForEach(Array(currentAndFutureHours.enumerated()), id: \.element.id) { index, hour in
                    hourRow(hour, index: index)
                        .frame(height: rowHeight)
                        .id(hour.id)
                }
            }
            .scrollTargetLayout()
            .padding(.top, verticalInset)
            .padding(.bottom, verticalInset)
        }
        .scrollPosition(id: $centeredHourId, anchor: .center)
        .scrollTargetBehavior(.viewAligned)
        .accessibilityIdentifier("hourly_inner_scroll")
        .simultaneousGesture(
            DragGesture(minimumDistance: 3)
                .onChanged { _ in setInteractionState(true) }
                .onEnded { _ in setInteractionState(false) }
        )
        .onDisappear { setInteractionState(false) }
    }

    // MARK: - Row (drum: scale/opacity by distance from center)

    private func hourRow(_ hour: HourlyViewData, index: Int) -> some View {
        let isCentered = index == centeredIndex
        let progress = min(CGFloat(abs(index - centeredIndex)) / centerInfluenceRows, 1)
        let scale = 1 - progress * (1 - edgeScale)
        let opacity = 1 - progress * 0.28
        let timeText = hour.isNow ? settings.string(.now) : hour.time
        let timeColor: Double = isCentered ? 1 : 0.5

        return HStack(spacing: 0) {
            Text(timeText)
                .font(.system(.subheadline, design: .rounded, weight: isCentered ? .semibold : .regular))
                .foregroundStyle(.white.opacity(timeColor))
                .frame(width: 58, alignment: .leading)

            WeatherAnimationView(conditionCode: hour.conditionCode, isDay: hour.isDay)
                .frame(width: 34, height: 34)

            Spacer(minLength: 8)

            rowInfoLabel(hour, isCentered: isCentered)
                .frame(minWidth: 120, alignment: .trailing)

            Text(hour.temperature)
                .font(.system(.body, design: .rounded, weight: isCentered ? .semibold : .regular))
                .foregroundStyle(.white.opacity(opacity))
                .frame(width: 48, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 9)
        .scaleEffect(scale)
        .opacity(opacity)
        .background(isCentered ? Color.white.opacity(0.08) : Color.clear)
    }

    @ViewBuilder
    private func rowInfoLabel(_ hour: HourlyViewData, isCentered: Bool) -> some View {
        let opacity = isCentered ? 0.85 : 0.6
        let font = Font.system(.caption, design: .rounded)
        let sep = " · "
        
        let humidityText: String? = hour.humidity.map {
            "\(settings.string(.humidityShort)) \($0)%"
        }
        
        let windText: String? = hour.windKph.map {
            "\(settings.string(.windSpeedShort)) \(Int($0)) \(settings.string(.windUnit))"
        }
        
        let precipText: String? = hour.precipitationChance > 0
        ? "\(settings.string(.precipitationChanceShort)) \(hour.precipitationChance)%"
        : nil
        
        let parts = [humidityText, windText, precipText].compactMap { $0 }
        
        if parts.isEmpty {
            Text(" ")
                .font(.caption)
        } else {
            Text(parts.joined(separator: sep))
                .font(font)
                .foregroundStyle(.white.opacity(opacity))
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
        }
    }

    private func setInteractionState(_ value: Bool) {
        guard isInteracting != value else { return }
        isInteracting = value
        onInteractionChanged?(value)
    }
}

// MARK: - Preview

#Preview {
    let settings = AppSettings.shared
    let sampleHours: [HourlyViewData] = [
        .init(id: "0", time: "12:00", temperature: "13°", conditionCode: 1000, isDay: true, isNow: false, precipitationChance: 0, windKph: 5, humidity: 65),
        .init(id: "1", time: "13:00", temperature: "14°", conditionCode: 1003, isDay: true, isNow: false, precipitationChance: 20, windKph: 8, humidity: 70),
        .init(id: "2", time: settings.string(.now), temperature: "15°", conditionCode: 1003, isDay: true, isNow: true, precipitationChance: 30, windKph: 12, humidity: 72),
        .init(id: "3", time: "15:00", temperature: "16°", conditionCode: 1003, isDay: true, isNow: false, precipitationChance: 45, windKph: 8, humidity: 68),
        .init(id: "4", time: "16:00", temperature: "17°", conditionCode: 1000, isDay: true, isNow: false, precipitationChance: 0, windKph: 5, humidity: 55),
        .init(id: "5", time: "17:00", temperature: "16°", conditionCode: 1180, isDay: true, isNow: false, precipitationChance: 80, windKph: 22, humidity: 90),
        .init(id: "6", time: "18:00", temperature: "14°", conditionCode: 1066, isDay: false, isNow: false, precipitationChance: 10, windKph: 3, humidity: 85),
        .init(id: "7", time: "19:00", temperature: "12°", conditionCode: 1066, isDay: false, isNow: false, precipitationChance: 100, windKph: 28, humidity: 95)
    ]
    return HourlyForecastView(hours: sampleHours)
        .frame(height: 468)
        .background(WeatherGradientColors.colors(for: 1003).first ?? .blue)
        .environment(\.appSettings, AppSettings.shared)
}
