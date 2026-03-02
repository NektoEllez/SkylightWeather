//
//  HorizontalPagingScrollView.swift
//  SkylightWeather
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
struct HorizontalPagingScrollView<Content: View>: View {

    private struct Metrics {
        let cardWidth: CGFloat
        let cardHeight: CGFloat
        let sidePeek: CGFloat
    }

    let pageCount: Int
    @Binding var selectedIndex: Int?
    var scrollEnabled: Bool = true
    var horizontalPadding: CGFloat = 0
    var cardWidthRatio: CGFloat = 1.0
    var pinchScale: CGFloat = 0.92
    var verticalPadding: CGFloat = 0
    @ViewBuilder let content: (Int) -> Content

    var body: some View {
        GeometryReader { geometry in
            let metrics = makeMetrics(for: geometry.size)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        cardView(index: index, metrics: metrics)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, horizontalPadding + metrics.sidePeek)
                .padding(.vertical, verticalPadding)
                .background(Color.clear)
            }
            .scrollPosition(id: $selectedIndex)
            .scrollDisabled(!scrollEnabled)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .background(Color.clear)
            #if os(macOS)
            .simultaneousGesture(macMouseSwipeGesture)
            #endif
        }
    }

    private func makeMetrics(for size: CGSize) -> Metrics {
        let containerWidth = size.width - horizontalPadding * 2
        let cardWidth = containerWidth * cardWidthRatio
        let sidePeek = (containerWidth - cardWidth) / 2
        let cardHeight = size.height - verticalPadding * 2
        return Metrics(cardWidth: cardWidth, cardHeight: cardHeight, sidePeek: sidePeek)
    }

    @ViewBuilder
    private func cardView(index: Int, metrics: Metrics) -> some View {
        let card = content(index)
            .frame(width: metrics.cardWidth, height: metrics.cardHeight)
            .id(index)

        if cardWidthRatio < 1 {
            card
                .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                    view.scaleEffect(phase.isIdentity ? 1 : pinchScale)
                }
        } else {
            card
        }
    }

    #if os(macOS)
    private var macMouseSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 14)
            .onEnded { value in
                guard scrollEnabled else { return }
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > abs(vertical) * 1.25 else { return }

                let threshold: CGFloat = 72
                var next = selectedIndex ?? 0
                if horizontal <= -threshold {
                    next += 1
                } else if horizontal >= threshold {
                    next -= 1
                }

                let clamped = min(max(next, 0), max(pageCount - 1, 0))
                guard clamped != (selectedIndex ?? 0) else { return }
                withAnimation(.snappy) {
                    selectedIndex = clamped
                }
            }
    }
    #endif
}

// MARK: - Preview

#Preview {
    @Previewable @State var selected: Int? = 0
    return HorizontalPagingScrollView(
        pageCount: 3,
        selectedIndex: $selected,
        cardWidthRatio: 0.86,
        pinchScale: 0.93
    ) { index in
        Text("\(L10n.text(.now)) \(index + 1)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.3))
    }
    .frame(height: 300)
}
