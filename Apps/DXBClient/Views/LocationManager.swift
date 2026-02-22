import CoreLocation
import SwiftUI

@Observable
@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    var detectedCountryCode: String?
    var detectedCity: String?
    var isAuthorized = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestIfNeeded() {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            manager.requestLocation()
        default:
            isAuthorized = false
            fallbackToLocale()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                isAuthorized = true
                manager.requestLocation()
            case .denied, .restricted:
                isAuthorized = false
                fallbackToLocale()
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            await reverseGeocode(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            #if DEBUG
            print("[LocationManager] Error: \(error.localizedDescription)")
            #endif
            fallbackToLocale()
        }
    }

    private func reverseGeocode(_ location: CLLocation) async {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                detectedCountryCode = placemark.isoCountryCode
                detectedCity = placemark.locality
                #if DEBUG
                print("[LocationManager] Detected: \(detectedCountryCode ?? "?") / \(detectedCity ?? "?")")
                #endif
            }
        } catch {
            #if DEBUG
            print("[LocationManager] Geocoding failed: \(error.localizedDescription)")
            #endif
            fallbackToLocale()
        }
    }

    private func fallbackToLocale() {
        if detectedCountryCode == nil {
            detectedCountryCode = Locale.current.region?.identifier
        }
    }
}
