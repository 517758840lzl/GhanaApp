import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/routes/routes.dart';

class LicenseController extends GetxController {
  // 权限数据
  List<Map<String, String>> get permissions => Platform.isIOS ? [
    {'title': 'locationTitle'.tr, 'description': 'locationDesc'.tr},
    {'title': 'cameraTitle'.tr, 'description': 'cameraDesc'.tr},
    {'title': 'mobileTitle'.tr, 'description': 'mobileDesc'.tr},
    {'title': 'inAppTitle'.tr, 'description': 'inAppDesc'.tr},
  ] : [
    {'title': 'locationTitle'.tr, 'description': 'locationDesc'.tr},
    {'title': 'cameraTitle'.tr, 'description': 'cameraDesc'.tr},
    {'title': 'smsTitle'.tr, 'description': 'smsDesc'.tr},
    {'title': 'appListTitle'.tr, 'description': 'appListDesc'.tr},
    {'title': 'mobileTitle'.tr, 'description': 'mobileDesc'.tr},
    {'title': 'inAppTitle'.tr, 'description': 'inAppDesc'.tr},
  ];

  // 显示退出确认对话框
  Future<bool> showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await Get.dialog<bool>(
      AlertDialog(
        title: Text('exitApplication'.tr),
        content: Text('logoutConfirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('ok'.tr),
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
