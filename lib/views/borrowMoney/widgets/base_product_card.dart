import 'package:flutter/material.dart';
import '../../../models/home_page_data.dart';
import '../../../l10n/app_strings.dart';
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
            buildDetailRow(AppStrings.loanAmount, formatLoanAmount(product)),
            buildDetailRow(AppStrings.termsLabel, formatTerms(product)),
            buildDetailRow(AppStrings.dueDate, formatDueDate(product)),
          ] else ...[
            buildDetailRow(AppStrings.termsLabel, formatTerms(product)),
            buildDetailRow(AppStrings.loanAmount, formatLoanAmount(product)),
            buildDetailRow(
              AppStrings.dailyInterestsLabel,
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
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化期限
  String formatTerms(Product product) {
    return product.daysPerTermFrom == product.daysPerTermTo
        ? '${product.daysPerTermFrom ?? 7} ${AppStrings.daysLabel}'
        : '${product.daysPerTermFrom ?? 7}~${product.daysPerTermTo ?? 180} ${AppStrings.daysLabel}';
  }

  /// 格式化贷款金额
  String formatLoanAmount(Product product) {
    final ac = product.productAccount ?? 0;
    if (ac != 0) {
      return '${AppStrings.currencyUSD}${StringUtil.formatAmount(product.productAccount ?? 0)}';
    } else {
      return product.loanLimitFrom == product.loanLimitTo
          ? '${AppStrings.currencyUSD}${StringUtil.formatAmount(product.loanLimitFrom as num)}'
          : '${AppStrings.currencyUSD}${StringUtil.formatAmount(product.loanLimitFrom as num)}~${StringUtil.formatAmount(product.loanLimitTo as num)}';
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
        AppStrings.notAvailable;
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
