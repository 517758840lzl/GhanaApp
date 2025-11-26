import 'package:flutter3APP/views/repayMoney/singleRepayment/repayment_submit_controller.dart';

import '../../../common/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/formatter/number_formatter.dart';
import '../../../utils/string/string_util.dart';
import '../../widgets/exit_confirmation_dialog.dart';
import '../../../routes/routes.dart';
import '../../../models/coupon.dart';
import '../../widgets/coupon_bottom_sheet_widget.dart';

class RepaymentSubmitPage extends StatefulWidget {
  RepaymentSubmitPage({Key? key}) : super(key: key);

  @override
  State<RepaymentSubmitPage> createState() => _RepaymentSubmitPageState();
}

class _RepaymentSubmitPageState extends State<RepaymentSubmitPage>
    with TickerProviderStateMixin {
  final controller = Get.put(RepaymentSubmitController());
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // 启动动画
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildAmountSection(),
                        const SizedBox(height: 5),
                        _buildCouponSection(),
                        const SizedBox(height: 5),
                        _buildDetailsSection(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF2C3E50),
            size: 20,
          ),
          onPressed: () async {
            final result = await showDialog(
              context: context,
              builder: (_) => const ExitConfirmationDialog(),
            );
            if (result == true) Get.back();
          },
        ),
      ),
      title: Text(
        'repaymentSubmit'.tr,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildAmountSection() {
    return Obx(() {
      final shouldShowRange =
          controller.isAmountReadOnly.value;

      return Container(
        // margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
          ),
          // borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAmountHeader(),
            const SizedBox(height: 12),
            _buildAmountInput(),
            if (!shouldShowRange) ...[
              const SizedBox(height: 12),
              _buildAmountRange(),
            ],
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  Widget _buildAmountHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            'assets/images/state_empty.webp',
            width: 20,
            height: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'repaymentAmount'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Obx(() {
      final couponResponse = controller.postLoanCouponResponse.value;
      final isReadOnly = controller.isAmountReadOnly.value;

      if (couponResponse != null) {
        return _buildCouponAmountDisplay(couponResponse);
      }

      // 如果只读，返回纯展示视图
      if (isReadOnly) {
        final displayAmount = controller.amountController.text.isEmpty
            ? StringUtil.formatDecimalAmount(controller.maxAmount.value)
            : controller.amountController.text;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${'currencyUSD'.tr} ',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                child: Text(
                  displayAmount,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        );
      }

      // 如果不只读，返回 TextField
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller.amountController,
          focusNode: controller.amountFocusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
          ),
          inputFormatters: [NumberInputFormatter()],
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintText: 'enterAmount'.tr,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            prefixText: '${'currencyUSD'.tr} ',
            prefixStyle: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
            suffixIcon: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.clear,
                  color: Color(0xFF999999),
                  size: 18,
                ),
              ),
              onPressed: () {
                controller.amountController.clear();
                if (controller.selectedCouponId.value != 0) {
                  controller.clearSelectedCoupon();
                }
              },
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCouponAmountDisplay(couponResponse) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_offer, color: Colors.green[600], size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'couponApplied'.tr,
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${'currencyUSD'.tr}${_formatAmount(couponResponse.repaymentAmount)}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${'currencyUSD'.tr}${_formatAmount(couponResponse.newRepaymentAmount)}',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRange() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.black.withOpacity(0.8),
            size: 14,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '${'repaymentRange'.tr}: ${'currencyUSD'.tr}${controller.minAmount.value} ~ ${'currencyUSD'.tr}${controller.maxAmount.value}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
              title: 'selectCoupon'.tr,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[400]!, Colors.orange[600]!],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'selectCoupon'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 2),
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
                            selectedCoupon.summary,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        } else {
                          return Text(
                            controller.couponList.length == 0
                                ? 'noAvailableCoupons'.tr
                                : 'pleaseCoupons'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader('paymentDetails'.tr, Icons.receipt_long),
          const SizedBox(height: 8),
          Obx(() {
            final billDetails = controller.billDetailsFuture.value;
            final hasDetails =
                billDetails.loanOrderDetails?.isNotEmpty ?? false;
            final detail = hasDetails
                ? billDetails.loanOrderDetails?.first
                : null;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildDetailItem(
                    'dueDate'.tr,
                    detail?.repayDate ?? "",
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    'principal'.tr,
                    detail != null
                        ? "${'currencyUSD'.tr}${_formatAmount(detail.loanAmount)}"
                        : "",
                    Icons.account_balance_wallet,
                    Colors.green,
                    isAmount: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    'repaidAmount'.tr,
                    detail != null
                        ? "${'currencyUSD'.tr}${_formatAmount(detail.waivedAmount)}"
                        : "",
                    Icons.check_circle,
                    Colors.orange,
                    isAmount: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    'interest'.tr,
                    detail != null
                        ? "${'currencyUSD'.tr}${_formatAmount(detail.interest)}"
                        : "",
                    Icons.trending_up,
                    Colors.purple,
                    isAmount: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    'penaltyInterest'.tr,
                    detail != null
                        ? "${'currencyUSD'.tr}${_formatAmount(detail.overdueInterest)}"
                        : "",
                    Icons.warning,
                    Colors.red,
                    isAmount: true,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    'daysRemainingUntilRepaymentDue'.tr,
                    billDetails.remainingDay?.toString() ?? "0",
                    Icons.access_time,
                    (billDetails.remainingDay ?? 0) <= 3
                        ? Colors.red
                        : Colors.blue,
                    isUrgent: (billDetails.remainingDay ?? 0) <= 3,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isAmount = false,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withOpacity(0.05)
            : Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: isUrgent
            ? Border.all(color: Colors.red.withOpacity(0.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'notAvailable'.tr : value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isUrgent
                        ? Colors.red
                        : isAmount
                        ? AppColors.primaryColor
                        : const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Obx(() {
          final billDetails = controller.billDetailsFuture.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPayNowButton(),
              if (billDetails.isExtensionSwitch == true) ...[
                const SizedBox(height: 8),
                _buildExtensionButton(billDetails),
              ],
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPayNowButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          controller.submitRepayment(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'repayNow'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildExtensionButton(billDetails) {
    return Container(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: AppColors.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (billDetails.loanOrderDetails?.isNotEmpty ?? false) {
            final detail = billDetails.loanOrderDetails!.first;
            Get.toNamed(
              Routes.extensionRequest,
              arguments: {
                'installmentId': detail.installmentId,
                'appOrderId': detail.appOrderId,
              },
            );
          }
        },
        child: Text(
          'repayForExtension'.tr,
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatAmount(num amount) {
    return amount.toStringAsFixed(2);
  }
}
