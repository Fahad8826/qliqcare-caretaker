import Foundation
import CoreLocation
import Flutter

class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private var channel: FlutterMethodChannel?

    // ⏱ Track last update time
    private var lastUpdateTime: Date?

    // ⏱ 20 seconds interval
    private let updateInterval: TimeInterval = 20

    override init() {
        super.init()
        locationManager.delegate = self
        
        // 🔥 Battery optimized accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.distanceFilter = 0
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func setChannel(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }

    func requestPermissions() {
        print("🔐 Requesting always authorization")
        locationManager.requestAlwaysAuthorization()
    }

    func startTracking() {
        print("🚀 Starting location updates")
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        print("🛑 Stopping location updates")
        locationManager.stopUpdatingLocation()
    }

    func getLastKnownLocation() -> CLLocationCoordinate2D? {
        print("🔍 Getting last known location")
        return locationManager.location?.coordinate
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else {
            print("❌ No location found")
            return
        }

        let now = Date()

        // ⏱ Send update only every 20 seconds
        if let lastTime = lastUpdateTime,
           now.timeIntervalSince(lastTime) < updateInterval {
            return
        }

        lastUpdateTime = now

        print("📍 Swift location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")

        channel?.invokeMethod(
            "locationUpdate",
            arguments: [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ]
        )
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("❌ Location error: \(error)")
    }
}