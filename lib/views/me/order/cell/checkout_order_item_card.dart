import 'package:flutter/material.dart';
import '../../../../models/settled_contract.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../utils/string/string_util.dart';

class CheckoutOrderItemCard extends StatelessWidget {
  final CheckoutOrderItem item;
  final ValueChanged<String> onCancel;
  final int cacheFlag;

  const CheckoutOrderItemCard({
    Key? key,
    required this.item,
    required this.onCancel,
    required this.cacheFlag,
  }) : super(key: key);

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
                if (cacheFlag == 0) ...[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.productLogo.replaceFirst("http://", "https://"),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4CAF50),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
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
                      if (cacheFlag == 0)
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.orderId} ${item.appOrderId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),

                // 完成状态徽章
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        AppStrings.completed,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        AppStrings.repaidAmount,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "\$${StringUtil.formatAmount(item.repaidAmount)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        AppStrings.settled,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

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
                      '${AppStrings.dueDate}: ',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.repayDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 12, color: Color(0xFF4CAF50)),
                      SizedBox(width: 4),
                      Text(
                        AppStrings.completed,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4CAF50),
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
}
