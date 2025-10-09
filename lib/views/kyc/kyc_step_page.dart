import 'dart:io';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/basa/analytics/app_event_tracker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../routes/routes.dart';
import '../../common/colors/app_colors.dart';
import '../../../l10n/app_strings.dart';
import '../../../utils/widget/modern_form_widgets.dart';
import '../widgets/KYC_exit_dialog.dart';
import '../widgets/ios_picker_widget.dart';
import 'kyc_step_controller.dart';
import 'widgets/kyc_header_view.dart';
import 'widgets/form_fields/email_input_field.dart';
import 'widgets/form_fields/province_city_dropdown.dart';
import 'widgets/form_fields/bank_list_dropdown.dart';
import 'widgets/form_fields/general_dropdown.dart';
import 'widgets/form_fields/contact_selection_field.dart';
import 'widgets/form_fields/number_input_field.dart';
import 'widgets/form_fields/image_upload_field.dart';
import 'widgets/form_fields/face_recognition_field.dart';
import 'widgets/form_fields/read_only_field.dart';

class KycStepPage extends StatelessWidget {
  KycStepPage({super.key});

  final controller = Get.put(KycStepController());

  // 存储每个步骤创建的TextFormField的focusNode
  final List<FocusNode> _focusNodes = [];

  // 添加focusNode，避免重复，以最后一个为准
  void _addFocusNode(FocusNode focusNode) {
    // 移除已存在的相同focusNode
    _focusNodes.remove(focusNode);
    // 添加新的focusNode到列表末尾
    _focusNodes.add(focusNode);
  }

  // 收起键盘的新方案
  void _hideKeyboard(BuildContext context) {
    // 收起键盘 - 移除所有焦点
    for (var focusNode in _focusNodes) {
      focusNode.unfocus();
    }
    FocusScope.of(context).unfocus();
  }

  // 清理上一步的focusNode
  void _clearPreviousStepFocusNodes() {
    _focusNodes.clear();
  }

  void onContinue(BuildContext context, KycStepController controller) async {
    // 收起键盘 - 使用新的方案
    _hideKeyboard(context);
    // 清理上一步的focusNode
    _clearPreviousStepFocusNodes();

    // 然后处理继续逻辑
    controller.handleContinue();
  }

  // 构建表单
  Widget _buildForm(KycStepController controller, BuildContext context) {
    if (controller.processSteps.isEmpty) {
      return Center(child: Text(AppStrings.noData));
    }

    List<Widget> formFields = [];
    for (var step in controller.processSteps) {
      if (step['step'] == controller.currentStep.value) {
        for (var entry in step['entries'] ?? {}) {
          final code = entry['code'] as String;
          final type = entry['type'] as int;
          final label = (entry['showContent'] ?? entry['defaultText'] ?? code)
              .toString();
          final currentValue = controller.stepData[code]?.toString() ?? '';
          Widget field;

          switch (type) {
            case 1: // 文本输入
              //key == 'iojkluy'
              if (code == '10003') {
                field = EmailInputField(
                  code: code,
                  label: label,
                  currentValue: currentValue,
                  controller: controller,
                  focusNodes: _focusNodes,
                  addFocusNode: _addFocusNode,
                );
              } else {
                if (!controller.controllers.containsKey(code)) {
                  controller.controllers[code] = TextEditingController(
                    text: currentValue,
                  );
                }
                // 创建FocusNode并添加到列表
                final focusNode = FocusNode();
                _addFocusNode(focusNode);

                field = Focus(
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
                    keyboardType: (code == '50002' || code == '40002')
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: (code == '40002')
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ]
                        : (code == '50002')
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
                    ),
                    onChanged: (v) => controller.stepData[code] = v,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return AppStrings.pleaseFillAllFields;
                      }
                      if (code == '40002' && v.trim().length != 11) {
                        return 'Please enter 11 digits';
                      }
                      if (code == '50002' && v.trim().length != 10) {
                        return 'Please enter 10 digits';
                      }
                      return null;
                    },
                  ),
                );
              }
              break;
            case 2: // 下拉选择
              //key == 'hfgdgscsddf'
              if (code == "10004") {
                field = ProvinceCityDropdown(
                  code: code,
                  label: label,
                  currentValue: currentValue,
                  controller: controller,
                );
              } else if (code == '50005') {
                field = BankListDropdown(
                  code: code,
                  label: label,
                  currentValue: currentValue,
                  controller: controller,
                );
              } else {
                field = GeneralDropdown(
                  code: code,
                  label: label,
                  currentValue: currentValue,
                  selectList: entry['selectList'],
                  controller: controller,
                );
              }
              break;
            case 3:
            case 9:
            case 10: // 数字输入或联系人选择
              // 联系人选择字段
              if (code == '30053' ||
                  code == '30063' ||
                  code == '30052' ||
                  code == '30062') {
                field = ContactSelectionField(
                  code: code,
                  label: label,
                  currentValue: currentValue,
                  type: entry['type'],
                  controller: controller,
                  context: context,
                  focusNodes: _focusNodes,
                  addFocusNode: _addFocusNode,
                  hideKeyboard: () => _hideKeyboard(context),
                );
              } else {
                // 普通数字输入字段
                field = NumberInputField(
                  code: code,
                  label: label,
                  currentValue: currentValue,
                  controller: controller,
                  focusNodes: _focusNodes,
                  addFocusNode: _addFocusNode,
                );
              }
              break;
            case 4: // 性别选择
              const Map<String, String> genderMap = {
                '1': AppStrings.male,
                '2': AppStrings.female,
              };
              // 移除未使用的反向性别映射
              String? displayValue =
                  controller.stepData[code]?.toString().isNotEmpty == true
                  ? genderMap[controller.stepData[code].toString()]
                  : null;
              List<Map<String, dynamic>> genderOptions = [
                {'key': '1', 'value': AppStrings.male},
                {'key': '2', 'value': AppStrings.female},
              ];

