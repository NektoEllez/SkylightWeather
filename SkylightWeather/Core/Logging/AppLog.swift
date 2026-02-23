    //
    //  AppLog.swift
    //  SkylightWeather
    //

import Foundation
import os

enum AppLog {
    nonisolated private static let subsystem = Bundle.main.bundleIdentifier ?? "test.SkylightWeather"
    
    nonisolated static let ui = Logger(subsystem: subsystem, category: "UI")
    nonisolated static let viewModel = Logger(subsystem: subsystem, category: "ViewModel")
    nonisolated static let useCase = Logger(subsystem: subsystem, category: "UseCase")
    nonisolated static let network = Logger(subsystem: subsystem, category: "Network")
    nonisolated static let location = Logger(subsystem: subsystem, category: "Location")
    nonisolated static let preferences = Logger(subsystem: subsystem, category: "Preferences")
}
