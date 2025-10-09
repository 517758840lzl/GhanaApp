import 'package:flutter3APP/http/http.dart';
import 'package:get/get.dart';
import 'userDataHelper.dart';

class AppState extends GetxService {

  static AppState get to => Get.find();
  // 登录状态
  final isLoggedIn = false.obs;
  // 用户ID
  final _userId = "".obs;
  // 是否从WebView返回
  final fromWebView = false.obs;

  // 登录
  void login(String userId) {
    isLoggedIn.value = true;
    _userId.value = userId;
  }


  // 登出
  Future<void> logout() async {
    isLoggedIn.value = false;
    _userId.value = "";
    HttpUtil.cancelRequest();
    await UserDataHelper.clearUserToken();
  }


}
