import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/l10n/app_strings.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/models/bill_detail.dart';
import 'package:flutter3APP/models/coupon.dart';
import 'package:flutter3APP/views/widgets/coupon_bottom_sheet_widget.dart';
import 'package:flutter3APP/views/widgets/exit_confirmation_dialog.dart';
import 'all_repayment_submit_controller.dart';

// 一起还款 - 重新设计
class AllRepaymentSubmitPage extends StatelessWidget {
  AllRepaymentSubmitPage({Key? key}) : super(key: key);

  final AllRepaymentSubmitController controller = Get.put(
    AllRepaymentSubmitController(),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击页面收起键盘
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: _buildAppBar(context),
        body: Obx(
          () =>  _buildMainContent(controller.billDetailsFuture.value)
        ),
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        AppStrings.allRepaymentSubmit,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (_) => const ExitConfirmationDialog(),
          );
          if (result == true) Get.back();
        },
      ),
    );
  }




  // 主要内容
  Widget _buildMainContent(BillDetailsData bill) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 还款金额卡片 - 
                _buildRepaymentAmountCard(),
                const SizedBox(height: 16),

                // 优惠券选择区域
                _buildCouponSection(),
                const SizedBox(height: 16),

                // 账单详情标题
                _buildSectionTitle(),
                const SizedBox(height: 12),

                // 账单详情列表
                _buildBillDetailsList(bill),
                const SizedBox(height: 100), // 为底部按钮留出空间
              ],
            ),
          ),
          // 底部还款按钮
          _buildBottomRepaymentButton(),
        ],
      ),
    );
  }

  // 还款金额卡片 - 设计
  Widget _buildRepaymentAmountCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 标题行
            Container(
              alignment: Alignment.center,
              child: Text(
                "${AppStrings.repaymentAmount}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 金额输入区域
            Obx(
              () => controller.postLoanCouponResponse.value == null
                  ? _buildAmountInputField()
                  : _buildCouponAmountDisplay(),
            ),
          ],
        ),
      ),
    );
  }

  // 金额输入框
  Widget _buildAmountInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: Alignment.center,
      child:  Text(
        '${AppStrings.currencyUSD}${controller.readOnlyAmount.value}',
        style: TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  // 优惠券金额显示
  Widget _buildCouponAmountDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.black, size: 16),
              const SizedBox(width: 8),
              Text(
                AppStrings.couponApplied,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${AppStrings.currencyUSD}${_formatAmount(controller.postLoanCouponResponse.value?.repaymentAmount ?? 0)}',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${AppStrings.currencyUSD}${_formatAmount(controller.postLoanCouponResponse.value?.newRepaymentAmount ?? 0)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 优惠券选择区域
  Widget _buildCouponSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            CouponBottomSheetWidget.show(
              couponList: controller.couponList,
              selectedCouponId: controller.selectedCouponId.value,
              onCouponSelected: (couponId) {
                controller.applyCoupon(couponId);
                Get.back();
              },
              onClearCoupon: () {
                controller.clearSelectedCoupon();
                Get.back();
              },
              title: AppStrings.selectCoupon,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.orange[600],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.selectCoupon,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        if (controller.selectedCouponId.value != 0) {
                          final selectedCoupon = controller.couponList
                              .firstWhere(
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
                            selectedCoupon.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        } else {
                          return Text(
                            AppStrings.pleaseCoupons,
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
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          AppStrings.billDetails,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  // 账单详情列表
  Widget _buildBillDetailsList(BillDetailsData bill) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bill.loanOrderDetails?.length ?? 0,
      itemBuilder: (context, index) {
        final detail = bill.loanOrderDetails?[index];
        return _buildBillItem(detail, index);
      },
    );
  }


  Widget _buildBillItem(dynamic detail, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 产品图标
            _buildProductIcon(detail),
            const SizedBox(width: 16),

            // 产品信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail?.productName ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 还款日期
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppStrings.dueDateColon} ${detail?.repayDate ?? ""}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 还款金额
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppStrings.amountDue} ${detail?.repaymentAmount ?? ""}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 剩余天数标签
                  _buildDaysRemainingTag(detail?.remainingDay ?? 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 产品图标
  Widget _buildProductIcon(dynamic detail) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: detail?.productLogo != null && detail.productLogo.isNotEmpty
            ? Image.network(
                detail.productLogo,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryColor,
                    size: 24,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Icon(
                    Icons.receipt_long,
                    color: AppColors.primaryColor,
                    size: 24,
                  );
                },
              )
            : Icon(Icons.receipt_long, color: AppColors.primaryColor, size: 24),
      ),
    );
  }

  // 剩余天数标签
  Widget _buildDaysRemainingTag(int days) {
    final color = _getDaysColor(days);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '${days}${AppStrings.daysRemaining}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 底部还款按钮
  Widget _buildBottomRepaymentButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
        child: SafeArea(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  controller.submitRepayment(Get.context!);
                },
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.payment, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        AppStrings.repayNow,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 根据剩余天数获取颜色
  Color _getDaysColor(int days) {
    if (days <= 3) {
      return const Color(0xFFE74C3C); // 红色 - 紧急
    } else if (days <= 7) {
      return const Color(0xFFF39C12); // 橙色 - 警告
    } else {
      return const Color(0xFF27AE60); // 绿色 - 正常
    }
  }

  // 格式化金额
  String _formatAmount(num amount) {
    return amount.toStringAsFixed(2);
  }
}
