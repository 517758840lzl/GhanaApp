import 'dart:async';
import 'dart:io';
import 'package:flutter3APP/views/me/bank/bank_select/bank_card_selection.dart';
import 'package:flutter3APP/views/me/bank/bank_select/bank_card_selection_controller.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/views/borrowMoney/borrow_controller.dart';
import '../../../basa/appsFlyer/apps_flyer_helper.dart';
import '../../../models/home_page_data.dart';
import '../../../models/confirm_user_apply_amount_info_req.dart';
import '../../../models/loan_amount_confirm_response.dart';
import '../../../models/coupon_calc.dart';
import '../../../models/coupon.dart';
import '../../../models/bank_card.dart';
import '../../../provider/userDataHelper.dart';
import '../../../common/toast.dart';
import '../../../http/api_urls.dart';
import 'package:flutter/material.dart';
import '../../../routes/routes.dart';
import '../../../l10n/app_strings.dart';


class LoanDetailController extends GetxController {
  // 状态变量
  final Rx<LoanAmountConfirmData?> confirmResponse = Rx<LoanAmountConfirmData?>(
    null,
  );
  final couponList = <CouponInfo>[].obs;
  final Rx<OrderCustomerCouponData?> couponCalcResponse =
      Rx<OrderCustomerCouponData?>(null); //使用优惠券后的金额
  final RxInt selectedCouponId = 0.obs;

  // final RxInt remainingSeconds = 0.obs;
  final RxBool isAutoLoanCancelled = false.obs;
  final RxInt cacheFlag = 0.obs;
  final RxBool isPrivacyAgreed = Platform.isAndroid ? true.obs : false.obs;
  Timer? countDownTimer;
  // int isResetCountDownTime = 0;
  List<Product> initialSelectedProducts = [];