              field = TextFormField(
                readOnly: true,
                controller: TextEditingController(text: displayValue ?? ''),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                decoration: ModernFormWidgets.getModernInputDecoration(
                  label: label,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
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
                    genderOptions,
                    (selectedValue) {
                      controller.stepData[code] = selectedValue;
                      controller.update();
                    },
                    controller.stepData[code]?.toString() ?? '',
                  );
                  AppEventTracker.instance.endInteraction(
                    controller.currentStep.value,
                    code,
                  );
                },
                validator: (String? v) {
                  if (controller.isSubmitted.value &&
                      (v == null || v.isEmpty)) {
                    return AppStrings.pleaseFillAllFields;
                  }
                  return null;
                },
              );
              break;
            case 5: // 日期选择
              if (!controller.controllers.containsKey(code)) {
                controller.controllers[code] = TextEditingController(
                  text: controller.stepData[code] ?? '',
                );
              }
              field = TextFormField(
                controller: controller.controllers[code],
                readOnly: true,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                decoration: ModernFormWidgets.getModernInputDecoration(
                  label: label,
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                ),
                onTap: () async {
                  AppEventTracker.instance.startInteraction(
                    controller.currentStep.value,
                    code,
                    label,
                  );
                  BottomPicker.date(
                    dismissable: true,
                    dateOrder: DatePickerDateOrder.dmy,
                    initialDateTime: DateTime(1990, 1, 1),
                    maxDateTime: DateTime(2100),
                    minDateTime: DateTime(1950),
                    onSubmit: (pick) {
                      if (pick != null) {
                        final formatted = DateFormat('yyyy-MM-dd').format(pick);
                        controller.stepData[code] = formatted;
                        controller.syncController(code, formatted);
                        controller.isSubmitted.value = false;
                      }
                      AppEventTracker.instance.endInteraction(
                        controller.currentStep.value,
                        code,
                      );
                    },
                    onDismiss: (p0) {
                      AppEventTracker.instance.endInteraction(
                        controller.currentStep.value,
                        code,
                      );
                    },
                    bottomPickerTheme: BottomPickerTheme.orange,
                  ).show(Get.context!);
                  // 兜底结束一次
                  AppEventTracker.instance.endInteraction(
                    controller.currentStep.value,
                    code,
                  );
                },
                validator: (String? v) {
                  if (controller.isSubmitted.value &&
                      (v == null || v.isEmpty)) {
                    return AppStrings.pleaseFillAllFields;
                  }
                  return null;
                },
              );
              break;
            case 6: // 图片上传
              field = ImageUploadField(
                label: label,
                code: entry['code'] ?? "",
                defaultText: entry['defaultText'] ?? "",
                controller: controller,
              );
              break;
            case 7: // 人脸识别
              field = FaceRecognitionField(
                code: code,
                label: label,
                controller: controller,
              );
              break;
            case 8: // 只读字段
              field = ReadOnlyField(label: label, currentValue: currentValue);
              break;
            default:
              field = Container();
          }
          if (type != 8) {
            formFields.add(
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  // 确保 opacity 值在有效范围内
                  final opacity = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: field,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            formFields.add(
              TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  // 确保 opacity 值在有效范围内
                  final opacity = value.clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        child: field,
                      ),
                    ),
                  );
                },
              ),
            );
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: formFields,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 收起键盘 - 使用新的方案
        _hideKeyboard(context);
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          // 收起键盘 - 使用新的方案
          _hideKeyboard(context);

          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => KYCExitDialog(),
          );
          if (shouldExit == true) {
            if (Platform.isAndroid) {
              exit(0);
            } else {
              Get.back(result: true);
            }
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              // 自定义导航栏
              Container(
                color: AppColors.primaryColor,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // 返回按钮
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              _hideKeyboard(context);
                              AppEventTracker.instance.recordExitEvent(
                                controller.currentStep.value,
                              );
                              final shouldExit = await showDialog<bool>(
                                context: context,
                                builder: (context) => KYCExitDialog(),
                              );
                              if (shouldExit == true) {
                                if (Platform.isAndroid) {
                                  exit(0);
                                } else {
                                  Get.until((route) => route.isFirst);
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // 标题
                        Expanded(
                          child: Center(
                            child: Obx(
                              () => Text(
                                controller.pageTitle.value,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 客服按钮
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(Routes.contact);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.asset(
                                'assets/images/icon_service_two.webp',
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              KycHeaderView(controller: controller),
              // 主要内容区域
              Expanded(
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(color: Colors.grey[50]),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                            child: Form(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildForm(controller, context),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.04,
                                  ),

                                  // 继续按钮
                                  Container(
                                    margin: EdgeInsets.only(bottom: 20),
                                    child: Material(
                                      elevation: 8,
                                      borderRadius: BorderRadius.circular(16),
                                      shadowColor: AppColors.primaryColor
                                          .withOpacity(0.3),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primaryColor,
                                              AppColors.primaryColor
                                                  .withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () =>
                                                onContinue(context, controller),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              height: 60,
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        AppStrings.nextStep,
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,

                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.black,
                                                      size: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
