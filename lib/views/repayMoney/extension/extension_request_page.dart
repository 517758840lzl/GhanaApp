import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/utils/string/string_util.dart';
import '../../../common/colors/app_colors.dart';
import 'extension_request_controller.dart';
import '../../../l10n/app_strings.dart';
import '../../../routes/routes.dart';

class ExtensionRequestPage extends StatelessWidget {
  ExtensionRequestPage({Key? key}) : super(key: key);

  final ExtensionRequestController controller = Get.put(
    ExtensionRequestController(),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          AppStrings.deferredPaymentDetails,
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/images/icon_service_two.webp',
                  width: 20,
                  height: 20,
                ),
              ),
              onPressed: () => Get.toNamed(Routes.contact),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final extensionInfo = controller.extensionInfo.value;
        if (extensionInfo == null) {
          return _buildEmptyState();
        }
        final newAmountText = extensionInfo.newExtensionFee < 0
            ? "0"
            : StringUtil.formatAmount(extensionInfo.newExtensionFee);
        final originalAmountText = StringUtil.formatAmount(
          extensionInfo.extensionFee,
        );

        return SingleChildScrollView(
          child: Column(
            children: [
              // 顶部状态卡片
              _buildStatusCard(newAmountText, originalAmountText),
              const SizedBox(height: 5),

              // 展期选项卡片
              _buildExtensionOptionsCard(extensionInfo),
              const SizedBox(height: 5),

              // 费用明细卡片
              _buildFeeDetailsCard(extensionInfo),
              const SizedBox(height: 5),

              // 优惠券选择卡片
              if (controller.couponList.isNotEmpty) ...[
                _buildCouponSelectionCard(),
                const SizedBox(height: 5),
              ],

              // 风险提示卡片
              _buildRiskWarningCard(),
              const SizedBox(height: 5),

              // 确认按钮
              _buildConfirmButton(),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
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
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 40,
              color: Color(0xFFCCCCCC),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noData,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 顶部状态卡片
  Widget _buildStatusCard(String newAmountText, String originalAmountText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.schedule, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 3),
              const Expanded(
                child: Text(
                  AppStrings.deferredPaymentAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.selectedCouponId.value == null)
                Container(
                  child: Text(
                    "${AppStrings.currencyUSD}$newAmountText",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              if (controller.selectedCouponId.value != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${AppStrings.currencyUSD}$newAmountText",
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${AppStrings.currencyUSD}$originalAmountText",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),

                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 展期选项卡片
  Widget _buildExtensionOptionsCard(dynamic extensionInfo) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.extensionDetails,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            AppStrings.newDueDate,
            extensionInfo.extensionRepaymentDate,
            Icons.calendar_today,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            AppStrings.extensionPeriod,
            "${extensionInfo.remainingDay} ${AppStrings.daysLabel}",
            Icons.access_time,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            AppStrings.amountDueAtMaturity,
            "${AppStrings.currencyUSD}${StringUtil.formatAmount(extensionInfo.totalSureRepayAmounts)}",
            Icons.account_balance_wallet,
            isAmount: true,
          ),
        ],
      ),
    );
  }

  // 费用明细卡片
  Widget _buildFeeDetailsCard(dynamic extensionInfo) {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.feeDetails,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.extensionFee,
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              Text(
                "${AppStrings.currencyUSD}${StringUtil.formatAmount(extensionInfo.extensionFee)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          if (controller.selectedCouponId.value != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.discount,
                  style: TextStyle(fontSize: 14, color: Color(0xFF52C41A)),
                ),
                Text(
                  "-${AppStrings.currencyUSD}${StringUtil.formatAmount(extensionInfo.extensionFee - extensionInfo.newExtensionFee)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF52C41A),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.totalPayment,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                "${AppStrings.currencyUSD}${StringUtil.formatAmount(extensionInfo.newExtensionFee)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 优惠券选择卡片
  Widget _buildCouponSelectionCard() {
    return Container(

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: AppColors.primaryColor, size: 16),
              const SizedBox(width: 6),
              const Text(
                AppStrings.selectCoupon,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              if (controller.selectedCouponId.value != null)
                GestureDetector(
                  onTap: () => controller.clearSelectedCoupon(),
                  child: Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.couponList.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    AppStrings.noAvailableCoupons,
                    style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                  ),
                ),
              );
            }

            return Column(
              children: controller.couponList.map((coupon) {
                final isSelected =
                    controller.selectedCouponId.value == coupon.couponId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : const Color(0xFFE8E8E8),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.05)
                        : Colors.white,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => controller.applyCoupon(coupon.couponId),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                isSelected ? Icons.check : Icons.local_offer,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF666666),
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coupon.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  if (coupon.description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      coupon.description,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  // 风险提示卡片
  Widget _buildRiskWarningCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFFD591), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFA8C16),
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              AppStrings.extensionTip,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF8C4A00),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 确认按钮
  Widget _buildConfirmButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () async {
            await controller.onConfirmExtension();
          },
          child: const Center(
            child: Text(
              AppStrings.confirmExtension,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 详情行组件
  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isAmount = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: const Color(0xFF666666), size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isAmount
                      ? AppColors.primaryColor
                      : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
