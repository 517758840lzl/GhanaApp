import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/settled_contract.dart';
import '../../../../utils/string/string_util.dart';
import '../../../../models/order_history.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../common/colors/app_colors.dart';

class HistoryDialogs {
  static void showHistoryOrderDetailDialog(
    BuildContext context,
    OrderHistoryItem item,
  ) {
    // 添加触觉反馈
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 40,
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 700),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部
                  _buildMeituanHeader(
                    context,
                    AppStrings.orderDetails,
                    AppStrings.completeLoanInformation,
                  ),

                  // 内容区域
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // 主要金额卡片
                          _buildAmountCard(
                            title: AppStrings.singleRepaymentAmount,
                            amount:
                                "${AppStrings.currencyUSD}${StringUtil.formatAmount(item.repayAmount)}",
                            subtitle: AppStrings.loanAmount,
                            subtitleAmount:
                                "${AppStrings.currencyUSD}${StringUtil.formatAmount(item.loanAmount)}",
                            isPrimary: true,
                          ),

                          const SizedBox(height: 12),

                          // 费用明细卡片
                          _buildInfoCard(
                            title: AppStrings.feeBreakdown,
                            children: [
                              _buildMeituanDetailRow(
                                AppStrings.amountCredited,
                                "${AppStrings.currencyUSD}${StringUtil.formatAmount(item.receiptAmount)}",
                              ),
                              _buildMeituanDetailRow(
                                AppStrings.serviceFee,
                                "${AppStrings.currencyUSD}${StringUtil.formatAmount(item.loanAmount - item.receiptAmount)}",
                              ),
                              _buildMeituanDetailRow(
                                AppStrings.interest,
                                "${AppStrings.currencyUSD}${StringUtil.formatAmount(item.interest)}",
                              ),
                              _buildMeituanDetailRow(
                                AppStrings.termsLabel,
                                "${item.totalServiceDays} ${AppStrings.daysLabel}",
                              ),
                              _buildMeituanDetailRow(
                                AppStrings.dueDate,
                                item.repayDateStr,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showCheckoutOrderDetailDialog(
    BuildContext context,
    CheckoutOrderItem item,
    int cacheFlag,
  ) {
    // 添加触觉反馈
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 40,
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 头部 - 绿色主题表示成功
                  _buildMeituanHeader(
                    context,
                    AppStrings.settledOrderDetails,
                    AppStrings.successfullyCompletedLoan,
                    isSuccess: true,
                  ),

                  // 内容区域
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // 主要金额卡片 - 绿色成功主题
                          _buildAmountCard(
                            title: AppStrings.singleRepaymentAmount,
                            amount:
                                "${AppStrings.currencyUSD}${StringUtil.formatAmount(item.repaidAmount)}",
                            isPrimary: true,
                            isSuccess: true,
                          ),

                          const SizedBox(height: 12),

                          // 订单信息卡片
                          _buildInfoCard(
                            title: AppStrings.orderInformation,
                            children: [
                              _buildMeituanDetailRow(
                                AppStrings.orderNumber,
                                item.appOrderId,
                              ),
                              if (cacheFlag == 0) ...[
                                _buildMeituanDetailRow(
                                  AppStrings.product,
                                  item.productName,
                                ),
                              ],
                              _buildMeituanDetailRow(
                                AppStrings.dueDate,
                                item.repayDate,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // 完成状态卡片
                          _buildSuccessStatusCard(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 头部组件
  static Widget _buildMeituanHeader(
    BuildContext context,
    String title,
    String subtitle, {
    bool isSuccess = false,
  }) {
    final primaryColor = isSuccess
        ? const Color(0xFF00B96B)
        : AppColors.primaryColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // 金额卡片
  static Widget _buildAmountCard({
    required String title,
    required String amount,
    String? subtitle,
    String? subtitleAmount,
    bool isPrimary = false,
    bool isSuccess = false,
  }) {
    final primaryColor = isSuccess
        ? const Color(0xFF00B96B)
        : AppColors.primaryColor;
    final backgroundColor = isSuccess
        ? const Color(0xFFF6FFED)
        : AppColors.primaryColor.withOpacity(0.1);
    final borderColor = isSuccess
        ? const Color(0xFFB7EB8F)
        : AppColors.primaryColor.withOpacity(0.3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: isPrimary ? 24 : 18,
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitleAmount != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  subtitleAmount,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 信息卡片
  static Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // 详情行
  static Widget _buildMeituanDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 成功状态卡片
  static Widget _buildSuccessStatusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FFED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB7EB8F), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF00B96B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.successfullySettled,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00B96B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppStrings.loanFullyRepaid,
                  style: TextStyle(fontSize: 13, color: Color(0xFF52C41A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
