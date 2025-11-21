import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../basa/appsFlyer/apps_flyer_helper.dart';
import '../../basa/main_constant.dart';
import '../../basa/updateData/user_updata_server.dart';
import '../../common/toast.dart';
import '../../provider/userDataHelper.dart';
import '../../http/api_urls.dart';
import '../../common/logger/app_logger.dart';
import '../../utils/validators.dart';
import '../../utils/md5.dart';
import '../../routes/routes.dart';
import '../../controllers/language_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isSendingOtp = false.obs;
  var phoneNumber = ''.obs;
  var phoneLength = 0.obs;
  var countryCode = Constant.COUNTRY_CODES.first.obs;
  var otpCountdown = '  ${'retrieveOtp'.tr}  '.obs;
  Timer? _otpTimer;
  var _otpCountdownTime = 60;
  var isPrivacyAgreed = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPhoneNumber();
    _loadCountryCode();
    phoneController.addListener(_handlePhoneNumberChange);
  }

  Future<void> _loadCountryCode() async {
    String? savedCountry = await UserDataHelper.getCountry();
    if (savedCountry != null && Constant.COUNTRY_CODES.contains(savedCountry)) {
      countryCode.value = savedCountry;
    } else {
      // 如果没有保存的区号，根据系统语言设置默认区号
      // 西班牙语默认第二个区号，其他语言默认第一个区号
      String? currentLang;
      try {
        final systemLocale = Get.deviceLocale;
        if (systemLocale != null) {
          currentLang = systemLocale.languageCode;
        }
      } catch (e) {
        // 如果获取语言控制器失败，尝试使用系统语言

          LogUtil.d('Error getting language: $e');
      }

      // 根据语言设置默认区号：西班牙语使用第二个（index 1），其他语言使用第一个（index 0）
      final defaultIndex = currentLang == 'es' ? 1 : 0;
      if (defaultIndex < Constant.COUNTRY_CODES.length) {
        countryCode.value = Constant.COUNTRY_CODES[defaultIndex];
      } else {
        countryCode.value = Constant.COUNTRY_CODES.first;
      }
    }
  }

  Future<void> selectCountryCode(String code) async {
    if (Constant.COUNTRY_CODES.contains(code)) {
      countryCode.value = code;
      await UserDataHelper.saveCountry(code);
    }
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    phoneController.removeListener(_handlePhoneNumberChange);
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    String? savedPhoneNumber = await UserDataHelper.getPhoneNumber();
    if (savedPhoneNumber != null && savedPhoneNumber.isNotEmpty) {
      phoneController.text = savedPhoneNumber;
      phoneLength.value = savedPhoneNumber.length;
    }
  }

  void _handlePhoneNumberChange() {
    final newPhoneNumber = phoneController.text.trim();
    if (newPhoneNumber != phoneNumber.value) {
      otpCountdown.value = 'retrieveOtp'.tr;
      _otpTimer?.cancel();
      phoneNumber.value = newPhoneNumber;
    } else if (newPhoneNumber != phoneNumber.value) {
      phoneNumber.value = newPhoneNumber;
    }
  }

  Future<void> sendOtp() async {
    if (isSendingOtp.value) return;

    isSendingOtp.value = true;
    final String phone = phoneController.text.trim();
    if (phone.isEmpty) {
      isSendingOtp.value = false;
      phoneNumber.value = phone;
      YDToast.text('pleaseEnterPhoneNumber'.tr);
      return;
    }
    if (!Validators.isValidPhoneNumber(phone)) {
      isSendingOtp.value = false;
      YDToast.text('invalidPhoneNumber'.tr);
      return;
    }
    // YDToast.loading();
    AppsFlyerHelper().eventRegisterApply(
      body: jsonEncode({
        "type": 'phone',
        "phone": '${countryCode.value}|$phone',
      }),
    );
    try {
      final result = await ApiUrls.postSendVerifyCode(
        type: 'phone',
        phone: '${countryCode.value}|$phone',
      );
      // YDToast.cleanAll();
      AppsFlyerHelper().eventRegisterApplyResult(
        msg: jsonEncode({
          "data": result.data,
          "state": result.code,
          "statusMsg": result.msg,
        }),
      );
      if (result.isSucceed) {
        otpCountdown.value = '60s';
        isSendingOtp.value = false;
        YDToast.text('otpSentSuccessfully'.tr);
        _startOtpTimer();
      } else {
        isSendingOtp.value = false;
        YDToast.text(result.msg != "" ? result.msg : 'errorSendingOtp'.tr);
      }
    } catch (e) {
      isSendingOtp.value = false;
      AppsFlyerHelper().eventRegisterErr(msg: e.toString());
      LogUtil.d('catch-Error:$e');
    }
  }

  void _startOtpTimer() {
    _otpCountdownTime = 60;
    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_otpCountdownTime == 0) {
        otpCountdown.value = '  ${'retrieveOtp'.tr}  ';
        timer.cancel();
      } else {
        otpCountdown.value = '${_otpCountdownTime--}s';
      }
    });
  }

  Future<void> registerOrLogin() async {
    if (!isPrivacyAgreed.value) {
      YDToast.text('pleaseAgreeToTerms'.tr);
      return;
    }

    final String otp = otpController.text.trim();
    final String phone = phoneController.text.trim();
    if (phone.isEmpty || otp.isEmpty) {
      YDToast.text('pleaseEnterPhoneAndOtp'.tr);
      return;
    }
    if (!Validators.isValidPhoneNumber(phone)) {
      YDToast.text('pleaseEnterPhoneNumber'.tr);
      return;
    }
    if (otp.length != 4) {
      YDToast.text('pleaseEnter4DigitCode'.tr);
      return;
    }

    YDToast.loading();
    AppsFlyerHelper().eventOtpApply(
      body: jsonEncode({"otp": otp, "phone": '${countryCode.value}|$phone'}),
    );
    try {
      final result = await ApiUrls.postLoginOrRegister(
        phone: phone,
        authCode: otp,
        onlyLogin: 0,
        countryCode: countryCode.value,
      );
      AppsFlyerHelper().eventOtpApplyResult(
        msg: jsonEncode({
          "data": result.data,
          "state": result.code,
          "statusMsg": result.msg,
        }),
      );
      if (result.isSucceed && result.data?["token"] != "") {
        final userData = result.data;
        await UserDataHelper.saveUserData(
          phone,
          userData?['token'],
          userData?['userId'],
          userData?['cacheData'],
        );

        LogUtil.d("---- ${userData}");
        AppsFlyerHelper().setCustomerUserId(
          Md5.stringToMd5(' ${countryCode.value}|$phone'),
        );
        //开始上报
        UpDataServer().triggerSingleReport();
        if (userData?['isFirstRegister'] == 1) {
          AppsFlyerHelper().eventRegisterSuccess();
        }
        if (userData?['isAuditAccount'] == 1) {
          YDToast.cleanAll();
          YDToast.text('accountUnderReview'.tr);
          Get.toNamed(Routes.contact);
        } else {
          final progressResponse = await ApiUrls.getAcquisitionProgress();
          YDToast.cleanAll();
          if (!progressResponse.isSucceed) {
            YDToast.text(
              progressResponse.msg != ""
                  ? progressResponse.msg
                  : 'unknownErrorMsg'.tr,
            );
            return;
          }
          final filledStep = progressResponse.data?["filledStep"] ?? 0;
          final totalStep = progressResponse.data?["totalStep"] ?? 0;
          Get.offAllNamed(filledStep < totalStep ? Routes.kyc : Routes.home);
        }
      } else {
        YDToast.cleanAll();
        YDToast.text("${result.msg}");
      }
    } catch (e) {
      // YDToast.text("catch-Error:$e");
      // YDToast.text("${'loginFailed'.tr}");
      AppsFlyerHelper().eventRegisterErr(msg: e.toString());
      LogUtil.d('catch-Error:$e');
    }
  }
}
