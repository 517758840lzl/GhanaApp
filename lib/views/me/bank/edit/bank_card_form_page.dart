import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../../common/colors/app_colors.dart';
import '../../../../utils/widget/modern_form_widgets.dart';
import '../../../../views/widgets/ios_picker_widget.dart';
import 'bank_card_form_controller.dart';

/// 银行卡表单模式枚举
enum BankCardMode { add, update }

/// 银行卡表单页面
class BankCardFormPage extends StatelessWidget {
  BankCardFormPage({Key? key}) : super(key: key);

  final BankCardFormController controller = Get.put(BankCardFormController());
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.grey[50],
        appBar: AppBar(
          title: Text(
            controller.mode == BankCardMode.add
                ? 'addBankCard'.tr
                : 'editBankCard'.tr,
          ),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: Container(
          width: double.infinity,   // 占满宽度
          height: double.infinity,  // 占满高度
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, // 渐变开始的位置
              end: Alignment.bottomCenter, // 渐变结束的位置
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.1),
              ],
              stops: [0.0, 0.6],
            ),
          ),
          child: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width * 0.05,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 表单卡片
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Account type selection
                            Semantics(
                              label: 'accountTypeSelection'.tr,
                              child: Text(
                                'accountType'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            controller.bankTypes.isEmpty
                                ? Container(
                                  key: Key('loading_account_types'),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Semantics(
                                        label:
                                            'loadingAccountTypes'.tr,
                                        child: Text(
                                          'loadingAccountTypes'.tr,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : _buildSelectionField(
                                  controller,
                                  'accountType'.tr,
                                  controller.selectedBankType.value,
                                  controller.bankTypes,
                                  (value) =>
                                      controller.selectedBankType.value =
                                          value,
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'pleaseSelectAccountType'.tr
                                              : null,
                                ),

                            const SizedBox(height: 8),

                            // Bank selection
                            Semantics(
                              label: 'bankSelection'.tr,
                              child: Text(
                                'selectBank'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            controller.bankList.isEmpty
                                ? Container(
                                  key: Key('loading_bank_list'),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 12),
                                      Semantics(
                                        label: 'loadingBankList'.tr,
                                        child: Text(
                                          'loadingBankList'.tr,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : _buildBankSelectionField(controller),
                            const SizedBox(height: 8),

                            // Card number input
                            Semantics(
                              label: 'cardNumberInput'.tr,
                              child: Text(
                                'cardNumber'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ModernFormWidgets.buildShadowedInputField(
                              Semantics(
                                label: 'cardNumberInputField'.tr,
                                child: TextFormField(
                                  controller:
                                      controller.bankCardNoController.value,
                                  decoration:
                                      ModernFormWidgets.getModernInputDecoration(
                                        label: 'cardNumber'.tr,
                                        hint: 'pleaseEnterCardNumber'.tr,
                                      ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).unfocus();
                                  },
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'enterCardNumber'.tr;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 提示信息
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'bankAccountTip'.tr,
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 提交按钮
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // 隐藏键盘
                          FocusScope.of(context).unfocus();
                          controller.submitBankCard(
                            context,
                            isUpdate: controller.mode == BankCardMode.update,
                            cardId: controller.bankCardInfo.value?.id,
                          );
                        },
                        key: Key('submit_bank_card_button'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          controller.mode == BankCardMode.add
                              ? 'addCard'.tr
                              : 'updateCard'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建选择字段
  /// [controller] 控制器实例
  /// [label] 字段标签
  /// [currentValue] 当前选中的值
  /// [options] 选项列表
  /// [onChanged] 选择改变回调
  /// [validator] 验证函数
  Widget _buildSelectionField(
    BankCardFormController controller,
    String label,
    String currentValue,
    List<Map<String, String>> options,
    Function(String) onChanged,
    {String? Function(String?)? validator}
  ) {
    String displayValue = '';
    try {
      if (currentValue.isNotEmpty && options.isNotEmpty) {
        final selectedOption = options.firstWhere(
          (option) => option['key'] == currentValue,
          orElse: () => {'key': '', 'value': ''},
        );
        displayValue = selectedOption['value'] ?? '';
      }
    } catch (e) {
      // 处理异常情况
      displayValue = '';
    }

    // 将选项转换为选择器需要的格式
    final List<Map<String, dynamic>> pickerOptions = options
        .map((option) => {
              'key': option['key'] ?? '',
              'value': option['value'] ?? '',
            })
        .toList();

    return ModernFormWidgets.buildShadowedInputField(
      TextFormField(
        readOnly: true,
        controller: TextEditingController(text: displayValue),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: ModernFormWidgets.getModernInputDecoration(
          label: label,
          errorText: currentValue.isEmpty ? validator?.call(null) : null,
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ),
        onTap: () async {
          if (options.isNotEmpty) {
            await IOSPickerWidget.showIOSPicker(
              Get.context!,
              label,
              pickerOptions,
              (value) => onChanged(value),
              currentValue,
            );
          }
        },
        validator: validator,
      ),
    );
  }

  /// 构建银行选择字段
  /// [controller] 控制器实例
  Widget _buildBankSelectionField(BankCardFormController controller) {
    String displayValue = '';
    try {
      if (controller.selectedBankId.value.isNotEmpty &&
          controller.bankList.isNotEmpty) {
        final selectedBank = controller.bankList.firstWhere(
          (bank) => bank['id'].toString() == controller.selectedBankId.value,
          orElse: () => {'id': '', 'bankName': ''},
        );
        displayValue = selectedBank['bankName']?.toString() ?? '';
      }
    } catch (e) {
      // 处理异常情况
      displayValue = '';
    }

    final List<Map<String, dynamic>> bankOptions = controller.getBankOptions();

    return ModernFormWidgets.buildShadowedInputField(
      TextFormField(
        readOnly: true,
        controller: TextEditingController(text: displayValue),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: ModernFormWidgets.getModernInputDecoration(
          label: 'selectBank'.tr,
          errorText:
              controller.selectedBankId.value.isEmpty
                  ? 'pleaseSelectBank'.tr
                  : null,
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ),
        onTap: () async {
          if (controller.bankList.isNotEmpty) {
            await IOSPickerWidget.showIOSPicker(
              Get.context!,
              'selectBank'.tr,
              bankOptions,
              (value) => controller.selectedBankId.value = value,
              controller.selectedBankId.value,
            );
          }
        },
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'pleaseSelectBank'.tr
                    : null,
      ),
    );
  }
}
