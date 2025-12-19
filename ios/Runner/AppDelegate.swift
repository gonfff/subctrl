import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let notificationChannel = "subctrl/notification_permissions"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let handled = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    setupNotificationChannel()
    return handled
  }

  private func setupNotificationChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(
      name: notificationChannel,
      binaryMessenger: controller.binaryMessenger,
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "checkPermission":
        self?.checkPermission(result: result)
      case "requestPermission":
        self?.requestPermission(result: result)
      case "openSettings":
        self?.openAppSettings()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func checkPermission(result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        result(self.string(from: settings.authorizationStatus))
      }
    }
  }

  private func requestPermission(result: @escaping FlutterResult) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
      center.getNotificationSettings { settings in
        DispatchQueue.main.async {
          result(self.string(from: settings.authorizationStatus))
        }
      }
    }
  }

  private func openAppSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  private func string(from status: UNAuthorizationStatus) -> String {
    switch status {
    case .authorized:
      return "authorized"
    case .denied:
      return "denied"
    case .notDetermined:
      return "notDetermined"
    case .provisional:
      return "provisional"
    case .ephemeral:
      return "ephemeral"
    @unknown default:
      return "denied"
    }
  }
}
