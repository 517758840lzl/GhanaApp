import 'package:get/get.dart';
import 'package:flutter3APP/utils/string/string_util.dart';
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
// import '../../../utils/formatter/number_formatter.dart';

class RepaymentSubmitController extends GetxController {
  final billDetailsFuture = BillDetailsData().obs;
  final RxString readOnlyAmount = ''.obs;
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();
  final minAmount = (0 as num).obs;
  final maxAmount = (0 as num).obs;
  final RxInt cacheFlag = 0.obs;
  final RxBool isAmountReadOnly = false.obs;
  List<String> orderIds = [];

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
      orderIds = arguments['orderIds'] ?? [];
    }
    fetchBillDetails();
    fetchCouponList();

    // 监听失去焦点事件
    amountFocusNode.addListener(() {
      if (!amountFocusNode.hasFocus) {
        onAmountFieldUnfocused();
      }
    });
  }

  Future<void> getCacheData() async {
    cacheFlag.value = await UserDataHelper.getCacheData();
  }

  Future<void> fetchBillDetails() async {
    YDToast.loading();
    try {
      final result = await ApiUrls.fetchBillDetails(orderIds: orderIds);
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        final data = BillDetailsDataMapper.fromMap(result.data ?? {});
        billDetailsFuture.value = data;
        final num minRaw = data.totalMinRepayAmounts ?? 0;
        final num maxRaw = data.totalSureRepayAmounts ?? 0;
        // 如果小数部分为 0，则转换为整数，移除无意义的小数
        minAmount.value = (minRaw % 1 == 0) ? minRaw.toInt() : minRaw;
        maxAmount.value = (maxRaw % 1 == 0) ? maxRaw.toInt() : maxRaw;
        if (maxAmount.value != 0) {
          amountController.text = StringUtil.formatDecimalAmount(
            maxAmount.value,
          );
          if (minAmount.value == maxAmount.value) {
            isAmountReadOnly.value = true;
          }
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
        productCodes: [],
        repaymentType: 1, // 全额还款
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
      amountController.text = StringUtil.formatDecimalAmount(maxAmount.value);
      // 计算优惠券后的金额
      await calculatePostLoanCoupon(couponId);
    } catch (e) {
      YDToast.text(AppStrings.errorApplyingCoupon);
    }
  }

  // 计算贷后使用优惠券金额
  Future<void> calculatePostLoanCoupon(int couponId) async {
    try {
      final billDetails = billDetailsFuture.value;
      if (billDetails.loanOrderDetails == null ||
          billDetails.loanOrderDetails!.isEmpty) {
        return;
      }

      // 获取第一个订单的installmentId
      final firstDetail = billDetails.loanOrderDetails!.first;
      YDToast.loading();
      final resp = await ApiUrls.calculatePostLoanCoupon(
        appOrderIds: orderIds,
        couponIds: [couponId],
        productCodes: [],
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

  void validateAmount() {
    final inputText = amountController.text.trim();

    // 如果输入为空，清除错误信息
    if (inputText.isEmpty) {
      return;
    }

    // 尝试解析金额
    final amount = num.tryParse(inputText.replaceAll(',', ''));
    if (amount == null) {
      return;
    }

    // 检查金额是否为负数
    if (amount < 0) {
      return;
    }

    // 检查金额精度（最多两位小数）
    if (amount.toString().contains('.') &&
        amount.toString().split('.')[1].length > 2) {
      return;
    }
  }

  // 处理失去焦点时的金额验证和调整
  void onAmountFieldUnfocused() {
    final inputText = amountController.text.trim();

    // 如果输入为空，不做处理
    if (inputText.isEmpty) {
      return;
    }

    // 尝试解析金额
    final amount = num.tryParse(inputText.replaceAll(',', ''));
    if (amount == null) {
      return;
    }

    // 处理金额范围限制
    if (minAmount.value != 0 && maxAmount.value != 0) {
      if (amount < minAmount.value) {
        // 如果低于最小金额，自动设置为最小金额
        amountController.text = StringUtil.formatDecimalAmount(minAmount.value);
        // 清除优惠券选择
        if (selectedCouponId.value != 0) {
          clearSelectedCoupon();
        }
      } else if (amount > maxAmount.value) {
        // 如果超过最大金额，自动设置为最大金额
        amountController.text = StringUtil.formatDecimalAmount(maxAmount.value);
      }
      if (amount != maxAmount.value && selectedCouponId.value != 0) {
        // 清除优惠券选择
        clearSelectedCoupon();
        YDToast.text(AppStrings.couponTips);
      }
    }
  }

  Future<RepaymentResultData?> generateRepaymentUrl(
    BuildContext context, {
    required List<Allocation> allocations,
    List<int> couponIds = const [],
    required int orderType,
    required num originalTotalRepayAmount,
    required num repayAmount,
  }) async {
    try {
      YDToast.loading();
      final result = await ApiUrls.generateRepaymentUrl(
        allocations: allocations.map((a) => a.toJson()).toList(),
        couponIds: couponIds,
        orderType: orderType,
        originalTotalRepayAmount: originalTotalRepayAmount,
        repayAmount: repayAmount,
      );
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        final mapped = RepaymentResultDataMapper.fromMap(result.data ?? {});
        return mapped;
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
      final amount = num.tryParse(amountController.text);
      if (amount == null || amount < minAmount.value) {
        return;
      }
      final bill = await billDetailsFuture.value;
      if (bill.loanOrderDetails == null) {
        return;
      }
      final allocations = bill.loanOrderDetails!
          .map(
            (d) => Allocation(
              allocationAmount: d.repaymentAmount,
              appOrderId: d.appOrderId,
              installmentId: d.installmentId,
            ),
          )
          .toList();

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
        repayAmount: amount,
      );
      if (result != null && result.payUrl.isNotEmpty) {
        Get.toNamed(Routes.webView, arguments: {'url': result.payUrl});
      }
    } catch (e) {}
  }

  @override
  void onClose() {
    amountFocusNode.dispose();
    super.onClose();
  }
}
