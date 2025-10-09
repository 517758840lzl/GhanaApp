import 'package:get/get.dart';
import 'package:flutter3APP/models/repayment_result.dart';
import 'package:flutter3APP/views/home_controller.dart';
import '../../../common/toast.dart';
import '../../../models/extension.dart';
import '../../../models/coupon.dart';
import '../../../models/post_coupon_calc.dart';
import '../../../provider/userDataHelper.dart';
import '../../../http/api_urls.dart';
import '../../../l10n/app_strings.dart';
import '../../../routes/routes.dart';
import '../../../views/widgets/extension_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExtensionRequestController extends GetxController {
  var extensionInfo = Rxn<ExtensionInfoData>();
  var couponList = <CouponInfo>[].obs;
  var selectedCouponId = RxnInt();
  // var postLoanCouponResponse = Rxn<PostLoanCouponData>();
  var cacheFlag = 0.obs;

  int installmentId = 0;
  String appOrderId = "";

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};
    if (args != {}) {
      installmentId = args['installmentId'] ?? 0;
      appOrderId = args['appOrderId'] ?? "";
      fetchExtensionInfo();
      fetchCouponList();
    }
    _getCacheData();
  }

  Future<void> _getCacheData() async {
    cacheFlag.value = await UserDataHelper.getCacheData() ?? 0;
  }

  Future<void> fetchExtensionInfo({List<int>? couponIds}) async {
    YDToast.loading();
    try {
      final result = await ApiUrls.applyExtension(
        couponIds: couponIds?.map((e) => e.toString()).toList() ?? [],
        installmentId: installmentId,
      );
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        extensionInfo.value = ExtensionInfoDataMapper.fromMap(
          result.data ?? {},
        );
      }
    } catch (e) {
      YDToast.cleanAll();
      YDToast.text(AppStrings.errorLoadingData);
    }
  }

  Future<void> fetchCouponList() async {
    try {
      final resp = await ApiUrls.getCouponListV2(
        appOrderIds: [appOrderId],
        couponType: 'POST',
        productCodes: [],
        repaymentType: 2,
      );
      if (resp.isSucceed && resp.data != null) {
        final coupons =
            (resp.data!['coupons'] as List?)
                ?.map((e) => CouponInfoMapper.fromMap(e))
                .where(
                  (product) => product.status == 0 && product.type == "POST",
                )
                .toList() ??
            [];
        couponList.assignAll(coupons);
      }
    } catch (e) {
      YDToast.text(AppStrings.errorLoadingData);
    }
  }

  Future<void> applyCoupon(int couponId) async {
    try {
      await fetchExtensionInfo(couponIds: [couponId]);
      selectedCouponId.value = couponId;

      // // 计算优惠券后的金额
      // await calculatePostLoanCoupon(couponId);
    } catch (e) {
      YDToast.text(AppStrings.errorApplyingCoupon);
    }
  }

  // Future<void> calculatePostLoanCoupon(int couponId) async {
  //   try {
  //     final resp = await ApiUrls.calculatePostLoanCoupon(
  //       appOrderIds: [appOrderId],
  //       couponIds: [couponId],
  //       productCodes: [],
  //       installmentId: [installmentId],
  //     );
  //     if (resp.isSucceed && resp.data != null) {
  //       postLoanCouponResponse.value = PostLoanCouponDataMapper.fromMap(
  //         resp.data ?? {},
  //       );
  //     }
  //   } catch (e) {
  //     YDToast.text(AppStrings.errorApplyingCoupon);
  //   }
  // }

  Future<void> onConfirmExtension() async {
    try {
      // 显示确认对话框
      final confirmed = await _showConfirmDialog();
      if (!confirmed) {
        return;
      }

      YDToast.loading();
      final allocations = [
        Allocation(
          allocationAmount: extensionInfo.value!.extensionFee,
          appOrderId: appOrderId,
          installmentId: installmentId,
        ),
      ];
      // 调用展期确认接口
      final result = await ApiUrls.generateRepaymentUrl(
        allocations: allocations.map((a) => a.toJson()).toList(),
        couponIds: selectedCouponId.value != null
            ? [selectedCouponId.value!]
            : [],
        orderType: 2,
        originalTotalRepayAmount: 0,
        repayAmount: extensionInfo.value!.extensionFee,
      );

      YDToast.cleanAll();

      if (result.isSucceed) {
        final responseData = RepaymentResultDataMapper.fromMap(
          result.data ?? {},
        );
        if (result.data != null && responseData.payUrl.isNotEmpty) {
          Get.toNamed(Routes.webView, arguments: {'url': responseData.payUrl});
        }
      } else {
        YDToast.text(result.msg);
      }
    } catch (e) {}
  }

  Future<bool> _showConfirmDialog() async {
    try {
      final result = await Get.dialog<bool>(
        ExtensionConfirmDialog(
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        ),
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
      );
      return result ?? false;
    } catch (e) {
      // 如果对话框显示失败，返回 false
      return false;
    }
  }

  void clearSelectedCoupon() {
    selectedCouponId.value = null;
    // postLoanCouponResponse.value = null;
    fetchExtensionInfo();
  }
}
