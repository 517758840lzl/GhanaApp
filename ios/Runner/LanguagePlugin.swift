import Flutter
import UIKit

public class LanguagePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.example.app/language",
      binaryMessenger: registrar.messenger()
    )
    let instance = LanguagePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "updateLanguage" {
      guard let args = call.arguments as? [String: Any],
            let languageCode = args["languageCode"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        return
      }
      
      // 保存语言偏好到UserDefaults
      UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
      UserDefaults.standard.synchronize()
      
      // 更新全局语言设置
      AppLanguageManager.shared.setLanguage(languageCode)
      
      result(true)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}

/// 应用语言管理器
/// 用于管理iOS原生代码的语言设置
class AppLanguageManager {
  static let shared = AppLanguageManager()
  
  private var currentLanguage: String = "en"
  
  private init() {
    // 从UserDefaults读取保存的语言设置
    if let languages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String],
       let firstLanguage = languages.first {
      currentLanguage = firstLanguage
    }
  }
  
  func setLanguage(_ languageCode: String) {
    currentLanguage = languageCode
    UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
    UserDefaults.standard.synchronize()
  }
  
  func getCurrentLanguage() -> String {
    return currentLanguage
  }
  
  /// 根据当前语言设置获取本地化字符串
  func localizedString(forKey key: String, comment: String = "") -> String {
    guard let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj"),
          let bundle = Bundle(path: path) else {
      // 如果找不到对应的语言包，使用默认的NSLocalizedString
      return NSLocalizedString(key, comment: comment)
    }
    return bundle.localizedString(forKey: key, value: nil, table: nil)
  }
}

/// 全局本地化函数
/// 根据当前应用语言设置返回对应的本地化字符串
func AppLocalizedString(_ key: String, comment: String = "") -> String {
  return AppLanguageManager.shared.localizedString(forKey: key, comment: comment)
}

