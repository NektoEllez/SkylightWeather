//
//  PageIndicatorView.swift
//  SkylightWeather
//

import SwiftUI

struct PageIndicatorView: View {
    let count: Int
    @Binding var selectedIndex: Int?

    private var current: Int {
        min(max(selectedIndex ?? 0, 0), max(count - 1, 0))
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index == current ? Color.white.opacity(0.95) : Color.white.opacity(0.35))
                    .frame(width: index == current ? 22 : 8, height: 8)
                    .animation(.spring(response: 0.28, dampingFraction: 0.8), value: current)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .adaptiveGlassBackground(cornerRadius: 20)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selected: Int? = 0
    return PageIndicatorView(count: 3, selectedIndex: $selected)
        .padding()
        .background(Color.blue.opacity(0.3))
}
