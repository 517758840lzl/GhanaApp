import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/home_page_data.dart';
import '../../../utils/string/string_util.dart';

/// 基础产品卡片组件
abstract class BaseProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const BaseProductCard({Key? key, required this.product, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      child: GestureDetector(onTap: onTap, child: buildCardContent(context)),
    );
  }

  /// 构建卡片内容，子类需要实现
  Widget buildCardContent(BuildContext context);

  /// 构建产品详情
  Widget buildProductDetails(Product product) {
    final int status = product.productStatus ?? -1;
    final bool onlyShowAmountAndDueDate = status == 1 || status == 2;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (onlyShowAmountAndDueDate) ...[
            buildDetailRow('loanAmount'.tr, formatLoanAmount(product)),
            buildDetailRow('termsLabel'.tr, formatTerms(product)),
            buildDetailRow('dueDate'.tr, formatDueDate(product)),
          ] else ...[
            buildDetailRow('termsLabel'.tr, formatTerms(product)),
            buildDetailRow('amount'.tr, formatLoanAmount(product)),
            buildDetailRow(
              'dailyInterestsLabel'.tr,
              formatInterestRate(product),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建详情行
  Widget buildDetailRow(String label, String value) {
    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: AutoSizeText(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化期限
  String formatTerms(Product product) {
    return product.daysPerTermFrom == product.daysPerTermTo
        ? '${product.daysPerTermFrom ?? 7} ${'daysLabel'.tr}'
        : '${product.daysPerTermFrom ?? 7}~${product.daysPerTermTo ?? 180} ${'daysLabel'.tr}';
  }

  /// 格式化贷款金额
  String formatLoanAmount(Product product) {
    final ac = product.productAccount ?? 0;
    if (ac != 0) {
      return '${'currencyUSD'.tr}${StringUtil.formatAmount(product.productAccount ?? 0)}';
    } else {
      return product.loanLimitFrom == product.loanLimitTo
          ? '${'currencyUSD'.tr}${StringUtil.formatAmount(product.loanLimitFrom as num)}'
          : '${'currencyUSD'.tr}${StringUtil.formatAmount(product.loanLimitFrom as num)}~${StringUtil.formatAmount(product.loanLimitTo as num)}';
    }
  }

  /// 格式化利率
  String formatInterestRate(Product product) {
    return product.dailyInterestRateFrom == product.dailyInterestRateTo
        ? '${((product.dailyInterestRateFrom ?? 0.01) * 100).toStringAsFixed(2)}%'
        : '${((product.dailyInterestRateFrom ?? 0.01) * 100).toStringAsFixed(2)}%~${((product.dailyInterestRateTo ?? 0.05) * 100).toStringAsFixed(2)}%';
  }

  /// 格式化到期日
  String formatDueDate(Product product) {
    return product.dueDate ??
        product.repayDateStr ??
        product.repayDate ??
        'notAvailable'.tr;
  }

  /// 构建产品图标
  Widget buildProductIcon(
    String? logoUrl,
    IconData fallbackIcon,
    Color fallbackColor,
  ) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          logoUrl?.replaceFirst("http://", "https://") ?? '',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            fallbackIcon,
            color: fallbackColor,
            size: 24,
            key: const ValueKey('default'),
          ),
        ),
      ),
    );
  }
}
