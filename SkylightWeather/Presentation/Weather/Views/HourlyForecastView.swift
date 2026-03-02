//
//  HourlyForecastView.swift
//  SkylightWeather
//

import SwiftUI

struct HourlyForecastView: View {

    private enum Layout {
        static let wheelRowHeight: CGFloat = 52
        static let pastStripHeight: CGFloat = 56
        static let headerHeight: CGFloat = 156
        static let separatorHeight: CGFloat = 1
    }

    let hours: [HourlyViewData]
    var onInteractionChanged: ((Bool) -> Void)?

    @Environment(\.appSettings) private var settings
    @State private var isPagerLocked = false
    @State private var selectedHourId: String?

    private var visibleHours: [HourlyViewData] {
        Array(hours.prefix(24))
    }

    private var nowIndex: Int? {
        visibleHours.firstIndex(where: { $0.isNow })
    }

    private var pastHours: [HourlyViewData] {
        guard let idx = nowIndex, idx > 0 else { return [] }
        return Array(visibleHours.prefix(idx))
    }

    private var currentAndFutureHours: [HourlyViewData] {
        guard let idx = nowIndex else { return visibleHours }
        return Array(visibleHours.suffix(from: idx))
    }

    private var nowHourId: String? {
        currentAndFutureHours.first?.id
    }

    private var selectedHour: HourlyViewData? {
        guard let selectedHourId else { return currentAndFutureHours.first }
        return currentAndFutureHours.first(where: { $0.id == selectedHourId }) ?? currentAndFutureHours.first
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerSection
                pastHoursSection
                futureHoursSection(totalHeight: geometry.size.height)
            }
        }
        .onChange(of: hours, initial: true) { _, _ in
            synchronizeSelection()
        }
        .onChange(of: selectedHourId) { oldValue, newValue in
            handleSelectionChange(oldValue: oldValue, newValue: newValue)
        }
        .onDisappear {
            selectedHourId = nowHourId
            setPagerLockState(false)
        }
    }

    @ViewBuilder
    private var headerSection: some View {
        if let selectedHour {
            selectedHourHeader(selectedHour)
                .frame(height: Layout.headerHeight)
            stripSeparator
        }
    }

    @ViewBuilder
    private var pastHoursSection: some View {
        if !pastHours.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(pastHours) { hour in
                        pastChip(hour)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .frame(height: Layout.pastStripHeight)
            stripSeparator
        }
    }

    private func futureHoursSection(totalHeight: CGFloat) -> some View {
        let scrollAreaHeight = totalHeight
            - (pastHours.isEmpty ? 0 : (Layout.pastStripHeight + Layout.separatorHeight))
            - Layout.headerHeight
            - Layout.separatorHeight

        return futureScroll(containerHeight: scrollAreaHeight)
    }

    private var stripSeparator: some View {
        Rectangle()
            .fill(.white.opacity(0.15))
            .frame(height: 0.5)
            .padding(.horizontal, 16)
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

    private func selectedHourHeader(_ hour: HourlyViewData) -> some View {
        let timeText = hour.isNow ? settings.string(.now) : hour.time
        return VStack(spacing: 6) {
            HStack(spacing: 0) {
                Text(timeText)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                WeatherAnimationView(conditionCode: hour.conditionCode, isDay: hour.isDay)
                    .frame(width: 100, height: 100)

                Text(hour.temperature)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Text(selectedHourInfoText(hour))
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func selectedHourInfoText(_ hour: HourlyViewData) -> String {
        let precipPart = "\(settings.string(.precipitationChanceShort)) \(hour.precipitationChance)%"
        let humidityPart = hour.humidity.map { "\($0)%" }
        let windPart = hour.windKph.map {
            "\(settings.string(.windSpeedShort)) \(Int($0)) \(settings.string(.windUnit))"
        }

        return [precipPart, humidityPart, windPart]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    @ViewBuilder
    private func futureScroll(containerHeight: CGFloat) -> some View {
        let content = Group {
            #if os(iOS)
            iOSFuturePicker
            #else
            macFutureList
            #endif
        }
        .clipped()
        .frame(maxWidth: .infinity)
        .frame(height: max(containerHeight, 0))

        #if os(iOS)
        content.simultaneousGesture(
            DragGesture(minimumDistance: 4)
                .onChanged { _ in
                    setPagerLockState(true)
                }
                .onEnded { _ in
                    setPagerLockState(false)
                }
        )
        #else
        content
        #endif
    }

    #if os(iOS)
    private var iOSFuturePicker: some View {
        Picker("", selection: $selectedHourId) {
            ForEach(currentAndFutureHours) { hour in
                wheelRow(hour)
                    .tag(Optional(hour.id))
            }
        }
        .labelsHidden()
        .pickerStyle(.wheel)
        .accessibilityIdentifier("hourly_inner_scroll")
    }
    #endif

    #if os(macOS)
    private var macFutureList: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(currentAndFutureHours) { hour in
                        Button {
                            selectedHourId = hour.id
                        } label: {
                            wheelRow(hour)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(selectedHourId == hour.id ? .white.opacity(0.14) : .clear)
                                )
                        }
                        .buttonStyle(.plain)
                        .id(hour.id)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .accessibilityIdentifier("hourly_inner_scroll")
            .onChange(of: selectedHourId, initial: true) { _, newValue in
                guard let newValue else { return }
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
    #endif

    private func wheelRow(_ hour: HourlyViewData) -> some View {
        let timeText = hour.isNow ? settings.string(.now) : hour.time

        return HStack(spacing: 0) {
            Text(timeText)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 76, alignment: .leading)

            Image(systemName: sfSymbol(for: hour.conditionCode, isDay: hour.isDay))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))
                .frame(width: 34, height: 34)

            Spacer(minLength: 12)

            Text(hour.temperature)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 48, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(height: Layout.wheelRowHeight)
        .contentShape(Rectangle())
    }

    private func sfSymbol(for conditionCode: Int, isDay: Bool) -> String {
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

    private func setPagerLockState(_ value: Bool) {
        guard isPagerLocked != value else { return }
        isPagerLocked = value
        onInteractionChanged?(value)
    }

    private func handleSelectionChange(oldValue: String?, newValue: String?) {
        guard oldValue != newValue else { return }
        if oldValue != nil, newValue != nil {
            HapticManager.shared.selectionChanged()
        }
    }

    private func synchronizeSelection() {
        let availableIDs = Set(currentAndFutureHours.map(\.id))
        if let selectedHourId, availableIDs.contains(selectedHourId) {
            return
        }
        selectedHourId = nowHourId
    }
}

// MARK: - Preview

#Preview {
    HourlyForecastView(hours: PreviewWeatherData.hourly)
        .frame(height: 468)
        .background(PreviewWeatherData.gradientBackground)
        .environment(\.appSettings, AppSettings.shared)
}
