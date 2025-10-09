import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      if let registrar = self.registrar(forPlugin: "FaceLivenessPlugin") {
        FaceLivenessPlugin.register(with: registrar)
        print("✅ FaceLivenessPlugin manually registered.")
      } else {
        print("❌ Failed to get registrar for FaceLivenessPlugin")
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
