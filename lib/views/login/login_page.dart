import 'dart:io';
import 'package:flutter3APP/utils/widget/widget.dart';

import '../../basa/main_constant.dart';
import '../../basa/country_config_helper.dart';
import '../../common/colors/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import '../../utils/non_repeatable_click.dart';
import '../../provider/userDataHelper.dart';
import 'login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1), // 浅黄色背景
              Color(0xFFFFFFFF), // 白色
            ],
            stops: [0.0, 0.9],
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // 顶部装饰区域和主标题
                Container(
                  height: 160,
                  child: Stack(
                    children: [
                      // 背景装饰圆形
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                Get.toNamed(Routes.contact);
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/images/icon_service_two.webp',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 主标题和副标题
                      Positioned(
                        top: 70,
                        left: 20,
                        right: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'fastApprovalQuickDisbursement'.tr,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'getApprovedInMinutesCashOutFast'.tr,
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(bottom: 10),
                //   child: Align(
                //     alignment: Alignment.center,
                //     child: ClipRRect(
                //       borderRadius: BorderRadius.circular(20),
                //       child: Image.asset(
                //         'assets/images/logo_app.png',
                //         height: 80 ,
                //         width: 80 ,
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 标题区域
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'phoneLogin'.tr,
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'enterPhoneNumberToLogin'.tr,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 25),

                                // 手机号输入框
                                _buildPhoneInputField(),
                                SizedBox(height: 20),

                                // 验证码输入框和发送按钮
                                Row(
                                  children: [
                                    Expanded(child: _buildOtpInputField()),
                                    SizedBox(width: 15),
                                    SizedBox(
                                      width: 130,
                                      child: Obx(
                                        () =>
                                            Container(
                                              height: 55,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                gradient:
                                                    controller
                                                        .isSendingOtp
                                                        .value
                                                    ? null
                                                    : LinearGradient(
                                                        colors: [
                                                          AppColors
                                                              .primaryColor,
                                                          AppColors.primaryColor
                                                              .withOpacity(0.9),
                                                        ],
                                                        begin: Alignment
                                                            .centerLeft,
                                                        end: Alignment
                                                            .centerRight,
                                                      ),
                                                color:
                                                    controller
                                                        .isSendingOtp
                                                        .value
                                                    ? AppColors
                                                          .textBackgroundColor
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border:
                                                    controller
                                                        .isSendingOtp
                                                        .value
                                                    ? Border.all(
                                                        color: AppColors
                                                            .primaryColor
                                                            .withOpacity(0.3),
                                                        width: 1.5,
                                                      )
                                                    : null,
                                                boxShadow:
                                                    controller
                                                        .isSendingOtp
                                                        .value
                                                    ? null
                                                    : [
                                                        BoxShadow(
                                                          color: AppColors
                                                              .primaryColor
                                                              .withOpacity(
                                                                0.25,
                                                              ),
                                                          blurRadius: 15,
                                                          offset: Offset(0, 4),
                                                          spreadRadius: 0,
                                                        ),
                                                        BoxShadow(
                                                          color: AppColors
                                                              .primaryColor
                                                              .withOpacity(0.1),
                                                          blurRadius: 6,
                                                          offset: Offset(0, 2),
                                                          spreadRadius: 0,
                                                        ),
                                                      ],
                                              ),
                                              child:
                                                  controller.isSendingOtp.value
                                                  ? SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: AppColors
                                                                .primaryColor,
                                                            strokeWidth: 2.5,
                                                          ),
                                                    )
                                                  : Text(
                                                      controller
                                                          .otpCountdown
                                                          .value,
                                                      style: TextStyle(
                                                        color:
                                                            controller
                                                                .isSendingOtp
                                                                .value
                                                            ? AppColors
                                                                  .primaryColor
                                                            : Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                            ).onTap(() {
                                              NonRepeatableClick.checkClick(
                                                debounceDuration:
                                                    const Duration(seconds: 2),
                                                click: () async {
                                                  if (!controller
                                                      .isSendingOtp
                                                      .value) {
                                                    controller.sendOtp();
                                                  }
                                                },
                                              );
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 35),

                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    height: 55,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryColor,
                                          AppColors.primaryColor.withOpacity(
                                            0.9,
                                          ),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.25),
                                          blurRadius: 20,
                                          offset: Offset(0, 4),
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: () {
                                          FocusScope.of(Get.context!).unfocus();
                                          controller.registerOrLogin();
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'continueText'.tr,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 25),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () =>
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color:
                                              controller.isPrivacyAgreed.value
                                              ? AppColors.primaryColor
                                              : Colors.transparent,
                                          border: Border.all(
                                            color:
                                                controller.isPrivacyAgreed.value
                                                ? AppColors.primaryColor
                                                : AppColors.textSecondary
                                                      .withOpacity(0.6),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          boxShadow:
                                              controller.isPrivacyAgreed.value
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors
                                                        .primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: Offset(0, 2),
                                                    spreadRadius: 0,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: controller.isPrivacyAgreed.value
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ).onTap(() {
                                        controller.isPrivacyAgreed.value =
                                            !controller.isPrivacyAgreed.value;
                                      }),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: GestureDetector(
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'iHaveReadAndAgree'.tr,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '《${'privacyPolicy'.tr}》',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  AppColors.cardBackgroundColor,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () async {
                                                Get.toNamed(
                                                  Routes.privacyPolicy,
                                                );
                                              },
                                          ),
                                          if (Theme.of(context).platform ==
                                              TargetPlatform.iOS)
                                            TextSpan(
                                              text: '《${'termsOfService'.tr}》',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors
                                                    .cardBackgroundColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  final countryCode =
                                                      await UserDataHelper.getCountry();
                                                  final url = Platform.isIOS
                                                      ? CountryConfigHelper.getTermServiceUrl(
                                                          countryCode,
                                                        )
                                                      : "";
                                                  Get.toNamed(
                                                    Routes.privacyPolicy,
                                                    arguments: {"url": url},
                                                  );
                                                },
                                            ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 国家代码区域 - 可点击选择
          Obx(() {
            final imageName = CountryConfigHelper.getCountryCodeImage(
              controller.countryCode.value,
            );
            final imagePath = 'assets/images/$imageName';
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  FocusScope.of(Get.context!).unfocus();
                  _showCountryCodePicker(Get.context!);
                },
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(imagePath, width: 20, height: 14),
                      SizedBox(width: 6),
                      Text(
                        '+${controller.countryCode.value}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // 分隔线
          Container(
            height: 20,
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.primaryColor.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // 手机号输入框
          Expanded(
            child: Container(
              height: 55,
              alignment: Alignment.centerLeft,
              child: TextField(
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.done,
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  height: 1.0,
                ),
                decoration: InputDecoration(
                  hintText: 'phoneNumber'.tr,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 0,
                  ),
                  counterText: '',
                  isDense: true,
                ),
                maxLength: 9,
                onChanged: (value) {
                  // 更新手机号长度
                  controller.phoneLength.value = value.length;

                  if (value.startsWith('0') && value.length == 9) {
                    final trimmed = value.replaceFirst(RegExp(r'^0+'), '');
                    controller.phoneController.text = trimmed;
                    controller.phoneController.selection =
                        TextSelection.collapsed(offset: trimmed.length);
                    controller.phoneLength.value = trimmed.length;
                    return; // 让下一次 onChanged 触发后再继续后续逻辑
                  }
                  // 当输入达到9位时自动获取验证码
                  if (value.length == 9) {
                    FocusScope.of(Get.context!).unfocus();
                    if (!controller.isSendingOtp.value) {
                      controller.sendOtp();
                    }
                  }
                },
                onSubmitted: (value) {
                  FocusScope.of(Get.context!).unfocus();
                },
              ),
            ),
          ),

          // 位数显示 - 放在右侧
          Obx(
            () => Container(
              margin: EdgeInsets.only(right: 15),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: controller.phoneLength.value == 9
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : AppColors.textBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.phoneLength.value == 9
                      ? AppColors.primaryColor.withOpacity(0.3)
                      : AppColors.textSecondary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                '${controller.phoneLength.value}/9',
                style: TextStyle(
                  color: controller.phoneLength.value == 9
                      ? Colors.black
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputField() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller.otpController,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        maxLength: 4,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
        decoration: InputDecoration(
          hintText: 'enterOtp'.tr,
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          counterText: '',
        ),
        onChanged: (value) {
          if (value.length == 4) {
            FocusScope.of(Get.context!).unfocus();
            controller.registerOrLogin();
          }
        },
        onSubmitted: (value) {
          FocusScope.of(Get.context!).unfocus();
        },
      ),
    );
  }

  void _showCountryCodePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'selectCountryCode'.tr,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // 区号列表
              ...Constant.COUNTRY_CODES.asMap().entries.map((entry) {
                final code = entry.value;
                final imageName = CountryConfigHelper.getCountryCodeImage(code);
                final imagePath = 'assets/images/$imageName';
                return Obx(
                  () => Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.selectCountryCode(code);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: controller.countryCode.value == code
                              ? AppColors.primaryColor.withOpacity(0.1)
                              : Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(imagePath, width: 20, height: 14),
                                SizedBox(width: 12),
                                Text(
                                  '+$code',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            if (controller.countryCode.value == code)
                              Icon(
                                Icons.check,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}
