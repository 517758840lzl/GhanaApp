import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/home_page_data.dart';
import '../../../routes/routes.dart';
import 'base_product_card.dart';

/// 还款中产品卡片组件
class RepaymentProductCard extends BaseProductCard {
  const RepaymentProductCard({
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
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
                    color: Colors.orange.shade100,
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.payment,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName ?? 'productDefault'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'repaymentRequired'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildProductDetails(product),
            const SizedBox(height: 16),
            buildBottomActionButton(product),
          ],
        ),
      ),
    );
  }

  /// 构建底部操作按钮
  Widget buildBottomActionButton(Product product) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (product.appOrderId != null) {
            List<String> ids = [product.appOrderId ?? ""];
            Get.toNamed(Routes.repaymentSubmit, arguments: {'orderIds': ids});
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 18),
            const SizedBox(width: 8),
            Text(
              'repayNow'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
