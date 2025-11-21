import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:get/get.dart';
import '../../../../common/colors/app_colors.dart';
import '../../../../models/order_history.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/string/string_util.dart';
import '../history_controller.dart';

class OrderHistoryItemWidget extends StatefulWidget {
  final OrderHistoryItem item;
  final ValueChanged<String> onCancel;
  final int cacheFlag;
  final HistoryController controller;

  const OrderHistoryItemWidget({
    Key? key,
    required this.item,
    required this.onCancel,
    required this.cacheFlag,
    required this.controller,
  }) : super(key: key);

  @override
  _OrderHistoryItemWidgetState createState() => _OrderHistoryItemWidgetState();
}

class _OrderHistoryItemWidgetState extends State<OrderHistoryItemWidget> {
  Timer? _timer;
  int _countdownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _countdownSeconds = widget.item.countdownTime ?? 0;
    if (_countdownSeconds > 0) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer?.cancel();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _getOrderStatusTextEs(int status) {
    switch (status) {
      case 3:
        return 'disbursing'.tr;
      case 4:
        return 'processing'.tr;
      case 5:
        return 'disbursementFailed'.tr;
      case 6:
        return 'completed'.tr;
      case 7:
        return 'exceptionallyClosed'.tr;
      case 12:
        return 'disbursing'.tr;
      case 20:
        return 'underReview'.tr;
      case 22:
        return 'rejected'.tr;
      default:
        return 'unknown'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 头部
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 产品图标
                if (widget.cacheFlag == 0) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:  AppColors.primaryColor.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.item.productLogo.replaceFirst(
                          "http://",
                          "https://",
                        ),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primaryColor.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.account_balance,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // 产品信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.cacheFlag == 0)
                        Text(
                          widget.item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.item.appOrderId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),

                // 状态标签
                _buildStatusBadge(),
              ],
            ),
          ),

          // 分割线
          Container(
            height: 1,
            color: const Color(0xFFF0F0F0),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // 金额信息区域
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'repaymentAmount'.tr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${StringUtil.formatAmount(widget.item.repayAmount)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!(widget.item.countdownTime != null &&
                        widget.item.countdownTime! > 0) &&
                    widget.item.orderStatus != 4)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      _getOrderStatusTextEs(widget.item.orderStatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 倒计时区域
          if (widget.item.countdownTime != null &&
              widget.item.countdownTime! > 0) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFE0B2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'timeRemaining'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${_countdownSeconds ~/ 60}:${(_countdownSeconds % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => widget.onCancel(widget.item.appOrderId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryColor),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 支付按钮
          if (widget.item.orderStatus == 4) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.toNamed(
                      Routes.repaymentSubmit,
                      arguments: {
                        'orderIds': [widget.item.appOrderId],
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 18,color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'payArrow'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // 底部信息
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF999999),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${'dueDate'.tr}: ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      StringUtil.extractYmd(widget.item.repayDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (!Platform.isAndroid)
                  GestureDetector(
                    onTap: () {
                      widget.controller.toContracrClick(
                        context,
                        widget.item.loanAmount,
                        widget.item.repayAmount,
                        widget.item.receiptAmount,
                        widget.item.repayDate,
                        widget.item.bankCardNo,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.description,
                            size: 12,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'loanContract'.tr,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String statusText;

    if (widget.item.orderStatus == 5) {
      backgroundColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1976D2);
      statusText = 'processing'.tr;
    } else if (widget.item.remainingDays >= 0) {
      backgroundColor = const Color(0xFFE8F5E8);
      textColor = const Color(0xFF2E7D32);
      statusText = 'processing'.tr;
    } else {
      backgroundColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
      statusText = 'overdue'.tr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }



}
