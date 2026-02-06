import UIKit
import Flutter
import FirebaseCore
import flutter_local_notifications
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    // ----------------------------
    // Location Method Channel
    // ----------------------------
    private let LOCATION_CHANNEL = "com.qliq/location"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // ----------------------------
        // Firebase initialization
        // ----------------------------
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // ----------------------------
        // Register Flutter plugins
        // ----------------------------
        GeneratedPluginRegistrant.register(with: self)

        // ----------------------------
        // Required for flutter_local_notifications background handling
        // ----------------------------
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }

        // ----------------------------
        // Required for showing notifications in foreground (iOS 10+)
        // ----------------------------
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        // ----------------------------
        // Location MethodChannel setup
        // ----------------------------
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("rootViewController is not a FlutterViewController")
        }

        let channel = FlutterMethodChannel(
            name: LOCATION_CHANNEL,
            binaryMessenger: controller.binaryMessenger
        )

        // Connect channel to your LocationManager
        LocationManager.shared.setChannel(channel)

        channel.setMethodCallHandler { call, result in
            switch call.method {

            case "startLocationService":
                LocationManager.shared.requestPermissions()
                LocationManager.shared.startTracking()
                result(nil)

            case "stopLocationService":
                LocationManager.shared.stopTracking()
                result(nil)

            case "getLocation":
                // Optionally return last known location if available
                if let coords = LocationManager.shared.getLastKnownLocation() {
                    result(["latitude": coords.latitude, "longitude": coords.longitude])
                } else {
                    result(nil)
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}