  // 银行卡选择控制器
  final BankCardSelectionController bankCardSelectionController = Get.put(
    BankCardSelectionController(),
  );

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};

    // isResetCountDownTime = args['isResetCountDownTime'] ?? 0;
    initialSelectedProducts = args['selectedProducts'] ?? [];
    // 初始化产品选择状态
    for (final product in initialSelectedProducts) {
      product.isSelected = true;
    }
    fetchConfirmationData();
  }

  @override
  void onClose() {
    countDownTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchConfirmationData() async {
    cacheFlag.value = await UserDataHelper.getCacheData();
    YDToast.loading();
    // 获取选中的产品
    // final selectedProducts =
    //     initialSelectedProducts.where((product) => product.isSelected).toList();
    List<Param> paramList = initialSelectedProducts.map((product) {
      return Param(
        appOrderId: product.appOrderId ?? "",
        loanAmount: product.productAccount ?? 0,
        productCode: product.productCode ?? '',
      );
    }).toList();
    ConfirmUserApplyAmountInfoReq reqData = ConfirmUserApplyAmountInfoReq(
      // isResetCountDownTime: 0,
      list: paramList,
    );
    final resp = await ApiUrls.confirmLoanAmount(data: reqData.toMap());
    YDToast.cleanAll();
    if (resp.isSucceed && resp.data != null) {
      final model = LoanAmountConfirmDataMapper.fromMap(resp.data ?? {});
      // 初始化产品选择状态
      for (var product in model.list) {
        product.isSelected = true;
      }
      confirmResponse.value = model;
      // remainingSeconds.value = model.countDownTime;
      // startCountDown();
      await fetchCouponList();
    } else {
      YDToast.text(resp.msg);
    }
  }

  void startCountDown() {
    // countDownTimer?.cancel();
    // if (remainingSeconds.value > 0) {
    //   countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //     if (remainingSeconds.value > 0) {
    //       remainingSeconds.value--;
    //     } else {
    //       timer.cancel();
    //     }
    //   });
    // }
  }

  //获取优惠券
  Future<void> fetchCouponList() async {
    final selectedProductCodes = initialSelectedProducts
        // .where((p) => p.isSelected)
        .map((p) => p.productCode ?? '')
        .where((code) => code.isNotEmpty)
        .toList();
    final resp = await ApiUrls.getCouponListV2(
      appOrderIds: [],
      couponType: 'PRE',
      productCodes: selectedProductCodes,
      repaymentType: 0,
    );
    if (resp.isSucceed && resp.data != null) {
      CouponListData data = CouponListDataMapper.fromMap(resp.data!);

      couponList.value = data.coupons
          .where((product) => product.status == 0 && product.type == "PRE")
          .toList();
      couponList.refresh();
    }
  }

  //使用优惠券后的金额
  Future<void> applyCoupon() async {
    if (selectedCouponId.value == 0) {
      return;
    }
    YDToast.loading();
    final productCodes = initialSelectedProducts
        // .where((product) => product.isSelected)
        .map((p) => p.productCode ?? '')
        .where((code) => code.isNotEmpty)
        .toList();
    // final appOrderIds = _getSelectedAppOrderIds();
    final resp = await ApiUrls.calculatePreLoanCoupon(
      appOrderIds: [],
      couponIds: [selectedCouponId.value],
      productCodes: productCodes,
    );
    YDToast.cleanAll();
    if (resp.isSucceed && resp.data != null) {
      couponCalcResponse.value = OrderCustomerCouponDataMapper.fromMap(
        resp.data!,
      );
      if (couponCalcResponse.value != null) {
        confirmResponse.value?.actualToAccountMoney =
            couponCalcResponse.value!.actualToAccountMoney ?? 0;
        confirmResponse.value?.loanAmount =
            couponCalcResponse.value!.newLoanAmount ?? 0;
        confirmResponse.value?.serviceFee =
            couponCalcResponse.value!.serviceFee ?? 0;
        confirmResponse.value?.rent = couponCalcResponse.value!.rent ?? 0;
        confirmResponse.refresh();
      }
    } else {
      YDToast.text(AppStrings.errorApplyingCoupon);
    }
  }

  //计算贷款额度
  Future<void> fetchConfirmationDataWithReset() async {
    YDToast.loading();
    if (confirmResponse.value != null) {
      List<Map<String, dynamic>> paramList = initialSelectedProducts.map((
        item,
      ) {
        return {
          "loanAmount": item.productAccount ?? 0,
          "productCode": item.productCode ?? "",
          "appOrderId": item.appOrderIdStr ?? "",
        };
      }).toList();
      //"isResetCountDownTime": 1,
      final reqData = {"list": paramList};
      final resp = await ApiUrls.confirmLoanAmount(data: reqData);
      YDToast.cleanAll();
      if (resp.isSucceed && resp.data != null) {
        final model = LoanAmountConfirmDataMapper.fromMap(resp.data!);
        for (var newProduct in model.list) {
          newProduct.isSelected = true;
        }
        confirmResponse.value = model;
        // remainingSeconds.value = model.countDownTime;
      }
      //有优惠券再次调用优惠券计算
      applyCoupon();
    }
  }

  Future<void> cancelAutoLoan() async {
    isAutoLoanCancelled.value = true;
    countDownTimer?.cancel();
    // remainingSeconds.value = 0;
    final productCodes = initialSelectedProducts
        // .where((product) => product.isSelected)
        .map((p) => p.productCode ?? '')
        .where((code) => code.isNotEmpty)
        .toList();
    // final appOrderIds = _getSelectedAppOrderIds();
    final resp = await ApiUrls.removeAutoLoan(
      appOrderIds: [],
      productCodes: productCodes,
    );
    if (resp.isSucceed) {
      await fetchConfirmationDataWithReset();
    }
  }

  // 切换产品选择状态
  void toggleProductSelection(String? productCode) {
    // if (productCode == null || productCode.isEmpty) return;
    // final selectList =
    //     initialSelectedProducts.where((p) => p.isSelected == true).toList();
    // if (selectList == 1 && selectList.first.productCode == productCode) {
    //   return;
    // }
    // final product = initialSelectedProducts.firstWhere(
    //   (p) => p.productCode == productCode,
    //   orElse: () => Product(productAccount: 0),
    // );
    // if (product.productCode != null) {
    //   product.isSelected = !product.isSelected;
    // }
    // // 产品选择后刷新数据
    // fetchConfirmationDataWithReset();
  }

  // 获取当前选中产品的appOrderIdStr列表
  // List<int> _getSelectedAppOrderIds() {
  //   return initialSelectedProducts
  //       .where((p) => p.isSelected)
  //       .map((p) => int.tryParse(p.appOrderIdStr ?? '') ?? 0)
  //       .where((id) => id > 0)
  //       .toList();
  // }

  submitLoan(BuildContext context) async {
    if (!isPrivacyAgreed.value) {
      Get.dialog(
        AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 30),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            AppStrings.ConfirmApplication,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(AppStrings.ConfirmApplicationDetail),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                    ),
                    child: const Text(
                      AppStrings.cancel,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      isPrivacyAgreed.value = true;
                      requestLoanClick();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                    ),
                    child: const Text(
                      AppStrings.confirm,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      return;
    }
    requestLoanClick();
  }

  requestLoanClick() async {
    try {
      // 组装参数
      // final selected =
      //     initialSelectedProducts.where((p) => p.isSelected).toList();
      if (confirmResponse.value!.list.length == 0) {
        YDToast.text(AppStrings.pleaseSelectAtLeastOneProduct);
        return;
      }
      YDToast.loading();
      final params = confirmResponse.value!.list
          .map(
            (item) => {
              'appOrderId': item.appOrderIdStr,
              'loanAmount': item.productAccount ?? 0,
              'productCode': item.productCode,
            },
          )
          .toList();
      var reqData = {
        'productInfoList': params,
        'bankId': confirmResponse.value?.bankCardId.toString(),
      };
      if (selectedCouponId.value != 0) {
        reqData.addAll({
          "couponIds": [selectedCouponId.value],
        });
      } else {
        reqData.addAll({"couponIds": []});
      }
      final resp = await ApiUrls.submitLoanRequest(jsonBody: reqData);
      YDToast.cleanAll();
      if (resp.isSucceed) {
        AppsFlyerHelper().eventWithdrawSuccess();
        YDToast.text(AppStrings.loanSubmittedSuccessfully);
        Get.find<BorrowController>().refreshData();
        Get.offAllNamed(Routes.loanResult);
      } else {
        YDToast.text(
          resp.msg != "" ? resp.msg : AppStrings.loanSubmissionFailed,
        );
      }
    } catch (e) {
      YDToast.text('${AppStrings.loanSubmissionError}: $e');
    }
  }

  /// 格式化利率
  String formatInterestRate(Product product) {
    return product.dailyInterestRateFrom == product.dailyInterestRateTo
        ? '${((product.dailyInterestRateFrom ?? 0.01) * 100).toStringAsFixed(2)}%'
        : '${((product.dailyInterestRateFrom ?? 0.01) * 100).toStringAsFixed(2)}%~${((product.dailyInterestRateTo ?? 0.05) * 100).toStringAsFixed(2)}%';
  }

  /// 显示银行卡选择弹窗
  Future<void> showBankCardSelectionDialog() async {
    // 获取当前选中的银行卡
    BankCardInfo? currentSelectedCard;
    if (confirmResponse.value != null &&
        confirmResponse.value!.bankCardId != null) {
      // 根据当前确认响应中的银行卡ID创建银行卡信息
      currentSelectedCard = BankCardInfo(
        bankCardNo: confirmResponse.value!.bankCardNo,
        bankId: 0, // 这个值在API响应中可能没有，暂时设为0
        bankName: confirmResponse.value!.bankCardName,
        id: confirmResponse.value!.bankCardId!,
        priority: 0,
      );
    }

    final BankCardInfo? selected = await BankCardSelection.show(
      currentSelectedCard: currentSelectedCard,
    );
    if (selected != null) {
      if (confirmResponse.value != null) {
        confirmResponse.value!.bankCardId = selected.id;
        confirmResponse.value!.bankCardName = selected.bankName;
        confirmResponse.value!.bankCardNo = selected.bankCardNo;
        confirmResponse.refresh();
      }
    }
  }
}
