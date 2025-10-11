import 'package:flutter3APP/http/http.dart';
import 'package:flutter3APP/views/me/dialogs/meituan_logout_dialog.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../http/api_urls.dart';
import '../../provider/userDataHelper.dart';
import '../../common/toast.dart';
import '../../routes/routes.dart';

class MyController extends GetxController with WidgetsBindingObserver {
  final RxString phone = ''.obs;
  final RxInt level = 1.obs;
  final RxInt sex = 1.obs; //1男2女

  final RxString customerName = ''.obs;
  final RxString idCardNumber = ''.obs;

  final RxBool isRepaymentVisible = false.obs;

  static DateTime? _lastConfirmTime;
  static const Duration _cooldown = Duration(seconds: 5);

  static const String _phoneKey = 'cached_phone';
  static const String _sexKey = 'cached_sex';
  static const String _levelKey = 'cached_level';
  static const String _customerNameKey = 'cached_customerName';
  static const String _idCardNumberKey = 'cached_idCardNumber';
  static const String _timestampKey = 'cached_timestamp';
  static const Duration _cacheDuration = Duration(days: 1);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadCachedData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadCachedData();
    }
  }

  Future<void> loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedPhone = prefs.getString(_phoneKey);
    final cachedSex = prefs.getInt(_sexKey);
    final cachedLevel = prefs.getInt(_levelKey);
    final cachedTimestamp = prefs.getInt(_timestampKey);
    phone.value = cachedPhone ?? '';
    sex.value = cachedSex ?? 1;
    level.value = cachedLevel ?? 1;
    await fetchUserInfo();
    await fetchRepaymentVisible();
    if (cachedTimestamp != null) {
      final lastCached = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
      if (DateTime.now().difference(lastCached) < _cacheDuration) {
        return;
      }
    }
    await fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final now = DateTime.now();
    if (_lastConfirmTime != null &&
        now.difference(_lastConfirmTime!) < _cooldown) {
      return;
    }

    try {
      final result = await ApiUrls.getUserInformation();
      if (result.isSucceed && result.data != null) {
        final userData = result.data;
        phone.value = userData?['phone']?.toString() ?? '';
        sex.value = userData?['sex'] ?? 1;
        customerName.value = userData?['customerName']?.toString() ?? '';
        idCardNumber.value = userData?['idCardNumber']?.toString() ?? '';
        level.value = userData?['level'] ?? 1;
        _lastConfirmTime = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_phoneKey, phone.value);
        await prefs.setInt(_sexKey, sex.value);
        await prefs.setInt(_levelKey, level.value);
        await prefs.setString(_customerNameKey, customerName.value);
        await prefs.setString(_idCardNumberKey, idCardNumber.value);
        await prefs.setInt(_timestampKey, now.millisecondsSinceEpoch);
      } else {
        YDToast.text(
          result.msg != ""
              ? result.msg
              : "Server error, please try again later.",
        );
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> fetchRepaymentVisible() async {
    // 这里建议后续迁移RepaymentApiService为ApiUrls统一接口
    // 目前仅做占位，实际迁移时需补充ApiUrls相关方法
    isRepaymentVisible.value = false; // TODO: 替换为真实接口判断
  }

  String getAvatarAsset() {
    if (sex.value == 2) {
      return 'assets/images/avatar_female.png';
    }
    return 'assets/images/avatar_male.webp';
  }

  Future<void> logout() async {
    HttpUtil.cancelRequest();
    await UserDataHelper.clearUserToken();
    Get.offAllNamed(Routes.login);
  }

  void showLogoutDialog(BuildContext context) {
    MeituanLogoutDialog.show(onConfirm: logout);
  }
}
