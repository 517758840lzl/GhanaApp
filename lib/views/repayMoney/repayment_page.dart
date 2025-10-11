import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3APP/utils/string/string_util.dart';
import '../../common/colors/app_colors.dart';
import '../../l10n/app_strings.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import 'repayment_controller.dart';

class RepaymentPage extends StatelessWidget {
  RepaymentPage({Key? key}) : super(key: key);

  final controller = Get.put(RepaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Obx(
        () => Column(
          children: [
            // 顶部统计卡片
            if (controller.items.length != 0) _buildStatsCard(),

            // 列表区域
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshData(),
                child: controller.items.length == 0
                    ? _buildEmptyView()
                    : _buildRepaymentList(),
              ),
            ),

            // 底部操作栏
            if (controller.items.length != 0) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Text(
        AppStrings.repayment,
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Image.asset(
              'assets/images/icon_service_two.webp',
              width: 22,
              height: 22,
            ),
            onPressed: () => Get.toNamed(Routes.contact),
          ),
        ),
      ],
    );
  }

  // 简洁的顶部统计卡片
  Widget _buildStatsCard() {
    return Container(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
        child: Column(
          children: [
            // 支付提示信息
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.paymentUpdateNotice,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 还款列表
  Widget _buildRepaymentList() {
    return ListView.builder(
      itemCount: controller.items.length,
      itemBuilder: (context, index) {
        final item = controller.items[index];
        final isSelected = controller.selectedMap[item.appOrderId] ?? true;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.toggleSelect(index),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部区域
                    Row(
                      children: [
                        // 产品图标和名称
                        if (controller.cacheFlag.value == 0) ...[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFF8F9FA),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                item.productLogo,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    size: 15,
                                    color: Color(0xFF9CA3AF),
                                  ),
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
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // 状态标签
                                _buildStatusBadge(item),
                              ],
                            ),
                          ),
                        ],
                        // 选择框
                        _buildSelectionBox(isSelected),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 金额显示区域
                    Container(
                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // 金额信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      AppStrings.currencyUSD,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      StringUtil.formatAmount(item.repayAmount),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.dueDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.repayDateStr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 还款按钮
                          _buildRepayButton(item),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 选择框
  Widget _buildSelectionBox(bool isSelected) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : const Color(0xFFD1D5DB),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: Colors.black)
          : null,
    );
  }

  // 状态标签
  Widget _buildStatusBadge(dynamic item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(item).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(item).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(item),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(item),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(item),
            ),
          ),
        ],
      ),
    );
  }

  // 还款按钮
  Widget _buildRepayButton(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () =>
              controller.goToRepaymentSubmitPage(orderIds: [item.appOrderId]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.payment, size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  AppStrings.repayNow,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 底部操作栏
  Widget _buildBottomActionBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 支付按钮
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => controller.goToAllRepaymentSubmitPage(
                    orderIds: controller.selectedOrderIds,
                    productCodes: controller.selectedProductCodes,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 18, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        '${AppStrings.repayNow} ${AppStrings.currencyUSD}${StringUtil.formatAmount(controller.totalSelectedAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 重新设计的空状态页面
  Widget _buildEmptyView() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 主图标区域
          Container(
            child: Image.asset(
              'assets/images/state_empty.webp',
              width: 120,
              height: 120,
            ),
          ),

          const SizedBox(height: 15),

          // 主标题
          Text(
            AppStrings.noRepaymentRecords,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // 描述文本
          Text(
            AppStrings.noRepaymentRecordsDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // 操作按钮
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => controller.loadRepaymentData(loading: true),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.refreshToCheck,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取状态颜色
  Color _getStatusColor(dynamic item) {
    if (item.orderStatus == 5) {
      return const Color(0xFF0369A1); // 处理中 - 蓝色
    } else if (item.remainingDays >= 0) {
      return const Color(0xFFF59E0B); // 正常 - 橙色
    } else {
      return const Color(0xFFDC2626); // 逾期 - 红色
    }
  }

  // 获取状态文本
  String _getStatusText(dynamic item) {
    if (item.orderStatus == 5) {
      return AppStrings.inProcess;
    } else if (item.remainingDays >= 0) {
      return AppStrings.processing;
    } else {
      return AppStrings.overdue;
    }
  }
}
