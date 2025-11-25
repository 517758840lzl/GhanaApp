import 'package:flutter/material.dart';
import 'package:flutter3APP/utils/widget/widget.dart';
import 'package:get/get.dart';
import '../../../models/home_page_data.dart';
import '../../../common/colors/app_colors.dart';
import '../../../common/toast.dart';
import 'base_product_card.dart';

/// 可借产品卡片组件
class AvailableProductCard extends BaseProductCard {
  final List<Product> selectedProducts;
  final Function(Product, bool) onProductSelection;

  const AvailableProductCard({
    Key? key,
    required Product product,
    required this.selectedProducts,
    required this.onProductSelection,
    VoidCallback? onTap,
  }) : super(key: key, product: product, onTap: onTap);

  @override
  Widget buildCardContent(BuildContext context) {
    return Obx(() {
      final isSelected = selectedProducts.contains(product);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.2)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 6),
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 产品头部
            Row(
              children: [
                // 产品图标
                buildProductIcon(
                  product.productLogo,
                  Icons.account_balance_wallet,
                  Colors.grey[600]!,
                ),

                const SizedBox(width: 12),

                // 产品信息
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
                        'fastApprovalInstantTransfer'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // 选择状态指示器
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                            key: ValueKey('checked'),
                          )
                        : const SizedBox(key: ValueKey('unchecked')),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 产品详情
            buildProductDetails(product),

            const SizedBox(height: 20),

            // 底部操作按钮
            buildBottomActionButton(product, isSelected),
          ],
        ).onTap((){
          handleProductSelection(product, isSelected);
        }),
      );
    });
  }

  /// 构建底部操作按钮
  Widget buildBottomActionButton(Product product, bool isSelected) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => handleProductSelection(product, isSelected),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primaryColor
              : Colors.grey[200],
          foregroundColor: isSelected ? Colors.black : Colors.grey[600],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              isSelected ? 'selected'.tr : 'selectProduct'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// 处理产品选择
  void handleProductSelection(Product product, bool isSelected) {
    if (isSelected) {
      if (selectedProducts.length > 1) {
        onProductSelection(product, isSelected);
      } else {
        YDToast.text('mustSelectOneProduct'.tr);
      }
    } else {
      onProductSelection(product, isSelected);
    }
  }
}
