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
        print("FaceLivenessPlugin registered.")
      } else {
        print("FaceLivenessPlugin")
      }
      
      // 注册语言插件
      if let registrar = self.registrar(forPlugin: "LanguagePlugin") {
        LanguagePlugin.register(with: registrar)
        print("LanguagePlugin registered.")
      }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
