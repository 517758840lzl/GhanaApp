import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../models/bank_card.dart';
import '../../../../common/colors/app_colors.dart';
import '../../../../utils/string/string_util.dart';
import '../../../../common/toast.dart';
import '../../../../http/api_urls.dart';
import '../../../../routes/routes.dart';

class BankCardSelectionController extends GetxController {
  // 银行卡列表
  final bankCardList = <BankCardInfo>[].obs;
  final Rx<BankCardInfo?> selectedBankCard = Rx<BankCardInfo?>(null);

  // 回调函数类型定义
  Function(BankCardInfo)? onBankCardSelected;

  @override
  void onInit() {
    super.onInit();
  }

  /// 初始化控制器
  void initialize({
    required Function(BankCardInfo) onSelected,
    BankCardInfo? currentSelectedCard,
  }) {
    onBankCardSelected = onSelected;
    selectedBankCard.value = currentSelectedCard;
  }

  /// 获取银行卡列表
  Future<void> fetchBankCardList() async {
    try {
      final result = await ApiUrls.getBankCardList();
      if (result.isSucceed && result.rawData != null) {
        final List<Map<String, dynamic>> rawList =
            List<Map<String, dynamic>>.from(
              result.rawData["userBankCardInfoRespList"],
            );
        final mapped =
            rawList.map((e) => BankCardInfoMapper.fromMap(e)).toList() ?? [];
        bankCardList.value = mapped;

        // 设置当前选中的银行卡
        if (selectedBankCard.value != null) {
          // 如果已经设置了选中的银行卡，在列表中查找对应的银行卡
          final currentCard = mapped.firstWhere(
            (card) => card.id == selectedBankCard.value!.id,
            orElse: () => mapped.isNotEmpty
                ? mapped.first
                : BankCardInfo(
                    bankCardNo: '',
                    bankId: 0,
                    bankName: '',
                    id: 0,
                    priority: 0,
                  ),
          );
          selectedBankCard.value = currentCard;
        } else if (mapped.isNotEmpty) {
          // 如果没有设置选中的银行卡，默认选择第一个
          selectedBankCard.value = mapped.first;
        }
      } else {
        YDToast.text(
          result.msg.isNotEmpty
              ? result.msg
              : 'errorFetchingBankCards'.tr,
        );
      }
    } catch (e) {
      YDToast.text('errorFetchingBankCards'.tr);
    }
  }

  /// 选择银行卡
  Future<void> selectBankCard(BankCardInfo bankCard) async {
    // 如果选择的银行卡不是当前传入的银行卡，先设置为默认银行卡
    if (selectedBankCard.value != null &&
        selectedBankCard.value!.id != bankCard.id) {
      try {
        YDToast.loading();
        final result = await ApiUrls.setDefaultBankCardRequest(
          cardId: bankCard.id,
        );
        YDToast.cleanAll();

        if (result.isSucceed) {
          // 更新选中状态
          selectedBankCard.value = bankCard;

          // 调用回调函数
          if (onBankCardSelected != null) {
            onBankCardSelected!(bankCard);
          }
        } else {
          YDToast.text(
            result.msg.isNotEmpty
                ? result.msg
                : 'errorSettingDefaultCard'.tr,
          );
        }
      } catch (e) {
        YDToast.cleanAll();
        YDToast.text('errorSettingDefaultCard'.tr);
      }
    } else {
      // 如果是当前银行卡或没有传入银行卡，直接选择
      selectedBankCard.value = bankCard;

      // 调用回调函数
      if (onBankCardSelected != null) {
        onBankCardSelected!(bankCard);
      }
    }
  }

  /// 显示银行卡选择弹窗
  Future<void> showBankCardSelectionDialog({
    required Function(BankCardInfo) onSelected,
    BankCardInfo? currentSelectedCard,
  }) async {
    // 初始化控制器
    initialize(
      onSelected: onSelected,
      currentSelectedCard: currentSelectedCard,
    );

    // 先获取银行卡列表
    await fetchBankCardList();

    if (bankCardList.isEmpty) {
      YDToast.text('noBankCardsFound'.tr);
      return;
    }

    await Get.bottomSheet(
      _buildBankCardSelectionBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// 构建银行卡选择底部弹窗
  Widget _buildBankCardSelectionBottomSheet() {
    return Container(
      height: Get.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text(
                  'Select Bank Card',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),

          // 银行卡列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: bankCardList.length,
              itemBuilder: (context, index) {
                final card = bankCardList[index];
                final isSelected = selectedBankCard.value?.id == card.id;

                return _buildBankCardItem(card, isSelected);
              },
            ),
          ),

          // 底部添加按钮
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 分割线
                Container(
                  height: 1,
                  color: Colors.grey[200],
                  margin: const EdgeInsets.only(bottom: 16),
                ),

                // 添加按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToAddBankCard(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Add New Bank Card',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  /// 跳转到添加银行卡页面
  Future<void> _navigateToAddBankCard() async {
    final result = await Get.toNamed(Routes.bankCardForm);

    // 如果添加成功返回，刷新银行卡列表
    if (result == true) {
      await fetchBankCardList();
    }
  }

  /// 对外暴露：跳转新增银行卡，返回是否成功
  Future<bool> navigateToAddBankCard() async {
    final result = await Get.toNamed(Routes.bankCardForm);
    return result == true;
  }

  /// 构建银行卡项
  Widget _buildBankCardItem(BankCardInfo card, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await selectBankCard(card);
            Get.back();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 银行卡图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // 银行卡信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.bankName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        StringUtil.maskCardNumber(card.bankCardNo),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (card.priority > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'defaultCard'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 选择指示器
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryColor
                        : Colors.grey[300],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
