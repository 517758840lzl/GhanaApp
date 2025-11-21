import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../utils/widget/modern_form_widgets.dart';
import '../../kyc_step_controller.dart';

class EmailInputField extends StatelessWidget {
  final String code;
  final String label;
  final String currentValue;
  final KycStepController controller;
  final List<FocusNode> focusNodes;
  final Function(FocusNode) addFocusNode;

  const EmailInputField({
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
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        String input = textEditingValue.text.contains('@')
            ? textEditingValue.text.split('@')[0]
            : textEditingValue.text;
        return controller.emailSuffixes.map((suffix) => '$input$suffix');
      },
      onSelected: (String selection) {
        FocusScope.of(context).unfocus();
        controller.stepData[code] = selection;
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4,
          child: Container(
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final String option = options.elementAt(index);
                return ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    onSelected(option);
                  },
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        );
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // 将Autocomplete提供的focusNode添加到我们的列表中
            addFocusNode(focusNode);

            if (controller.stepData[code] != null &&
                textEditingController.text.isEmpty) {
              textEditingController.text = controller.stepData[code]!;
            } else if (currentValue.isNotEmpty &&
                textEditingController.text.isEmpty) {
              textEditingController.text = currentValue;
            }
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
                controller: textEditingController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                decoration: ModernFormWidgets.getModernInputDecoration(
                  label: label,
                  hint: currentValue.isEmpty ? 'example@domain.com' : '',
                  errorText:
                      controller.isSubmitted.value &&
                          (textEditingController.text.trim().isEmpty)
                      ? 'pleaseFillAllFields'.tr
                      : null,
                  suffixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
                onChanged: (val) {
                  controller.stepData[code] = val;
                  if (val.trim().isNotEmpty) {
                    controller.isSubmitted.value = false;
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'pleaseFillAllFields'.tr;
                  }
                  return null;
                },
              ),
            );
          },
    );
  }
}
