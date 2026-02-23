    //
    //  HorizontalPagingScrollView.swift
    //  SkylightWeather
    //

import SwiftUI

@available(iOS 17.0, *)
struct HorizontalPagingScrollView<Content: View>: View {
    let pageCount: Int
    @Binding var selectedIndex: Int?
    var horizontalPadding: CGFloat = 0
    var cardWidthRatio: CGFloat = 1.0
    var pinchScale: CGFloat = 0.92
    var verticalPadding: CGFloat = 0
    @ViewBuilder let content: (Int) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width - horizontalPadding * 2
            let cardWidth = containerWidth * cardWidthRatio
            let sidePeek = (containerWidth - cardWidth) / 2
            let cardHeight = geometry.size.height - verticalPadding * 2
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        cardView(index: index, cardWidth: cardWidth, height: cardHeight)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, horizontalPadding + sidePeek)
                .padding(.vertical, verticalPadding)
                .background(Color.clear)
            }
            .scrollPosition(id: $selectedIndex)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .background(Color.clear)
        }
    }
    
    @ViewBuilder
    private func cardView(index: Int, cardWidth: CGFloat, height: CGFloat) -> some View {
        let card = content(index)
            .frame(width: cardWidth, height: height)
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
