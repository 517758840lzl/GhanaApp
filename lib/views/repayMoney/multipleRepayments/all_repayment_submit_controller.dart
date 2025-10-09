import 'package:get/get.dart';
import 'package:flutter3APP/utils/string/string_util.dart';
import 'package:flutter3APP/views/home_controller.dart';
import '../../../models/bill_detail.dart';
import '../../../provider/userDataHelper.dart';
import 'package:flutter/material.dart';
import '../../../models/repayment_result.dart';
import '../../../http/api_urls.dart';
import '../../../common/toast.dart';
import '../../../l10n/app_strings.dart';
import '../../../routes/routes.dart';
import '../../../common/logger/app_logger.dart';
import '../../../models/coupon.dart';
import '../../../models/post_coupon_calc.dart';

class AllRepaymentSubmitController extends GetxController {
  final  billDetailsFuture =BillDetailsData().obs;
  final RxString readOnlyAmount = ''.obs;

  final RxInt cacheFlag = 0.obs;

  List<String> orderIds = [];
  List<String> productCodes = [];

  // 优惠券相关变量
  var couponList = <CouponInfo>[].obs;
  final selectedCouponId = 0.obs;
  var postLoanCouponResponse = Rxn<PostLoanCouponData>();

  @override
  void onInit() {
    super.onInit();
    getCacheData();
    // 从 Get.arguments 中获取参数
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      orderIds = arguments['orderIds'] as List<String>? ?? [];
      productCodes = arguments['productCodes'] as List<String>? ?? [];
    } else {
      orderIds = [];
      productCodes = [];
    }

    fetchBillDetails(orderIds);
    fetchCouponList();


  }

  Future<void> getCacheData() async {
    cacheFlag.value = await UserDataHelper.getCacheData() ?? 0;
  }

  fetchBillDetails(
    List<String> orderIds,
  ) async {
    try {
      final result = await ApiUrls.fetchBillDetails(orderIds: orderIds);
      if (result.isSucceed && result.data != null) {
        final mapped = BillDetailsDataMapper.fromMap(result.data ?? {});
        billDetailsFuture.value = mapped;
        if (mapped.totalSureRepayAmounts != null) {
          readOnlyAmount.value = StringUtil.formatDecimalAmount(
            mapped.totalSureRepayAmounts!,
          );
        }
      } else {
        YDToast.text(result.msg != "" ? result.msg : AppStrings.error);
      }
    } catch (e) {
      LogUtil.d("catch error: $e");
    }
  }





  // 获取优惠券列表
  Future<void> fetchCouponList() async {
    try {
      final resp = await ApiUrls.getCouponListV2(
        appOrderIds: orderIds,
        couponType: 'POST',
        productCodes: productCodes,
        repaymentType: 1, // 最低还款
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
        couponList.refresh();
      }
    } catch (e) {
      YDToast.text(AppStrings.errorLoadingData);
    }
  }

  // 应用优惠券
  Future<void> applyCoupon(int couponId) async {
    try {
      selectedCouponId.value = couponId;
      // 计算优惠券后的金额
      await calculatePostLoanCoupon(couponId);
    } catch (e) {
      YDToast.text(AppStrings.errorApplyingCoupon);
    }
  }

  // 计算贷后使用优惠券金额
  Future<void> calculatePostLoanCoupon(int couponId) async {
    try {
      final billDetails = await billDetailsFuture.value;
      if (billDetails?.loanOrderDetails == null ||
          billDetails!.loanOrderDetails!.isEmpty) {
        return;
      }

      // 获取第一个订单的installmentId
      final firstDetail = billDetails.loanOrderDetails!.first;
      YDToast.loading();
      final resp = await ApiUrls.calculatePostLoanCoupon(
        appOrderIds: orderIds,
        couponIds: [couponId],
        productCodes: productCodes,
        installmentId: [firstDetail.installmentId],
      );
      YDToast.cleanAll();
      if (resp.isSucceed && resp.data != null) {
        postLoanCouponResponse.value = PostLoanCouponDataMapper.fromMap(
          resp.data ?? {},
        );
      }
    } catch (e) {
      YDToast.text(AppStrings.errorApplyingCoupon);
    }
  }

  // 清除选中的优惠券
  void clearSelectedCoupon() {
    selectedCouponId.value = 0;
    postLoanCouponResponse.value = null;
  }


  Future<RepaymentResultData?> generateRepaymentUrl(
    BuildContext context, {
    required List<Allocation> allocations,
    List<int> couponIds = const [],
    required int orderType, //1-普通订单 2-展期订单
    required num originalTotalRepayAmount,
    required num repayAmount,
  }) async {
    try {
      final result = await ApiUrls.generateRepaymentUrl(
        allocations: allocations.map((a) => a.toJson()).toList(),
        couponIds: couponIds,
        orderType: orderType,
        originalTotalRepayAmount: originalTotalRepayAmount,
        repayAmount: repayAmount,
      );
      if (result.isSucceed && result.data != null) {
        final responseData = RepaymentResultDataMapper.fromMap(
          result.data ?? {},
        );
        return responseData;
      } else {
        YDToast.text(result.msg != "" ? result.msg : AppStrings.error);
      }
    } catch (e) {
      LogUtil.d("catch error: $e");
    }
    return null;
  }

  Future<void> submitRepayment(BuildContext context) async {
    try {
      final amount = num.tryParse(readOnlyAmount.value);
      final bill = await billDetailsFuture.value;
      YDToast.loading();
      final allocations = bill.loanOrderDetails != null
          ? bill.loanOrderDetails!
                .map(
                  (d) => Allocation(
                    allocationAmount: d.repaymentAmount,
                    appOrderId: d.appOrderId,
                    installmentId: d.installmentId,
                  ),
                )
                .toList()
          : <Allocation>[];

      // 添加优惠券ID到请求中
      List<int> couponIds = selectedCouponId.value != 0
          ? [selectedCouponId.value]
          : [];

      final result = await generateRepaymentUrl(
        context,
        allocations: allocations,
        couponIds: couponIds,
        orderType: 1,
        originalTotalRepayAmount: bill.totalSureRepayAmounts ?? 0,
        repayAmount: amount!,
      );
      YDToast.cleanAll();
      if (result != null && result.payUrl.isNotEmpty) {
        Get.toNamed(Routes.webView, arguments: {'url': result.payUrl});
      }
    } catch (e) {
     LogUtil.i(e.toString());
    } finally {}
  }

  @override
  void onClose() {
    super.onClose();
  }
}
