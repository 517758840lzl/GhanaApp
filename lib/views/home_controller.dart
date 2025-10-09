import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter3APP/views/borrowMoney/borrow_controller.dart';
import 'package:flutter3APP/views/me/my_controller.dart';
import 'package:flutter3APP/views/repayMoney/repayment_controller.dart';
import '../common/logger/app_logger.dart';
import '../common/permission/permission_util.dart';
import 'package:permission_handler/permission_handler.dart';
import '../http/api_urls.dart';
import '../common/toast.dart';
import '../models/loan_reject_info.dart';
import '../models/pop_config.dart';
import '../provider/app_state.dart';
import '../l10n/app_strings.dart';
import 'package:get/get.dart';
import '../routes/routes.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  DateTime? lastRefreshTime;
  late List<Widget> pages;
  int _lastRequestTimestamp = 0;
  final int _requestCooldown = 3000;

  void setPages(List<Widget> pageList) {
    pages = pageList;
  }

  void onTabTapped(int index) {
    selectedIndex.value = index;
    refreshWithCooldown(refreshWithPage);
  }

  void refreshWithPage() {
    switch (selectedIndex.value) {
      case 0:
        Get.find<BorrowController>().refreshData();
        break;
      case 1:
        Get.find<RepaymentController>().refreshData();
        break;
      case 2:
        Get.find<MyController>().loadCachedData();
        break;
    }
  }

  void refreshWithCooldown(void Function()? refreshFunction) {
    final now = DateTime.now();
    if (lastRefreshTime != null &&
        now.difference(lastRefreshTime!).inSeconds < 2) {
      return;
    }
    lastRefreshTime = now;
    refreshFunction?.call();
  }

  Future<void> requestLocationPermission(
    BuildContext context,
    void Function()? onDenied,
  ) async {
    var hasLocation = await PermissionUtil.checkAndRequest(Permission.location);
    if (!hasLocation && onDenied != null) {
      onDenied();
    }
  }

  Future<PopConfigData?> getPopConfig(int? type) async {
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (currentTimestamp - _lastRequestTimestamp < _requestCooldown) {
      return null;
    }
    try {
      _lastRequestTimestamp = currentTimestamp;
      final result = await ApiUrls.getPopConfig(type: type);
      if (result.isSucceed && result.data != null) {
        final mapped = PopConfigDataMapper.fromMap(result.data ?? {});
        return mapped;
      } else {
        LogUtil.d('Error: \\${result.msg}');
      }
    } catch (e) {
      LogUtil.d('Exception: $e');
    }
    return null;
  }
}
