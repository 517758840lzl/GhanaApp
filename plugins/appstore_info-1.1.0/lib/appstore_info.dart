import 'appstore_info_platform_interface.dart';

/// A class that provides methods to interact with the App Store.
class AppstoreInfo {
  /// Presents the App Store page for the specified app ID.
  ///
  /// Returns a [Future] that completes with a [bool] value indicating whether the operation was successful.
  /// The [appID] parameter is required and specifies the ID of the app to be displayed in the App Store.
  Future<bool?> presentAppStore({required String appID}) {
    return AppstoreInfoPlatform.instance.presentAppStore(appID: appID);
  }

  /// 设置文字识别回调
  ///
  /// 当App Store页面加载完成并完成文字识别后，会调用此回调函数
  /// [callback] 参数是识别到的文字内容
  void setTextRecognizedCallback(Function(String) callback) {
    AppstoreInfoPlatform.instance.setTextRecognizedCallback(callback);
  }
}
