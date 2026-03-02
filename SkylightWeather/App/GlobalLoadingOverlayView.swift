//
//  GlobalLoadingOverlayView.swift
//  SkylightWeather
//

import SwiftUI
#if canImport(Lottie)
import Lottie
#endif

struct GlobalLoadingOverlay: View {

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.black.opacity(0.24)
                .ignoresSafeArea()

            animationContainer
        }
        .accessibilityIdentifier("global_loading_overlay")
    }

    private var backgroundFill: Color {
        #if os(iOS)
        Color(.systemBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }

    private var animationContainer: some View {
        Group {
            #if canImport(Lottie)
            LottieView(animation: .named("loader_infinity"))
                .playing(loopMode: .loop)
                .frame(width: 116, height: 116)
            #else
            ProgressView()
                .controlSize(.large)
            #endif
        }
        .frame(width: 158, height: 158)
        .background(backgroundFill.opacity(0.22))
        .clipShape(.rect(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }
}

#Preview {
    GlobalLoadingOverlay()
}
