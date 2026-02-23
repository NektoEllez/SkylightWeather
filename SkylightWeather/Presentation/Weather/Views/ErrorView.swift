//
//  ErrorView.swift
//  SkylightWeather
//

import SwiftUI

struct ErrorView: View {

    let message: String
    let actionTitle: String
    var iconName: String = "cloud.slash"
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            errorIcon
            errorMessage
            actionButton
        }
        .padding()
    }

    // MARK: - Subviews

    private var errorIcon: some View {
        Image(systemName: iconName)
            .font(.system(size: 48))
            .foregroundStyle(.primary)
    }

    private var errorMessage: some View {
        Text(message)
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)
    }

    private var actionButton: some View {
        Button(actionTitle) {
            HapticManager.shared.lightImpact()
            onAction()
        }
            .buttonStyle(.bordered)
    }
}

// MARK: - Preview

#Preview {
    ErrorView(
        message: AppSettings.shared.string(.errorNoInternet),
        actionTitle: AppSettings.shared.string(.retry),
        iconName: "cloud.slash",
        onAction: {}
    )
        .environment(\.appSettings, AppSettings.shared)
}
