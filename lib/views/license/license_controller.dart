import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/l10n/app_strings.dart';
import 'package:flutter3APP/basa/main_constant.dart';
import 'package:flutter3APP/routes/routes.dart';

class LicenseController extends GetxController {
  // 权限数据
  final List<Map<String, String>> permissions = Platform.isIOS?[
    {'title': Constant.locationTitle, 'description': Constant.locationDesc},
    {'title': Constant.cameraTitle, 'description': Constant.cameraDesc},
    {'title': Constant.mobileTitle, 'description': Constant.mobileDesc},
    {'title': Constant.inAppTitle, 'description': Constant.inAppDesc},
  ]:[
    {'title': Constant.locationTitle, 'description': Constant.locationDesc},
    {'title': Constant.cameraTitle, 'description': Constant.cameraDesc},
    {'title': Constant.smsTitle, 'description': Constant.smsDesc},
    {'title': Constant.appListTitle, 'description': Constant.appListDesc},
    {'title': Constant.mobileTitle, 'description': Constant.mobileDesc},
    {'title': Constant.inAppTitle, 'description': Constant.inAppDesc},
  ];

  // 显示退出确认对话框
  Future<bool> showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await Get.dialog<bool>(
      AlertDialog(
        title: Text(AppStrings.exitApplication),
        content: Text(AppStrings.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(AppStrings.ok),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  // 处理返回按钮点击
  Future<void> handleBackButtonPress(BuildContext context) async {
    final shouldExit = await showExitConfirmationDialog(context);
    if (shouldExit) {
      exit(0);
    }
  }

  // 处理拒绝按钮点击
  Future<void> handleRejectButtonPress(BuildContext context) async {
    final shouldExit = await showExitConfirmationDialog(context);
    if (shouldExit) {
      exit(0);
    }
  }

  // 处理同意按钮点击
  void handleAgreeButtonPress(BuildContext context) {
    Get.offAllNamed(Routes.privacy);
  }
}
