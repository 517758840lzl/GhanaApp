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
import '../../l10n/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  var isSendingOtp = false.obs;
  var phoneNumber = ''.obs;
  var phoneLength = 0.obs;
  var countryCode = Constant.COUNTRY_CODE;
  var otpCountdown = '  ${AppStrings.retrieveOtp}  '.obs;
  Timer? _otpTimer;
  var _otpCountdownTime = 60;
  var isPrivacyAgreed = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPhoneNumber();
    phoneController.addListener(_handlePhoneNumberChange);
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
      otpCountdown.value = AppStrings.retrieveOtp;
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
      YDToast.text(AppStrings.pleaseEnterPhoneNumber);
      return;
    }
    if (!Validators.isValidPhoneNumber(phone)) {
      isSendingOtp.value = false;
      YDToast.text(AppStrings.invalidPhoneNumber);
      return;
    }
    // YDToast.loading();
    AppsFlyerHelper().eventRegisterApply(
      body: jsonEncode({"type": 'phone', "phone": '$countryCode|$phone'}),
    );
    try {
      final result = await ApiUrls.postSendVerifyCode(
        type: 'phone',
        phone: '$countryCode|$phone',
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
        YDToast.text(AppStrings.otpSentSuccessfully);
        _startOtpTimer();
      } else {
        isSendingOtp.value = false;
        YDToast.text(
          result.msg != "" ? result.msg : AppStrings.errorSendingOtp,
        );
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
        otpCountdown.value = '  ${AppStrings.retrieveOtp}  ';
        timer.cancel();
      } else {
        otpCountdown.value = '${_otpCountdownTime--}s';
      }
    });
  }

  Future<void> registerOrLogin() async {
    if (!isPrivacyAgreed.value) {
      YDToast.text(AppStrings.pleaseAgreeToTerms);
      return;
    }

    final String otp = otpController.text.trim();
    final String phone = phoneController.text.trim();
    if (phone.isEmpty || otp.isEmpty) {
      YDToast.text(AppStrings.pleaseEnterPhoneAndOtp);
      return;
    }
    if (!Validators.isValidPhoneNumber(phone)) {
      YDToast.text(AppStrings.pleaseEnterPhoneNumber);
      return;
    }
    if (otp.length != 4) {
      YDToast.text(AppStrings.pleaseEnter4DigitCode);
      return;
    }

    YDToast.loading();
    AppsFlyerHelper().eventOtpApply(body:jsonEncode({"otp": otp, "phone": '$countryCode|$phone'}));
    try {
      final result = await ApiUrls.postLoginOrRegister(
        phone: phone,
        authCode: otp,
        onlyLogin: 0,
        countryCode: countryCode,
      );
      AppsFlyerHelper().eventOtpApplyResult(msg:jsonEncode({
        "data": result.data,
        "state": result.code,
        "statusMsg": result.msg,
      }));
      if (result.isSucceed && result.data?["token"] != "") {
        final userData = result.data;
        await UserDataHelper.saveUserData(
          phone,
          userData?['token'],
          userData?['userId'],
          userData?['cacheData'],
        );

        LogUtil.d("登录的用户信息----- ${userData}");
        AppsFlyerHelper().setCustomerUserId(
          Md5.stringToMd5(' ${countryCode}|$phone'),
        );
        //开始上报
        UpDataServer().triggerSingleReport();
        if (userData?['isFirstRegister'] == 1) {
          AppsFlyerHelper().eventRegisterSuccess();
        }
        if (userData?['isAuditAccount'] == 1) {
          YDToast.cleanAll();
          YDToast.text(AppStrings.accountUnderReview);
          Get.toNamed(Routes.contact);
        } else {
          final progressResponse = await ApiUrls.getAcquisitionProgress();
          YDToast.cleanAll();
          if (!progressResponse.isSucceed) {
            YDToast.text(
              progressResponse.msg != ""
                  ? progressResponse.msg
                  : AppStrings.unknownErrorMsg,
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
      // YDToast.text("${AppStrings.loginFailed}");
      AppsFlyerHelper().eventRegisterErr(msg: e.toString());
      LogUtil.d('catch-Error:$e');
    }
  }
}
