import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../utils/widget/modern_form_widgets.dart';
import '../../kyc_step_controller.dart';

class NumberInputField extends StatelessWidget {
  final String code;
  final String label;
  final String currentValue;
  final KycStepController controller;
  final List<FocusNode> focusNodes;
  final Function(FocusNode) addFocusNode;

  const NumberInputField({
    Key? key,
    required this.code,
    required this.label,
    required this.currentValue,
    required this.controller,
    required this.focusNodes,
    required this.addFocusNode,
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
      child: TextFormField(
        controller: controller.controllers[code],
        keyboardType: code == '50002'
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: (code == '50002')
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : null,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: ModernFormWidgets.getModernInputDecoration(
          label: label,
          errorText:
              controller.isSubmitted.value &&
                  (controller.controllers[code]?.text.trim().isEmpty ?? true)
              ? 'pleaseFillAllFields'.tr
              : null,
        ),
        onChanged: (v) {
          controller.stepData[code] = v;
          if (v.trim().isNotEmpty) {
            controller.isSubmitted.value = false;
          }
        },
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return 'pleaseFillAllFields'.tr;
          }
          if (code == '50002' && v.trim().length != 10) {
            return 'Please enter 10 digits';
          }
          return null;
        },
      ),
    );
  }
}
