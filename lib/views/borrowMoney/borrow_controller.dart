import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/common/toast.dart';
import 'package:flutter3APP/provider/userDataHelper.dart';
import 'package:flutter3APP/common/logger/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../models/home_page_data.dart';
import '../../../http/api_urls.dart';
import '../../common/permission/permission_util.dart';
import '../../../routes/routes.dart';
import '../../basa/updateData/user_updata_server.dart';

class BorrowController extends GetxController {
  var selectedProducts = <Product>[].obs;
  final homePageData = HomePageDetails().obs;
  var countdownSeconds = 0.obs;
  Timer? countdownTimer;
  var hasClickedManually = false.obs;
  var cacheFlag = 0.obs;

  var isAutoLoan = false.obs;

  // New: control visibility of bottom countdown
  var showBottomCountdown = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData(isloding: true);
    checkFirstVisitAndStartCountdown();
  }

  @override
  void onClose() {
    countdownSeconds.value = 0;
    if (countdownTimer != null) {
      countdownTimer?.cancel();
    }
    super.onClose();
  }

  Future<void> checkFirstVisitAndStartCountdown() async {
    await _getCacheData();
    if (isAutoLoan.value) {
      startCountdown();
    }
  }

  void refreshData({isloding = false}) {
    fetchDataWithLoading(isloding);
  }

  Future<void> fetchDataWithLoading(isloding) async {
    if (isloding) {
      YDToast.loading();
    }
    try {
      final result = await ApiUrls.fetchHomePageData();
      YDToast.cleanAll();
      homePageData.value = HomePageDetailsMapper.fromMap(result.data!);
      homePageData.refresh();
      // 根据新的数据结构，直接从confirmData中获取产品列表
      if (homePageData.value.confirmData?.autoLoan == 1) {
        isAutoLoan.value = true;
      }

      List<Product> newSelectedProducts = [];
      final details = homePageData.value;

      // 从confirmData中获取产品列表
      List<Product>? productList = details.confirmData?.list;

      if (productList != null) {
        newSelectedProducts = productList.where((p) => p.productStatus == 0).toList();
      }

      selectedProducts.assignAll(newSelectedProducts);

      // Setup bottom countdown from backend countDownTime
      if (countdownTimer != null) {
        countdownTimer?.cancel();
      }
      hasClickedManually.value = false;
      countdownSeconds.value = details.confirmData?.countDownTime ?? 0;
      showBottomCountdown.value = (countdownSeconds.value > 0) && selectedProducts.isNotEmpty;
      if (showBottomCountdown.value) {
        startCountdown();
      }
    } catch (e) {
      LogUtil.d(e.toString());
    }
  }

  void startCountdown() {
    if (countdownTimer != null) {
      countdownTimer?.cancel();
    }
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (hasClickedManually.value) {
        timer.cancel();
        return;
      }
      if (!showBottomCountdown.value) {
        timer.cancel();
        return;
      }
      countdownSeconds.value--;
      if (countdownSeconds.value <= 0) {
        timer.cancel();
        await _onCountdownFinished();
      }
    });
  }

  Future<void> _onCountdownFinished() async {
    showBottomCountdown.value = false;
    if (countdownTimer != null) {
      countdownTimer?.cancel();
    }
    await fetchDataWithLoading(false);
  }

  Future<int?> _getCacheData() async {
    cacheFlag.value = await UserDataHelper.getCacheData();
    return cacheFlag.value;
  }

  Future<void> markAsVisited() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasVisitedFirstHomePage', true);
  }

  Future<bool> checkPermissions() async {
    var hasLocation = await PermissionUtil.checkAndRequest(Permission.location);
    return hasLocation;
  }

  Future<void> handleButtonClick() async {
    if (selectedProducts.isEmpty) return;

    bool hasPermissions = await checkPermissions();
    if (cacheFlag.value == 0) {
      if (!hasPermissions) {
        PermissionUtil.showPermissionDialog(Permission.location);
        return;
      }
    }
    UpDataServer().triggerSingleReport();
    Get.toNamed(
      Routes.loanConfirm,
      arguments: {
        // 'isResetCountDownTime': 1,
        'selectedProducts': selectedProducts,
      },
    );
    markAsVisited();
  }

  void handleButtonTap() async {
    await handleButtonClick();
  }

  // New: cancel auto disburse
  void cancelAutoDisburse() {
    showBottomCountdown.value = false;
    if (countdownTimer != null) {
      countdownTimer?.cancel();
    }
  }

  // New: show confirm to cancel auto disburse and call API
  void showCancelAutoDisburseDialog() {
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('autoDisburseTip'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('autoDisburseCancel'.tr),
        actions: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  ),
                  child: Text('cancel'.tr, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await _removeAutoLoanAndRefresh();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  ),
                  child: Text('confirm'.tr, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeAutoLoanAndRefresh() async {
    try {
      final productCodes = selectedProducts
          .where((p) => p.productStatus == 0)
          .map((p) => p.productCode)
          .whereType<String>()
          .toList();
      YDToast.loading();
      final result = await ApiUrls.removeAutoLoan(productCodes: productCodes);
      YDToast.cleanAll();
      if (result.isSucceed) {
        YDToast.text('cancelSuccess'.tr);
        cancelAutoDisburse();
        await fetchDataWithLoading(false);
      } else {
        YDToast.text(result.msg);
      }
    } catch (e) {
      LogUtil.d('removeAutoLoan error: $e');
    } finally {}
  }
}
