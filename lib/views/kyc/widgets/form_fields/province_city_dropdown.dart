import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../utils/widget/modern_form_widgets.dart';
import '../../kyc_step_controller.dart';
import '../../../widgets/address_picker_widget.dart';

class ProvinceCityDropdown extends StatelessWidget {
  final String code;
  final String label;
  final String currentValue;
  final KycStepController controller;

  const ProvinceCityDropdown({
    Key? key,
    required this.code,
    required this.label,
    required this.currentValue,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.provinceCityCache['province'] == null ||
          controller.provinceCityCache['city'] == null) {
        return Container();
      }

      final cityParentIds =
          (controller.provinceCityCache['city'] as List<dynamic>)
              .map((city) => city['parentId'] as int)
              .toSet();

      final validProvinces =
          (controller.provinceCityCache['province'] as List<dynamic>)
              .where(
                (province) => cityParentIds.contains(province['id'] as int),
              )
              .toList();

      if (validProvinces.isEmpty) {
        return Text(AppStrings.noDataAvailable);
      }

      // 获取当前选中的省份和城市名称
      String selectedProvinceName = '';
      String selectedCityName = '';
      String displayText = '';

      if (controller.selectedProvince.value.isNotEmpty) {
        var province = validProvinces.firstWhere(
          (p) => p['id'].toString() == controller.selectedProvince.value,
          orElse: () => {'name': ''},
        );
        selectedProvinceName = province['name'] ?? '';
      }

      if (controller.selectedCity.value.isNotEmpty) {
        var cities = (controller.provinceCityCache['city'] as List<dynamic>)
            .where(
              (city) =>
                  city['parentId'] ==
                  int.parse(controller.selectedProvince.value),
            )
            .toList();
        var city = cities.firstWhere(
          (c) => c['id'].toString() == controller.selectedCity.value,
          orElse: () => {'name': ''},
        );
        selectedCityName = city['name'] ?? '';
      }

      // 组合显示文本
      if (selectedProvinceName.isNotEmpty && selectedCityName.isNotEmpty) {
        displayText = '$selectedProvinceName, $selectedCityName';
      } else if (selectedProvinceName.isNotEmpty) {
        displayText = selectedProvinceName;
      }

      // 检查是否已选择完整的省市信息
      bool isComplete =
          controller.selectedProvince.value.isNotEmpty &&
          controller.selectedCity.value.isNotEmpty;

      return TextFormField(
        readOnly: true,
        controller: TextEditingController(text: displayText),
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        decoration: ModernFormWidgets.getModernInputDecoration(
          label: label,
          hint: AppStrings.pleaseSelectBothProvinceAndCity,
          errorText: controller.isSubmitted.value && !isComplete
              ? AppStrings.pleaseFillAllFields
              : null,
          suffixIcon: Icon(
            Icons.location_on,
            color: Colors.grey[600],
            size: 20,
          ),
        ),
        onTap: () async {
          AppEventTracker.instance.startInteraction(
            controller.currentStep.value,
            code,
            label,
          );

          final result = await AddressPickerWidget.showAddressPicker(
            Get.context!,
            label,
            controller.provinceCityCache['province'] as List<dynamic>,
            controller.provinceCityCache['city'] as List<dynamic>,
            controller.selectedProvince.value,
            controller.selectedCity.value,
          );

          if (result != null) {
            controller.onAddressSelected(result);
            // 启动自动链式调用
            await controller.autoTriggerNextSelectableField(code, Get.context!);
          }

          AppEventTracker.instance.endInteraction(
            controller.currentStep.value,
            code,
          );
        },
        validator: (value) {
          if (controller.isSubmitted.value && !isComplete) {
            return AppStrings.pleaseFillAllFields;
          }
          return null;
        },
      );
    });
  }
}
