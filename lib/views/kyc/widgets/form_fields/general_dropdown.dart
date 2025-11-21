import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../utils/widget/modern_form_widgets.dart';
import '../../kyc_step_controller.dart';
import '../../../widgets/ios_picker_widget.dart';

class GeneralDropdown extends StatelessWidget {
  final String code;
  final String label;
  final String currentValue;
  final List? selectList;
  final KycStepController controller;

  const GeneralDropdown({
    Key? key,
    required this.code,
    required this.label,
    required this.currentValue,
    required this.selectList,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Set<String> uniqueValues = <String>{};
    bool isValidValue = false;
    String displayValue = '';

    if (selectList == null || selectList!.isEmpty) {
      return TextFormField(
        readOnly: true,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: ModernFormWidgets.getModernInputDecoration(
          label: label,
          errorText: controller.isSubmitted.value
              ? 'pleaseFillAllFields'.tr
              : null,
          suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ),
        onTap: () {
          // 空列表时不做任何操作
        },
        validator: (val) =>
            controller.isSubmitted.value && (val == null || val.isEmpty)
            ? 'pleaseFillAllFields'.tr
            : null,
      );
    }

    // 处理选项列表
    List<Map<String, dynamic>> processedOptions = [];
    for (var item in selectList!) {
      String value = item['value'].toString();
      String itemKey = item['key'].toString();

      if (uniqueValues.contains(value)) {
        value = itemKey;
      } else {
        uniqueValues.add(value);
      }

      if (itemKey == currentValue) {
        isValidValue = true;
        displayValue = value;
      }

      processedOptions.add({'key': itemKey, 'value': value});
    }

    if (!isValidValue && currentValue != 'pleaseSelect'.tr) {
      displayValue = '';
    }

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: displayValue),
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: ModernFormWidgets.getModernInputDecoration(
        label: label,
        errorText:
            controller.isSubmitted.value &&
                (currentValue.isEmpty || !isValidValue)
            ? 'pleaseFillAllFields'.tr
            : null,
        suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
      ),
      onTap: () async {
        AppEventTracker.instance.startInteraction(
          controller.currentStep.value,
          code,
          label,
        );
        await IOSPickerWidget.showIOSPicker(
          Get.context!,
          label,
          processedOptions,
          (selectedValue) {
            controller.stepData[code] = selectedValue;
            // 触发UI更新
            controller.update();
            // 启动自动链式调用
            controller.autoTriggerNextSelectableField(code, Get.context!);
          },
          currentValue,
        );
        AppEventTracker.instance.endInteraction(
          controller.currentStep.value,
          code,
        );
      },
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'pleaseFillAllFields'.tr;
        }
        return null;
      },
    );
  }
}
