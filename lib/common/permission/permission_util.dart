import 'package:synchronized/synchronized.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../l10n/app_strings.dart';

class PermissionUtil {
  static final Lock _lock = Lock();
  static final Map<Permission, Future<bool>?> _requestingFutures = {};

  static Future<bool> checkAndRequest(Permission p) async {
    return await _lock.synchronized(() async {
      if (_requestingFutures[p] != null) {
        return await _requestingFutures[p]!;
      }
      final completer = Completer<bool>();
      _requestingFutures[p] = completer.future;
      try {
        var status = await p.status;
        if (!status.isGranted) {
          status = await p.request();
        }
        completer.complete(status.isGranted);
        return status.isGranted;
      } catch (e) {
        completer.complete(false);
        rethrow;
      } finally {
        _requestingFutures.remove(p);
      }
    });
  }

  /// 显示权限弹框提示
  /// [permission] 权限类型
  static void showPermissionDialog(Permission permission) {
    String title = AppStrings.permissionRequired;
    String content = "";
    String cancelText = AppStrings.cancel;
    String settingsText = AppStrings.goToSettings;

    // 根据不同的权限类型设置不同的提示内容
    switch (permission) {
      case Permission.camera:
        content = AppStrings.cameraPermissionRequired;
        break;
      case Permission.microphone:
        content = AppStrings.microphonePermissionRequired;
        break;
      case Permission.storage:
        content = AppStrings.storagePermissionRequired;
        break;
      case Permission.location:
        content = AppStrings.locationPermissionRequiredDialog;
        break;
      case Permission.phone:
        content = AppStrings.phonePermissionRequired;
        break;
      case Permission.sms:
        content = AppStrings.smsPermissionRequired;
        break;
      case Permission.contacts:
        content = AppStrings.contactsPermissionRequired;
        break;
      case Permission.photos:
        content = AppStrings.photosPermissionRequired;
        break;
      case Permission.notification:
        content = AppStrings.notificationPermissionRequired;
        break;
      default:
        content = AppStrings.generalPermissionRequired;
        break;
    }

    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(settingsText),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
