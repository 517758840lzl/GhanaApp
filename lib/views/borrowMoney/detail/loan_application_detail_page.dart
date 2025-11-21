import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/utils/string/string_util.dart';
import 'package:flutter3APP/views/borrowMoney/detail/loan_application_detail_controller.dart';
import 'package:flutter3APP/models/home_page_data.dart';

class LoanApplicationDetailPage extends StatelessWidget {
  LoanApplicationDetailPage({Key? key}) : super(key: key);

  final controller = Get.put(LoanApplicationDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: _buildAppBar(),
      body: Obx(
        () => controller.product.value == null
            ? _buildEmptyState()
            : _buildContent(controller.product.value!),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      title: Text(
        'loanDetails'.tr,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Get.back(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE5E5E5)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'noDetailsAvailable'.tr,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Product product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildStatusHeader(product),
          const SizedBox(height: 5),
          _buildAmountCard(product),
          const SizedBox(height: 5),
          _buildOrderInfoCard(product),
          const SizedBox(height: 5),
          _buildBankInfoCard(product),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    product.appOrderStatus ?? 0,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(product.appOrderStatus ?? 0),
                  color: _getStatusColor(product.appOrderStatus ?? 0),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(product.appOrderStatus ?? 0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.productName ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(product.appOrderStatus ?? 0),
            ],
          ),
          if (product.appOrderStatus == 5 || product.appOrderStatus == 3)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: product.appOrderStatus == 5
                    ? Colors.red.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: product.appOrderStatus == 5
                      ? Colors.red.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    product.appOrderStatus == 5
                        ? Icons.error_outline
                        : Icons.schedule,
                    color: product.appOrderStatus == 5
                        ? Colors.red
                        : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      product.appOrderStatus == 22
                          ? 'reviewFailedTip'.tr
                          : product.appOrderStatus == 5
                          ? 'disbursementFailedTip'.tr
                          : 'disbursementWaitTip'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: product.appOrderStatus == 5
                            ? Colors.red
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
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

  Widget _buildAmountCard(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/state_empty.webp',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Loan Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAmountRow(
            'loanAmount'.tr,
            product.loanAmount ?? 0,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAmountItem(
                  'amountToReceive'.tr,
                  product.receiptAmount ?? 0,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountItem(
                  'repaymentAmount'.tr,
                  product.repayAmount ?? 0,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAmountItem(
                  'interest'.tr,
                  product.interest ?? 0,
                  Icons.percent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountItem(
                  'serviceFee'.tr,
                  (product.serviceFee ??
                      ((product.loanAmount ?? 0) -
                          (product.receiptAmount ?? 0))),
                  Icons.receipt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, num amount, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFFFFB800).withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isPrimary
            ? Border.all(color: const Color(0xFFFFB800).withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isPrimary ? 16 : 14,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: isPrimary ? const Color(0xFFFFB800) : Colors.grey[700],
            ),
          ),
          Text(
            '${'currencyUSD'.tr}${StringUtil.formatAmount(amount)}',
            style: TextStyle(
              fontSize: isPrimary ? 24 : 16,
              fontWeight: FontWeight.bold,
              color: isPrimary ? const Color(0xFFFFB800) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(String label, num amount, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(height: 8),
          Text(
            '${'currencyUSD'.tr}${StringUtil.formatAmount(amount)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: const Color(0xFFFFB800),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Order Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'productName'.tr,
            product.productName ?? '',
            Icons.business,
          ),
          _buildInfoRow(
            'orderId'.tr,
            product.appOrderId ?? '',
            Icons.receipt,
          ),
          _buildInfoRow(
            'loanTerm'.tr,
            '${product.totalServiceDays ?? 0} ${'daysLabel'.tr}',
            Icons.schedule,
          ),
          _buildInfoRow(
            'repaymentDate'.tr,
            product.repayDateStr ?? '',
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfoCard(Product product) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: const Color(0xFFFFB800),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Bank Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'bankCard'.tr,
            product.bankCardName ?? '',
            Icons.credit_card,
          ),
          _buildInfoRow(
            'bankCardNumber'.tr,
            _maskBankCard(product.bankCardNo ?? ''),
            Icons.credit_card_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(int status) {
    Color chipColor = _getStatusColor(status);
    String statusText = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 20:
        return Colors.blue;
      case 22:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.green;
      case 5:
        return Colors.red;
      case 6:
        return Colors.green;
      case 7:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 20:
        return 'processingLabel'.tr;
      case 22:
        return 'rejection'.tr;
      case 3:
        return 'disbursing'.tr;
      case 4:
        return 'repaying'.tr;
      case 5:
        return 'disbursementFailed'.tr;
      case 6:
        return 'repaymentCompleted'.tr;
      case 7:
        return 'unknownStatus'.tr;
      default:
        return 'unknownStatus'.tr;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 20:
        return Icons.hourglass_empty;
      case 22:
        return Icons.cancel;
      case 3:
        return Icons.schedule;
      case 4:
        return Icons.trending_up;
      case 5:
        return Icons.error;
      case 6:
        return Icons.check_circle;
      case 7:
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _maskBankCard(String cardNumber) {
    if (cardNumber.length <= 8) return cardNumber;
    return '${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }
}
