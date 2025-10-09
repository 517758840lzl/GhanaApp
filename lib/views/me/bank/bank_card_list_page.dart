import 'package:flutter/material.dart';
import '../../../basa/main_constant.dart';
import '../../../models/bank_card.dart';
import '../../../common/colors/app_colors.dart';
import 'package:get/get.dart';
import 'bank_card_list_controller.dart';
import '../../../l10n/app_strings.dart';

// 导入BankCardMode枚举

class BankCardListPage extends StatelessWidget {
  const BankCardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BankCardListController controller = Get.put(BankCardListController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          AppStrings.myBankCards,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 可用银行卡数量显示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Obx(
              () => Text(
                'Available Bank Cards (${controller.bankCardInfoList.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ),
          // 主要内容区域
          Expanded(
            child: Obx(
              () => RefreshIndicator(
                onRefresh: () async {
                  // 这里可以添加刷新逻辑
                  controller.refreshBankCardList();
                },
                child: controller.bankCardInfoList.isEmpty
                    ? _buildEmptyState()
                    : _buildBankCardList(controller),
              ),
            ),
          ),

          // 底部操作区域
          controller.edit == true
              ? _buildBottomActions(controller)
              : Container(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.noBankCardsFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.addFirstBankCard,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCardList(BankCardListController controller) {
    return Obx(
      () => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.bankCardInfoList.length,
        itemBuilder: (context, index) {
          final card = controller.bankCardInfoList[index];
          final isDefault = card.priority > 0;
          final bgColor = _getBankCardColor(card.bankName);

          return Obx(
            () => _buildBankCardItem(
              card: card,
              bgColor: bgColor,
              isDefault: isDefault,
              isSelected: controller.selectedCard.value?.id == card.id,
              controller: controller,
            ),
          );
        },
      ),
    );
  }

  // 根据银行名称返回随机卡片颜色
  Color _getBankCardColor(String bankName) {
    // 使用银行名称的hashCode来生成一致的随机颜色
    final colors = [
      const Color(0xFFE53E3E), // 红色
      const Color(0xFFFF8C00), // 橙色
      const Color(0xFF1E40AF), // 蓝色
      const Color(0xFF059669), // 绿色
      const Color(0xFF7C3AED), // 紫色
      const Color(0xFFDC2626), // 深红色
      const Color(0xFF0891B2), // 青色
      const Color(0xFFCA8A04), // 黄色
      const Color(0xFFBE185D), // 粉色
      const Color(0xFF7C2D12), // 棕色
    ];

    // 使用银行名称的hashCode来确保同一银行总是显示相同颜色
    final index = bankName.hashCode.abs() % colors.length;
    return colors[index];
  }

  Widget _buildBankCardItem({
    required BankCardInfo card,
    required Color bgColor,
    required bool isDefault,
    required bool isSelected,
    required BankCardListController controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withValues(alpha: 0.08),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgColor, bgColor.withValues(alpha: 0.9)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Constant.APP_BLACK_CARD
                ? isSelected
                      ? Border.all(color: AppColors.primaryColor, width: 2)
                      : null
                : null,
          ),
          child: Stack(
            children: [
              // 背景水印
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: _buildBankLogo(card.bankName, 80),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.selectedCard.value = card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 顶部行：银行logo、名称和操作按钮
                      Row(
                        children: [
                          // 银行logo
                          _buildBankLogo(card.bankName, 32),
                          const SizedBox(width: 12),
                          // 银行名称和卡类型
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${card.bankName}${card.bankTypeDesc ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                if (isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      AppStrings.defaultCard,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // 编辑按钮
                          if (controller.edit == true)
                            Row(
                              children: [
                                // 选择指示器
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.white.withValues(alpha: 0.3),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 卡号
                      Text(
                        card.bankCardNo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // 底部行：持卡人信息和默认标识
                      Row(
                        children: [
                          if (card.holderName != null &&
                              card.holderName!.isNotEmpty)
                            Expanded(
                              child: Text(
                                card.holderName!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // 操作按钮区域
                      _buildCardActionButtons(card, controller),
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

  // 构建银行logo
  Widget _buildBankLogo(String bankName, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getBankInitial(bankName),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 获取银行首字母
  String _getBankInitial(String bankName) {
    return bankName.isNotEmpty ? bankName[0].toUpperCase() : 'B';
  }

  // 构建卡片操作按钮
  Widget _buildCardActionButtons(
    BankCardInfo card,
    BankCardListController controller,
  ) {
    return Center(
      child: _buildActionButton(
        text: AppStrings.edit,
        onTap: () {
          // 管理卡片逻辑
          controller.navigateToEditCard(card, controller);
        },
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    String? text,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: text != null
            ? Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildBottomActions(BankCardListController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 设置默认按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: controller.setDefaultCard,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.setAsDefault,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 添加银行卡按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => controller.navigateToAddCard(controller),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    AppStrings.addBankAccount,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
