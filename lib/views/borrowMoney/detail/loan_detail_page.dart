import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/routes/routes.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/utils/non_repeatable_click.dart';
import 'package:flutter3APP/utils/string/string_util.dart';
import 'package:flutter3APP/views/borrowMoney/detail/loan_detail_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/coupon.dart';
import '../../../provider/userDataHelper.dart';
import 'widgets/coupon_bottom_sheet_widget.dart';

class LoanDetailPage extends StatelessWidget {
   LoanDetailPage({Key? key}) : super(key: key);

  final LoanDetailController controller = Get.put(LoanDetailController());
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Obx(
        () => controller.confirmResponse.value == null
            ? _buildEmptyState()
            : _buildMainContent(controller),
      ),
    );
  }

  // 应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'loanConfirmation'.tr,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE5E5E5)),
      ),
    );
  }

  // 空状态页面
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(Icons.info_outline, size: 40, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'noLoanConfirmationInfo'.tr,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 主要内容
  Widget _buildMainContent(LoanDetailController controller) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 金额概览卡片
                _buildAmountOverviewCard(controller),
                const SizedBox(height: 10),

                // 费用明细卡片
                _buildFeeDetailsCard(controller),
                const SizedBox(height: 10),
                // 优惠券选择卡片
                _buildCouponCard(controller),
                const SizedBox(height: 10),

                // 银行卡信息卡片
                _buildBankCardCard(controller),
                const SizedBox(height: 10),

                // 隐私协议
                _buildPrivacyAgreement(controller),
                const SizedBox(height: 100), // 为底部按钮留出空间
              ],
            ),
          ),
        ),
        // 底部确认按钮
        _buildBottomButton(controller),
      ],
    );
  }

  // 金额概览卡片 - 
  Widget _buildAmountOverviewCard(LoanDetailController controller) {
    final response = controller.confirmResponse.value;
    if (response == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头部装饰
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 实际到账金额
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'loanPrincipal'.tr,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${'currencyUSD'.tr}${response.loanAmount}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 还款日期
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange[600], size: 16),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'repaymentDate'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              StringUtil.extractYmd(response.repayDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 费用明细卡片
  Widget _buildFeeDetailsCard(LoanDetailController controller) {
    final response = controller.confirmResponse.value;
    if (response == null) return const SizedBox.shrink();

    final totalAmount = response.loanAmount + response.rent;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 费用明细
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFeeItem(
                  'loanPrincipal'.tr,
                  '${'currencyUSD'.tr}${response.loanAmount}',
                  isHighlighted: false,
                ),
                const SizedBox(height: 12),
                _buildFeeItem(
                  'actualAmountToAccount'.tr,
                  '${'currencyUSD'.tr}${response.actualToAccountMoney}',
                  isHighlighted: false,
                ),
                const SizedBox(height: 12),
                _buildFeeItem(
                  'serviceFee'.tr,
                  '${'currencyUSD'.tr}${response.serviceFee}',
                  isHighlighted: true,
                ),
                const SizedBox(height: 12),
                _buildFeeItem(
                  'interest'.tr,
                  '${'currencyUSD'.tr}${response.rent}',
                  isHighlighted: true,
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 16),
                _buildFeeItem(
                  'totalRepaymentAmount'.tr,
                  '${'currencyUSD'.tr}${totalAmount}',
                  isHighlighted: true,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 费用项目
  Widget _buildFeeItem(
    String label,
    String amount, {
    bool isHighlighted = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isHighlighted ? Colors.grey[700] : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isHighlighted ? Colors.black : Colors.black,
          ),
        ),
      ],
    );
  }

  // 银行卡信息卡片
  Widget _buildBankCardCard(LoanDetailController controller) {
    final response = controller.confirmResponse.value;
    if (response == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          NonRepeatableClick.checkClick(
            debounceDuration: const Duration(seconds: 1),
            click: () async {
              if (controller.appBlackCard.value) {
                await controller.showBankCardSelectionDialog();
              }
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.credit_card,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'bankCardToAccount'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response.bankCardName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      response.bankCardNo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => controller.appBlackCard.value
                  ? Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    )
                  : SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  // 优惠券选择卡片
  Widget _buildCouponCard(LoanDetailController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          CouponBottomSheetWidget.show(controller);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_offer,
                  color: Colors.orange[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'selectCoupon'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      if (controller.selectedCouponId.value != 0) {
                        final selectedCoupon = controller.couponList.firstWhere(
                          (coupon) =>
                              coupon.couponId ==
                              controller.selectedCouponId.value,
                          orElse: () => CouponInfo(
                            couponId: 0,
                            title: '',
                            description: '',
                            discountType: 0,
                            discountValue: 0.0,
                            maxDiscountValue: 0.0,
                            minDiscountValue: 0.0,
                            repaymentType: 0,
                            status: 0,
                            summary: '',
                            type: '',
                            validFrom: 0,
                            validTo: 0,
                          ),
                        );
                        return Text(
                          selectedCoupon.summary,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      } else {
                        return controller.couponList.isEmpty
                            ? Text(
                                'noAvailableCoupons'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              )
                            : Text(
                                'pleaseCoupons'.tr,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              );
                      }
                    }),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 隐私协议
  Widget _buildPrivacyAgreement(LoanDetailController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Obx(
            () => Transform.scale(
              scale: 1.1,
              child: Checkbox(
                value: controller.isPrivacyAgreed.value,
                onChanged: (val) {
                  controller.isPrivacyAgreed.value = val ?? false;
                },
                activeColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(text: 'iHaveReadAndAgreeText'.tr),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        if (Platform.isAndroid) {
                          Get.toNamed(Routes.privacyPolicy);
                        } else {
                          final response = controller.confirmResponse.value;
                          if (response != null) {
                            final phoneNumber =
                                await UserDataHelper.getPhoneNumber() ?? '';
                            final prefs = await SharedPreferences.getInstance();
                            final customerName =
                                prefs.getString("cached_customerName") ?? "";
                            final idCardNumber =
                                prefs.getString("cached_idCardNumber") ?? "";
                            Get.toNamed(
                              Routes.loanContract,
                              arguments: {
                                'loanAmount': response.loanAmount.toString(),
                                'singleRepaymentAmount':
                                    (response.loanAmount +
                                            response.serviceFee +
                                            response.rent)
                                        .toString(),
                                'amountCredited': response.actualToAccountMoney
                                    .toString(),
                                'interest': response.rent.toString(),
                                'dueDate': response.repayDate,
                                'name': customerName,
                                'idCardNumber': idCardNumber,
                                'receivingBankCardNumber': response.bankCardNo,
                                'loanMobilePhoneNumber': phoneNumber,
                              },
                            );
                          }
                        }
                      },
                    text: Platform.isAndroid
                        ? 'privacyPolicy'.tr
                        : 'loanContract'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 底部确认按钮
  Widget _buildBottomButton(LoanDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              NonRepeatableClick.checkClick(
                debounceDuration: const Duration(seconds: 1),
                click: () async {
                  await controller.submitLoan(Get.context!);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(
              'confirmLoan'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
