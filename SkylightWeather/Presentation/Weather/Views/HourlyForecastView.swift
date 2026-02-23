//
//  HourlyForecastView.swift
//  SkylightWeather
//

import SwiftUI

struct HourlyForecastView: View {

    let hours: [HourlyViewData]
    var onInteractionChanged: ((Bool) -> Void)?
    private let slotWidth: CGFloat = 68
    private let edgeScale: CGFloat = 0.72
    private let centerInfluenceFactor: CGFloat = 0.45
    private var visibleHours: [HourlyViewData] { Array(hours.prefix(24)) }
    @State private var isInteracting = false

    var body: some View {
        GeometryReader { geometry in
            let edgeInset = max((geometry.size.width - slotWidth) / 2, 0)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Color.clear
                        .frame(width: edgeInset)

                    ForEach(visibleHours) { hour in
                        hourSlot(hour)
                            .frame(width: slotWidth)
                            .visualEffect { view, proxy in
                                view
                                    .scaleEffect(
                                        Self.scaleForItem(
                                            midX: proxy.frame(in: .named("hourly-scroll")).midX,
                                            containerWidth: geometry.size.width,
                                            centerInfluenceFactor: centerInfluenceFactor,
                                            edgeScale: edgeScale
                                        )
                                    )
                                    .opacity(
                                        Self.opacityForItem(
                                            midX: proxy.frame(in: .named("hourly-scroll")).midX,
                                            containerWidth: geometry.size.width,
                                            centerInfluenceFactor: centerInfluenceFactor
                                        )
                                    )
                            }
                    }

                    Color.clear
                        .frame(width: edgeInset)
                }
                .scrollTargetLayout()
            }
            .accessibilityIdentifier("hourly_inner_scroll")
            .scrollTargetBehavior(.viewAligned)
            .coordinateSpace(name: "hourly-scroll")
            .background(Color.clear)
            .simultaneousGesture(
                DragGesture(minimumDistance: 3)
                    .onChanged { _ in
                        setInteractionState(true)
                    }
                    .onEnded { _ in
                        setInteractionState(false)
                    }
            )
            .onDisappear {
                setInteractionState(false)
            }
        }
    }

    nonisolated private static func normalizedDistance(
        midX: CGFloat,
        containerWidth: CGFloat,
        centerInfluenceFactor: CGFloat
    ) -> CGFloat {
        let centerX = containerWidth / 2
        let influenceRadius = max(containerWidth * centerInfluenceFactor, 1)
        return min(abs(midX - centerX) / influenceRadius, 1)
    }

    nonisolated private static func scaleForItem(
        midX: CGFloat,
        containerWidth: CGFloat,
        centerInfluenceFactor: CGFloat,
        edgeScale: CGFloat
    ) -> CGFloat {
        let progress = normalizedDistance(
            midX: midX,
            containerWidth: containerWidth,
            centerInfluenceFactor: centerInfluenceFactor
        )
        return 1 - progress * (1 - edgeScale)
    }

    nonisolated private static func opacityForItem(
        midX: CGFloat,
        containerWidth: CGFloat,
        centerInfluenceFactor: CGFloat
    ) -> CGFloat {
        let progress = normalizedDistance(
            midX: midX,
            containerWidth: containerWidth,
            centerInfluenceFactor: centerInfluenceFactor
        )
        return 1 - progress * 0.22
    }

    // MARK: - Subviews

    private func hourSlot(_ hour: HourlyViewData) -> some View {
        VStack(spacing: 8) {
            Text(hour.time)
                .font(.system(.caption, design: .rounded, weight: hour.isNow ? .semibold : .regular))
                .foregroundStyle(.white.opacity(hour.isNow ? 1 : 0.85))
                .lineLimit(1)

            WeatherAnimationView(conditionCode: hour.conditionCode, isDay: hour.isDay)
                .frame(width: 36, height: 36)

            Text(hour.temperature)
                .font(.system(.body, design: .rounded, weight: hour.isNow ? .semibold : .regular))
                .foregroundStyle(.white)

            if hour.precipitationChance > 0 {
                Text("\(hour.precipitationChance)%")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            } else if let wind = hour.windKph, wind >= 20 {
                Text("\(Int(wind))")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                Text(" ")
                    .font(.caption)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(.vertical, 16)
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
        .init(id: "1", time: settings.string(.now), temperature: "15°", conditionCode: 1003, isDay: true, isNow: true, precipitationChance: 30, windKph: 12),
        .init(id: "2", time: "14:00", temperature: "16°", conditionCode: 1003, isDay: true, isNow: false, precipitationChance: 45, windKph: 8),
        .init(id: "3", time: "15:00", temperature: "17°", conditionCode: 1000, isDay: true, isNow: false, precipitationChance: 0, windKph: 5),
        .init(id: "4", time: "16:00", temperature: "16°", conditionCode: 1180, isDay: true, isNow: false, precipitationChance: 80, windKph: 22),
        .init(id: "5", time: "17:00", temperature: "14°", conditionCode: 1066, isDay: false, isNow: false, precipitationChance: 10, windKph: 3)
    ]
    return HourlyForecastView(hours: sampleHours)
        .padding()
        .frame(height: 140)
        .background(WeatherGradientColors.colors(for: 1003).first ?? .blue)
}
