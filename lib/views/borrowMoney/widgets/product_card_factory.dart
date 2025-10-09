import 'package:flutter/material.dart';
import '../../../models/home_page_data.dart';
import 'available_product_card.dart';
import 'repayment_product_card.dart';
import 'processing_product_card.dart';
import 'locked_product_card.dart';
import 'rejected_product_card.dart';
import 'unavailable_product_card.dart';

/// 产品卡片工厂类
class ProductCardFactory {
  /// 根据产品状态创建对应的卡片组件
  static Widget createProductCard({
    required Product product,
    List<Product>? selectedProducts,
    Function(Product, bool)? onProductSelection,
    VoidCallback? onTap,
  }) {
    switch (product.productStatus) {
      case 0: // 可借
        return AvailableProductCard(
          product: product,
          selectedProducts: selectedProducts ?? [],
          onProductSelection: onProductSelection ?? (_, __) {},
          onTap: onTap,
        );
      case 1: // 还款中
        return RepaymentProductCard(product: product, onTap: onTap);
      case 2: // 申请中
        return ProcessingProductCard(product: product, onTap: onTap);
      case 3: // 锁定中
        return LockedProductCard(product: product, onTap: onTap);
      case 4: // 拒绝中
        return RejectedProductCard(product: product, onTap: onTap);
      default:
        return UnavailableProductCard(product: product, onTap: onTap);
    }
  }
}
