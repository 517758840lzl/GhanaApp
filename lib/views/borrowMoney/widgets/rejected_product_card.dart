import 'package:flutter/material.dart';
import '../../../models/home_page_data.dart';
import '../../../l10n/app_strings.dart';
import 'base_product_card.dart';

/// 拒绝产品卡片组件
class RejectedProductCard extends BaseProductCard {
  const RejectedProductCard({
    Key? key,
    required Product product,
    VoidCallback? onTap,
  }) : super(key: key, product: product, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    return Container(
      height: 260,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      product.productLogo?.replaceFirst(
                            "http://",
                            "https://",
                          ) ??
                          '',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.cancel, color: Colors.red, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName ?? AppStrings.productDefault,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.rejected,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildProductDetails(product),
            if (product.borrowRetryDate != null &&
                product.borrowRetryDate!.isNotEmpty) ...[
              const SizedBox(height: 12),
              buildRetryDateInfo(product),
            ],
            const SizedBox(height: 16),
            buildBottomActionButton(),
          ],
        ),
      ),
    );
  }

  /// 构建重试日期信息
  Widget buildRetryDateInfo(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.schedule, color: Colors.red, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.retryAvailableOn,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.borrowRetryDate!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建底部操作按钮
  Widget buildBottomActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[100],
          foregroundColor: Colors.red[600],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, size: 18),
            const SizedBox(width: 8),
            const Text(
              AppStrings.applicationRejected,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
