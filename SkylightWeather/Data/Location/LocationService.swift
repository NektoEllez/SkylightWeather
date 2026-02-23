//
//  LocationService.swift
//  SkylightWeather
//

import CoreLocation
import os

extension CLLocationCoordinate2D {
    static let moscow = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
}

@MainActor
final class LocationService {

    private let manager = CLLocationManager()
    private let logger = AppLog.location
    private lazy var coordinator = Coordinator(owner: self)
    private var continuations: [CheckedContinuation<CLLocationCoordinate2D, Never>] = []
    private var isRequestInFlight = false
    private var isAwaitingAuthorization = false
    private var timeoutTask: Task<Void, Never>?
    private let requestTimeoutNanoseconds: UInt64 = 12_000_000_000

    func requestLocation() async -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus
        logger.debug("Location request started")

        if status == .denied || status == .restricted {
            logger.notice("Location permission unavailable, using Moscow fallback")
            return .moscow
        }

        return await withCheckedContinuation { continuation in
            continuations.append(continuation)

            guard !isRequestInFlight else { return }

            isRequestInFlight = true
            manager.delegate = coordinator
            manager.desiredAccuracy = kCLLocationAccuracyKilometer
            scheduleRequestTimeout()

            if status == .notDetermined {
                logger.debug("Location permission not determined, requesting authorization")
                isAwaitingAuthorization = true
                manager.requestWhenInUseAuthorization()
            } else {
                isAwaitingAuthorization = false
                manager.requestLocation()
            }
        }
    }

    private func requestSingleLocation() {
        manager.requestLocation()
    }

    private func resolveAll(with coordinate: CLLocationCoordinate2D) {
        logger.debug("Resolved location request")
        timeoutTask?.cancel()
        timeoutTask = nil
        manager.delegate = nil
        let pending = continuations
        continuations.removeAll()
        isRequestInFlight = false
        isAwaitingAuthorization = false
        pending.forEach { $0.resume(returning: coordinate) }
    }

    private func scheduleRequestTimeout() {
        timeoutTask?.cancel()
        timeoutTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: self.requestTimeoutNanoseconds)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                self.logger.notice("Location request timed out, using Moscow fallback")
                self.resolveAll(with: .moscow)
            }
        }
    }

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            if isAwaitingAuthorization {
                logger.debug("Location permission granted, requesting single location")
                isAwaitingAuthorization = false
                requestSingleLocation()
            }
        case .denied, .restricted:
            logger.notice("Location permission denied/restricted, using fallback")
            resolveAll(with: .moscow)
        case .notDetermined:
            break
        @unknown default:
            resolveAll(with: .moscow)
        }
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, CLLocationManagerDelegate {

        private weak var owner: LocationService?

        init(owner: LocationService) {
            self.owner = owner
        }

        nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            Task { @MainActor [weak self] in
                AppLog.location.debug("Authorization status changed")
                self?.owner?.handleAuthorizationChange(manager.authorizationStatus)
            }
        }

        nonisolated func locationManager(
            _ manager: CLLocationManager,
            didUpdateLocations locations: [CLLocation]
        ) {
            Task { @MainActor [weak self] in
                AppLog.location.debug("Location updated from CoreLocation")
                self?.owner?.resolveAll(with: locations.first?.coordinate ?? .moscow)
            }
        }

        nonisolated func locationManager(
            _ manager: CLLocationManager,
            didFailWithError error: Error
        ) {
            Task { @MainActor [weak self] in
                AppLog.location.error("Location manager failed, using fallback")
                self?.owner?.resolveAll(with: .moscow)
            }
        }
    }
}
