import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../utils/widget/modern_form_widgets.dart';
import '../../kyc_step_controller.dart';
import '../../../widgets/ios_picker_widget.dart';

class BankListDropdown extends StatelessWidget {
  final String code;
  final String label;
  final String currentValue;
  final KycStepController controller;

  const BankListDropdown({
    Key? key,
    required this.code,
    required this.label,
    required this.currentValue,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.bankList.length == 0) {
        return Container();
      }

      Set<String> uniqueValues = Set<String>();
      bool isValidValue = false;
      String displayValue = '';

      // 处理选项列表
      List<Map<String, dynamic>> processedOptions = [];
      for (var item in controller.bankList) {
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
              controller.update();
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
    });
  }
}
