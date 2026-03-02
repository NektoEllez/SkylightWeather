//
//  GlassStyle.swift
//  SkylightWeather
//

import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveGlassBackground(
        cornerRadius: CGFloat = 20,
        useLiquidGlass: Bool = true
    ) -> some View {
        #if os(iOS)
        if #available(iOS 26, *), useLiquidGlass {
            self
                .glassEffect(in: .rect(cornerRadius: cornerRadius))
        } else {
            self
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        #else
        self
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        #endif
    }
}
