import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../common/colors/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../../kyc_step_controller.dart';

class ContactSelectionField extends StatelessWidget {
  final String code;
  final String label;
  final String currentValue;
  final int type;
  final KycStepController controller;
  final BuildContext context;
  final List<FocusNode> focusNodes;
  final Function(FocusNode) addFocusNode;
  final VoidCallback hideKeyboard;

  const ContactSelectionField({
    Key? key,
    required this.code,
    required this.label,
    required this.currentValue,
    required this.type,
    required this.controller,
    required this.context,
    required this.focusNodes,
    required this.addFocusNode,
    required this.hideKeyboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 确保控制器存在
    if (!controller.controllers.containsKey(code)) {
      controller.controllers[code] = TextEditingController(text: currentValue);
    }

    // 创建FocusNode并添加到列表
    final focusNode = FocusNode();
    addFocusNode(focusNode);

    // 判断是否可编辑
    bool isEditable = type == 10; // 10可选可输入，9只能选

    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          AppEventTracker.instance.startInteraction(
            controller.currentStep.value,
            code,
            label,
          );
        } else {
          AppEventTracker.instance.endInteraction(
            controller.currentStep.value,
            code,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          readOnly: !isEditable,
          controller: controller.controllers[code],
          keyboardType: TextInputType.phone,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            hintText: isEditable
                ? AppStrings.enterPhoneNumberOrSelectFromContacts
                : AppStrings.selectFromContacts,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Container(
              margin: EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    hideKeyboard();
                    AppEventTracker.instance.startInteraction(
                      controller.currentStep.value,
                      code,
                      label,
                    );
                    await controller.requestContactPermission(code);
                    AppEventTracker.instance.endInteraction(
                      controller.currentStep.value,
                      code,
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.contacts,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            errorText:
                controller.isSubmitted.value &&
                    (controller.controllers[code]?.text.trim().isEmpty ?? true)
                ? AppStrings.pleaseFillAllFields
                : null,
          ),
          onChanged: isEditable
              ? (val) {
                  controller.stepData[code] = val;
                  if (val.trim().isNotEmpty) {
                    controller.isSubmitted.value = false;
                  }
                }
              : null,
          validator: (val) {
            if (controller.isSubmitted.value &&
                (val == null || val.trim().isEmpty)) {
              return AppStrings.pleaseFillAllFields;
            }
            return null;
          },
        ),
      ),
    );
  }
}
