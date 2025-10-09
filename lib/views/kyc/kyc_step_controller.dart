import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
// import 'package:get/get_navigation/src/dialog/dialog_route.dart';
// import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:flutter3APP/basa/analytics/app_event_tracker.dart';
import 'package:flutter3APP/basa/appsFlyer/apps_flyer_helper.dart';
import 'package:flutter3APP/basa/updateData/user_updata_server.dart';
import 'package:flutter3APP/provider/userDataHelper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../../http/api_urls.dart';
// import '../../common/userDataHelper.dart';
import '../../http/headers/request_headers.dart';
import '../../common/logger/app_logger.dart';
import '../../utils/image/image_util.dart';
import '../../utils/non_repeatable_click.dart';
import '../../common/permission/permission_util.dart';
import '../../routes/routes.dart';
import '../widgets/confirm_bank_card_dialog.dart';
import '../widgets/KYC_exit_dialog.dart';
import '../widgets/ios_picker_widget.dart';
import '../widgets/address_picker_widget.dart';
import '../../common/toast.dart';
import '../../l10n/app_strings.dart';
import '../../models/step.dart';
import '../../models/startup_config.dart';

class KycStepController extends GetxController {
  static const platform = MethodChannel('com.example.face_liveness/channel');
  var token = ''.obs;
  var filledStep = 0.obs;
  var totalStep = 5.obs;
  var processSteps = [].obs;
  var currentStep = 0.obs;
  var stepData = <String, dynamic>{}.obs;
  var selectDataCache = <String, List<dynamic>>{}.obs;
  var dataMap = <String, dynamic>{}.obs;
  var provinceCityCache = <String, List<dynamic>>{}.obs;
  final selectedProvince = "".obs;
  final selectedCity = "".obs;
  var isSubmitted = false.obs;

  var pageTitle = ''.obs;
  var faceLiveSteps = <String>[].obs;
  var bankList = <dynamic>[].obs;

  final updataBool = true.obs; //是否上报

  var cardImage = ''.obs; //证件图片code：40007

  var cardBackImage = ''.obs; //证件背面图片code：40008
  var faceImage = ''.obs; //头像图片code：

  final emailSuffixes = [
    '@gmail.com',
    '@hotmail.com',
    '@zoho.com',
    '@outlook.com',
    '@yahoo.com',
    '@icloud.com',
    '@protonmail.com',
  ];
  final controllers = <String, TextEditingController>{};

  // KYC 步骤确认弹窗配置
  final Map<int, _ConfirmConfig> confirmConfigs = {
    3: _ConfirmConfig(
      fieldCode: '50002',
      dialogBuilder: (value) => ConfirmBankCardDialog(contents: value),
    ),
    // 3: _ConfirmConfig(
    //   fieldCode: '50002',
    //   dialogBuilder: (value) => ConfirmBankCardDialog(cardNo: value),
    // ),
    // 4: _ConfirmConfig(
    //   fieldCode: '40002',
    //   dialogBuilder: (value) => ConfirmBankCardDialog(cardNo: value, type: 1),
    // ),
  };

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    getLocation();
  }

  getLocation() async {
    final cacheFlag = await UserDataHelper.getCacheData();
    if (Platform.isIOS && cacheFlag == 0 && updataBool.value) {
      bool hasPermissions = await await PermissionUtil.checkAndRequest(
        Permission.location,
      );

      if (!hasPermissions) {
        PermissionUtil.showPermissionDialog(Permission.location);
        return;
      }

      //主动触发一次上报
      UpDataServer().triggerSingleReport();
      updataBool.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    // 页面准备就绪时开始页面事件
    if (currentStep.value > 0) {
      AppEventTracker.instance.startPageEvent(
        currentStep.value,
        pageTitle.value,
      );
    }
  }

  Future<void> _initializeData() async {
    await fetchAcquisitionProgress();
  }

  @override
  void onClose() {
    controllers.forEach((_, controller) => controller.dispose());
    // 清理事件数据
    AppEventTracker.instance.cleanData();
    super.onClose();
  }

  //获取人脸识别步骤
  Future<void> fetchStartupConfig({bool isLoading = false}) async {
    try {
      if (isLoading) {
        YDToast.loading();
      }
      final result = await ApiUrls.fetchStartupConfig();
      if (isLoading) {
        YDToast.cleanAll();
      }
      if (result.isSucceed && result.data != null) {
        final responseData = result.data ?? {};
        final configData = StartupConfigDataMapper.fromMap(responseData);
        final filteredSteps = configData.faceLiveStep;
        if (filteredSteps.isNotEmpty) {
          faceLiveSteps.assignAll(filteredSteps);
        }
      }
      else{
        if (isLoading) {
          YDToast.text(result.msg);
        }
      }
    } catch (e) {
      faceLiveSteps.assignAll(["headNod"]);
    }
  }

  //获取kyc进度
  Future<void> fetchAcquisitionProgress() async {
    YDToast.loading();
    try {
      final result = await ApiUrls.getAcquisitionProgressRaw();
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        final data = result.data;
        filledStep.value = data?['filledStep'];
        totalStep.value = data?['totalStep'];
        processSteps.value = data?['processSteps'];
        currentStep.value = filledStep.value + 1;
        processSteps.refresh();
        if (processSteps.isNotEmpty) {
          if (totalStep.value < currentStep.value) {
            Get.offAndToNamed(Routes.home);
          } else {
            await fetchStepElements(currentStep.value);
            // 开始页面事件
            AppEventTracker.instance.startPageEvent(
              currentStep.value,
              pageTitle.value,
            );
          }
        } else {
          YDToast.text(AppStrings.noStepsDataAvailable);
        }
      } else {
        YDToast.text(AppStrings.progressCouldNotBeObtained);
      }
    } catch (e) {
      LogUtil.d(e);
    }
  }

  Future<void> fetchStepElements(int step) async {
    YDToast.loading();

    try {
      final result = await ApiUrls.getStepElements(step: step);
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        final responseData = result.data ?? {};
        stepData.assignAll(responseData);
        processSteps.value = stepData['stepInfoList'];
        final stepInfoList = stepData['stepInfoList'];
        if (stepInfoList != null && stepInfoList.isNotEmpty) {
          try {
            final stepInfo = stepInfoList.firstWhere(
              (s) => s['step'] == step,
              orElse: () => null,
            );
            pageTitle.value = stepInfo?['pageTitle'] ?? '';
          } catch (e) {
            pageTitle.value = '';
          }
        } else {
          pageTitle.value = '';
        }
        filledStep.value = step;

        // 拉取到页面数据后，清理上一页并开始新的页面事件
        AppEventTracker.instance.endAllOpenForStep(step);
        // 结束当前页面事件（如果有的话）
        AppEventTracker.instance.endPageEvent(step);
        // 延迟一点开始页面事件，确保页面标题已经设置
        Future.delayed(Duration(milliseconds: 100), () {
          AppEventTracker.instance.startPageEvent(step, pageTitle.value);
        });

        if (provinceCityCache.length == 0) {
          populateProvinceCitySelectList();
        }

        if (bankList.length == 0) {
          fetchBankList();
        }
        if (faceLiveSteps.length == 0) {
          fetchStartupConfig();
        }
      } else {
        YDToast.text(AppStrings.systemErrorTryAgain);
      }
    } catch (e) {
      YDToast.text(AppStrings.systemErrorTryAgain);
    } finally {}
  }

  Future<void> fetchBankList() async {
    try {
      final result = await ApiUrls.getBankList();
      if (result.isSucceed && result.data != null) {
        final responseData = result.data ?? {};
        List<dynamic> _bankList = responseData['bankInfoList'];
        processSteps.forEach((step) {
          for (var entry in step['entries'] ?? []) {
            if (entry['code'] == '50005') {
              final list = _bankList.map((bank) {
                return {
                  'key': bank['id'].toString(),
                  'value': bank['bankName'],
                };
              }).toList();
              bankList.assignAll(list);
              entry['selectList'] = list;
            }
          }
        });
      }
    } catch (e) {
      YDToast.text(AppStrings.errorFetchingBankList);
    }
  }

  Future<void> fetchProvincesCities() async {
    try {
      final result = await ApiUrls.getProvincesCities();
      if (result.isSucceed && result.data != null) {
        final responseData = result.data ?? {};
        provinceCityCache['province'] = responseData['province'];
        provinceCityCache['city'] = responseData['city'];
      } else {
        YDToast.text(AppStrings.errorFetchingProvincesCities);
      }
    } catch (e) {
      YDToast.text(AppStrings.errorFetchingProvincesCities);
    }
  }

  Future<void> populateProvinceCitySelectList() async {
    await fetchProvincesCities();
    final provinces = provinceCityCache['province'] ?? [];
    final cities = provinceCityCache['city'] ?? [];
    final cityParentIds = cities.map((city) => city['parentId'] as int).toSet();
    final validProvinces = provinces.where((province) {
      final provinceId = province['id'] as int;
      return cityParentIds.contains(provinceId);
    }).toList();

    selectedProvince.value = validProvinces.isNotEmpty
        ? validProvinces[0]['id'].toString()
        : "";

    selectedCity.value = "";

    for (var step in processSteps) {
      for (var entry in step['entries'] ?? []) {
        if (entry['selectList'] == null && entry['type'] == 2) {
          entry['selectList'] = validProvinces.map((province) {
            return {
              'key': province['id'].toString(),
              'value': province['name'],
            };
          }).toList();
        }
      }
    }
  }

  void onProvinceChanged(String? newProvince) {
    selectedProvince.value = newProvince ?? "";
    selectedCity.value = "";
    fetchCitiesForProvince(newProvince);
  }

  void fetchCitiesForProvince(String? provinceId) {
    if (provinceId != null && provinceCityCache['city'] != null) {
      selectedCity.value =
          provinceCityCache['city']
              ?.firstWhere(
                (city) => city['parentId'] == int.parse(provinceId),
              )['id']
              .toString() ??
          "";
    }
  }

  // 处理地址选择器的结果
  void onAddressSelected(Map<String, dynamic> addressResult) {
    selectedProvince.value = addressResult['provinceId']?.toString() ?? "";
    selectedCity.value = addressResult['cityId']?.toString() ?? "";
    update();
  }

  // 联系人选择
  Future<void> requestContactPermission(String code) async {
    await selectContact(code);
  }

  void _showContactPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: Text(AppStrings.failedToAccessContacts),
        content: Text(AppStrings.pleaseCheckContactPermission),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text(AppStrings.openSettings),
          ),
        ],
      ),
    );
  }

  //选择通讯录
  Future<void> selectContact(String code) async {
    try {
      String phoneNumber = "";
      String name = "";
      if (Platform.isIOS) {
        if (await FlutterContacts.requestPermission()) {
          final contact = await FlutterContacts.openExternalPick();
          if (contact != null && contact.phones.isNotEmpty) {
            phoneNumber = contact.phones.first.number;
            name = contact.displayName;
          } else {
            _showContactPermissionDeniedDialog();
          }
        } else {
          _showContactPermissionDeniedDialog();
        }
      } else {
        final FlutterNativeContactPicker contactPicker =
            FlutterNativeContactPicker();
        final contact = await contactPicker.selectContact();
        if (contact != null && contact.phoneNumbers!.isNotEmpty) {
          phoneNumber = contact.phoneNumbers!.first;
          name = contact.fullName ?? "";
        }
      }
      if (code == "30052" || code == '30062') {
        if (name.isNotEmpty) {
          stepData[code] = name;
          if (controllers.containsKey(code)) {
            controllers[code]!.text = name;
          }

          if (phoneNumber.isNotEmpty) {
            String iphoneCode = (int.parse(code) + 1).toString();
            stepData[iphoneCode] = phoneNumber;
            if (controllers.containsKey(iphoneCode)) {
              controllers[iphoneCode]!.text = phoneNumber;
            }
          }
        } else {
          YDToast.text(AppStrings.contactRestricted);
        }
      } else {
        if (phoneNumber.isNotEmpty) {
          stepData[code] = phoneNumber;
          if (controllers.containsKey(code)) {
            controllers[code]!.text = phoneNumber;
          }
          try {
            if (name.isNotEmpty) {
              String nameCode = (int.parse(code) - 1).toString();
              stepData[nameCode] = name;
              if (controllers.containsKey(nameCode)) {
                controllers[nameCode]!.text = name;
              }
            }
          } catch (e) {}
        } else {
          YDToast.text(AppStrings.contactRestricted);
        }
      }
    } catch (e) {
      YDToast.text(AppStrings.errorSelectingContact);
    }
  }

  // 表单提交
  Future<void> submitStepData() async {
    isSubmitted.value = true;

    List<Map<String, dynamic>> jsonParam = [];
    String provinceName = "";
    String cityName = "";

    if (selectedProvince.value != "" && provinceCityCache['province'] != null) {
      provinceName =
          provinceCityCache['province']?.firstWhere(
            (province) => province['id'].toString() == selectedProvince.value,
          )['name'] ??
          '';
    }
    if (selectedCity.value != "" && provinceCityCache['city'] != null) {
      cityName =
          provinceCityCache['city']?.firstWhere(
            (city) => city['id'].toString() == selectedCity.value,
          )['name'] ??
          '';
    }

    for (var step in processSteps) {
      if (step['step'] == 2) {
        for (var entry in step['entries'] ?? []) {
          String key = entry['key'] ?? "";
          String code = entry['code'] ?? "";
          dynamic value = stepData[code];
          if (entry['type'] == 8 && entry['submitValue'] != null) {
            jsonParam.add({'key': key, 'value': entry['submitValue']});
          }
          if (code == '30053' && value != null) {
            Map<String, dynamic> contactData = {'contactPhoneNumber': value};
            jsonParam.add({'key': key, 'value': json.encode(contactData)});
          } else if (code == '30063' && value != null) {
            Map<String, dynamic> contactData = {'contactPhoneNumber': value};
            jsonParam.add({'key': key, 'value': json.encode(contactData)});
          } else {
            if (value != entry['defaultText'] && value != null) {
              jsonParam.add({'key': key, 'value': value});
            }
          }
        }
      } else {
        for (var entry in step['entries'] ?? []) {
          String key = entry['key'] ?? "";
          String code = entry['code'] ?? "";
          dynamic value = stepData[code];
          if (entry['type'] == 8 && entry['submitValue'] != null) {
            jsonParam.add({'key': key, 'value': entry['submitValue']});
          }
          if (code == "10004") {
            Map<String, dynamic> provinceCity = {
              'homeCity': cityName,
              'homeProvince': provinceName,
            };
            jsonParam.add({'key': key, 'value': json.encode(provinceCity)});
          } else {
            if (value != entry['defaultText']) {
              jsonParam.add({'key': key, 'value': value});
            }
          }
        }
      }
    }

    int processId = stepData['processId'] ?? 0;
    final postData = {
      'isUpdate': 0,
      'jsonParam': jsonParam,
      'processId': processId,
      'step': currentStep.value,
    };

    try {
      YDToast.loading();
      final result = await ApiUrls.submitStepData(data: postData);

      if (result.isSucceed && result.data != null) {
        final stepResponse = StepDataMapper.fromMap(result.data ?? {});
        // 先上报当前步骤的事件
        await AppEventTracker.instance.flushCurrentStep(
          currentStep.value,
          getCurrentStepTitle(),
        );
        YDToast.cleanAll();
        YDToast.text(result.msg);
        if (stepResponse.isFinished == 1) {
          AppEventTracker.instance.cleanData();
          AppsFlyerHelper().eventAutoOrder();
          Get.offAndToNamed(Routes.home);
        } else {
          currentStep.value = stepResponse.nextStep;
          await fetchStepElements(currentStep.value);
        }
      } else {
        YDToast.cleanAll();
        YDToast.text(
          result.msg != "" ? result.msg : AppStrings.systemErrorTryAgain,
        );
      }
    } catch (e) {
      YDToast.cleanAll();
      YDToast.text(AppStrings.systemErrorTryAgain);
    } finally {}
  }

  // OCR数据处理
  void handleOCRData(Map<String, dynamic> ocrData) {
    void updateField(String code, dynamic value) {
      String valueStr = value?.toString() ?? '';
      stepData[code] = valueStr;
      syncController(code, valueStr);
    }

    void updateGenderField(String code, dynamic gender) {
      String genderStr = gender?.toString() ?? '';
      const Map<String, String> genderMap = {'1': 'Male', '2': 'Female'};
      stepData[code] = genderMap.containsKey(genderStr) ? genderStr : '';
      syncController(code, genderStr);
    }

    updateField('40002', ocrData['idCardNumber']); // Ghana Card → idCardNumber
    updateField('40004', ocrData['name']); // Names → name
    updateField('40003', ocrData['fatherName']); // Surnames → fatherName
    updateField(
      '40010',
      ocrData['documentNumber'],
    ); // Document number → documentNumber
    updateField('40006', ocrData['birthday']); // Date of birth → birthday
    updateGenderField('40001', ocrData['gender']); // Gender → gender
  }

  void syncController(String code, String value) {
    if (controllers.containsKey(code)) {
      if (code == '40001') {
        const Map<String, String> genderDisplayMap = {
          '1': 'Male',
          '2': 'Female',
        };
        controllers[code]!.text = genderDisplayMap[value] ?? '';
      } else {
        controllers[code]!.text = value;
      }
    }
  }

  // 处理继续按钮点击
  Future<void> handleContinue() async {
    NonRepeatableClick.checkClick(
      debounceDuration: const Duration(seconds: 2),
      click: () async {
        final cacheFlag = await UserDataHelper.getCacheData();
        if (Platform.isIOS && cacheFlag == 0 && updataBool.value) {
          bool hasPermissions = await await PermissionUtil.checkAndRequest(
            Permission.location,
          );

          if (!hasPermissions) {
            PermissionUtil.showPermissionDialog(Permission.location);
            return;
          }

          //主动触发一次上报
          UpDataServer().triggerSingleReport();
          updataBool.value = false;
        }

        isSubmitted.value = true;

        // 检查当前步骤是否填写完成
        if (!isCurrentStepComplete()) {
          // 计算缺失字段（不直接使用文案）
          getMissingRequiredFieldTitles();

          // 检查是否有人脸识别字段缺失
          bool hasFaceRecognitionMissing = false;
          for (var step in processSteps) {
            if (step['step'] == currentStep.value) {
              for (var entry in step['entries'] ?? []) {
                if (entry['must'] == 1 && entry['type'] == 7) {
                  String code = entry['code'];
                  dynamic value = stepData[code];
                  if (value == null || value.toString().isEmpty) {
                    hasFaceRecognitionMissing = true;
                    break;
                  }
                }
              }
            }
            if (hasFaceRecognitionMissing) break;
          }

          // 根据缺失字段类型显示不同提示
          if (hasFaceRecognitionMissing) {
            YDToast.text(AppStrings.pleaseCompleteFaceRecognition);
          } else {
            YDToast.text(AppStrings.pleaseCompleteRequiredFields);
          }
          return;
        }

        bool faceRecognitionRequired = false;
        String faceCode = "";
        for (var step in processSteps) {
          if (step['step'] == currentStep.value) {
            for (var entry in step['entries'] ?? []) {
              if (entry['type'] == 7) {
                faceRecognitionRequired = true;
                faceCode = entry['code'] ?? "";
                break;
              }
            }
          }
          if (faceRecognitionRequired) break;
        }

        if (faceRecognitionRequired &&
            (stepData[faceCode] == null || stepData[faceCode]!.isEmpty)) {
          // 这里需要页面处理面部识别
          await startFaceDetection(faceCode);

          return;
        }
        String value = '';
        final val = stepData["40002"]?.toString() ?? '';
        final val2 = stepData["50002"]?.toString() ?? '';
        if (val != '' || val != '') {
          value = '${AppStrings.confirmAccount}\n';
        }
        if (val != '') {
          value = value + "${AppStrings.bvnNumberInput}: ${val}";
        }
        if (val2 != '') {
          if (val != '') {
            value = value + "\n${AppStrings.bankCard}: ${val2}";
          } else {
            value = value + "${AppStrings.bankCard}: ${val2}";
          }
        }
        if (value.isNotEmpty) {
          // if (stepData.containsKey("40002") && val.length != 11) {
          //   YDToast.text('Please enter your 11-digit BVN');
          //   return;
          // }
          // if (stepData.containsKey("50002") && val2.length != 10) {
          //   YDToast.text('Please enter a 10-digit bank card number.');
          //   return;
          // }
          final confirmed = await Get.dialog<bool>(
            ConfirmBankCardDialog(contents: value),
          );
          if (confirmed == true) {
            await submitStepData();
          }
          return;
        }
        // final cfg = confirmConfigs[currentStep.value];
        // if (cfg != null) {
        //   final val = stepData[cfg.fieldCode]?.toString() ?? '';
        //   if (val.isNotEmpty) {
        //     final confirmed = await Get.dialog<bool>(cfg.dialogBuilder(val));
        //     if (confirmed == true) {
        //       await submitStepData();
        //     }
        //     return;
        //   }
        // }

        await submitStepData();
      },
    );
  }

  // 显示退出确认对话框
  Future<bool> showExitDialog() async {
    final shouldExit = await Get.dialog<bool>(const KYCExitDialog());
    return shouldExit == true;
  }

  // 处理退出逻辑
  Future<void> handleExit() async {
    final shouldExit = await showExitDialog();
    if (shouldExit == true) {
      if (Platform.isAndroid) {
        exit(0);
      } else {
        Get.until((route) => route.isFirst);
      }
    }
  }

  // 验证表单
  bool validateForm() {
    isSubmitted.value = true;

    // 检查当前步骤的所有必填字段
    for (var step in processSteps) {
      if (step['step'] == currentStep.value) {
        for (var entry in step['entries'] ?? []) {
          if (entry['must'] == 1) {
            String code = entry['code'];
            dynamic value = stepData[code];
            if (value == null || value.toString().isEmpty) {
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  // 获取当前步骤缺失的必填字段标题
  List<String> getMissingRequiredFieldTitles() {
    List<String> missingTitles = [];

    for (var step in processSteps) {
      if (step['step'] == currentStep.value) {
        for (var entry in step['entries'] ?? []) {
          if (entry['must'] == 1) {
            String code = entry['code'];
            int type = entry['type'];
            if (type != 8) {
              // 特殊处理 code 10004，检测省份和城市选择
              if (code == "10004") {
                if (selectedProvince.value.isEmpty ||
                    selectedCity.value.isEmpty) {
                  String title =
                      entry['showContent'] ?? entry['label'] ?? 'Unknown Field';
                  missingTitles.add(title);
                }
              } else {
                dynamic value = stepData[code];
                if (value == null || value.toString().isEmpty) {
                  String title =
                      entry['showContent'] ?? entry['label'] ?? 'Unknown Field';
                  missingTitles.add(title);
                }
              }
            }
          }
        }
      }
    }

    return missingTitles;
  }

  // 检查当前步骤是否填写完成
  bool isCurrentStepComplete() {
    for (var step in processSteps) {
      if (step['step'] == currentStep.value) {
        for (var entry in step['entries'] ?? []) {
          if (entry['must'] == 1) {
            String code = entry['code'];
            int type = entry['type'];
            if (type != 8) {
              // 特殊处理 code 10004，检测省份和城市选择
              if (code == "10004") {
                if (selectedProvince.value.isEmpty ||
                    selectedCity.value.isEmpty) {
                  return false;
                }
              } else {
                dynamic value = stepData[code];
                if (value == null || value.toString().isEmpty) {
                  return false;
                }
              }
            }
          }
        }
      }
    }
    return true;
  }

  // 重置表单验证状态
  void resetValidation() {
    isSubmitted.value = false;
  }

  // 更新字段值
  void updateFieldValue(String code, dynamic value) {
    stepData[code] = value;
    if (controllers.containsKey(code)) {
      controllers[code]!.text = value?.toString() ?? '';
    }
  }

  // 获取字段值
  dynamic getFieldValue(String code) {
    return stepData[code];
  }

  // 检查字段是否为空
  bool isFieldEmpty(String code) {
    final value = stepData[code];
    return value == null || value.toString().isEmpty;
  }

  // 获取当前步骤的标题
  String getCurrentStepTitle() {
    for (var step in processSteps) {
      if (step['step'] == currentStep.value) {
        return step['pageTitle'] ?? '';
      }
    }
    return '';
  }

  // 获取进度百分比
  double getProgressPercentage() {
    if (totalStep.value == 0) return 0.0;
    return filledStep.value / totalStep.value;
  }

  // 检查是否完成所有步骤
  bool isCompleted() {
    return filledStep.value >= totalStep.value;
  }

  // 获取当前步骤的字段列表
  List<dynamic> getCurrentStepEntries() {
    for (var step in processSteps) {
      if (step['step'] == currentStep.value) {
        return step['entries'] ?? [];
      }
    }
    return [];
  }

  // 获取当前步骤中可选择的字段（下拉选择、日期选择、省市选择等）
  List<dynamic> getCurrentStepSelectableFields() {
    List<dynamic> selectableFields = [];
    for (var step in processSteps) {
      if (step['step'] == currentStep.value) {
        for (var entry in step['entries'] ?? []) {
          int type = entry['type'] ?? 0;
          // 类型2: 下拉选择, 类型4: 性别选择, 类型5: 日期选择, 类型6: 图片上传, 类型7: 人脸识别
          // 以及特殊的省市选择(code: 10004)和银行卡选择(code: 50005)
          if (type == 2 || entry['code'] == '10004') {
            selectableFields.add(entry);
          }
        }
        break;
      }
    }
    return selectableFields;
  }

  // 获取下一个未填写的可选择字段
  dynamic getNextUnfilledSelectableField(String currentCode) {
    List<dynamic> selectableFields = getCurrentStepSelectableFields();
    bool foundCurrent = false;

    for (var field in selectableFields) {
      if (foundCurrent) {
        String code = field['code'] ?? '';
        dynamic value = stepData[code];

        // 检查字段是否已填写
        bool isFilled = false;
        if (code == '10004') {
          // 省市选择需要检查省份和城市都已选择
          isFilled =
              selectedProvince.value.isNotEmpty &&
              selectedCity.value.isNotEmpty;
        } else {
          isFilled = value != null && value.toString().isNotEmpty;
        }

        if (!isFilled) {
          return field;
        }
      }

      if (field['code'] == currentCode) {
        foundCurrent = true;
      }
    }

    return null; // 没有找到下一个未填写的字段
  }

  // 自动调起下一个选择控件
  Future<void> autoTriggerNextSelectableField(
    String currentCode,
    BuildContext context,
  ) async {
    final nextField = getNextUnfilledSelectableField(currentCode);
    if (nextField != null) {
      // 延迟一点时间，让当前选择完成
      await Future.delayed(Duration(milliseconds: 500));

      String code = nextField['code'] ?? '';
      String label =
          (nextField['showContent'] ?? nextField['defaultText'] ?? code)
              .toString();
      int type = nextField['type'] ?? 0;

      // 开始埋点：自动调起下一个选择控件（添加auto_trigger标识）
      AppEventTracker.instance.startInteraction(currentStep.value, code, label);

      // 根据字段类型调起相应的选择控件
      switch (type) {
        case 2: // 下拉选择
          if (code == '10004') {
            // 省市选择
            final result = await AddressPickerWidget.showAddressPicker(
              context,
              label,
              provinceCityCache['province'] as List<dynamic>,
              provinceCityCache['city'] as List<dynamic>,
              selectedProvince.value,
              selectedCity.value,
            );
            if (result != null) {
              onAddressSelected(result);
              // 结束当前埋点
              AppEventTracker.instance.endInteraction(currentStep.value, code);
              // 继续自动调起下一个选择控件
              await autoTriggerNextSelectableField(code, context);
            } else {
              // 用户取消选择，结束埋点
              AppEventTracker.instance.endInteraction(currentStep.value, code);
            }
          } else {
            // 普通下拉选择
            List? selectList = nextField['selectList'];
            if (selectList != null && selectList.isNotEmpty) {
              Set<String> uniqueValues = <String>{};
              List<Map<String, dynamic>> processedOptions = [];
              for (var item in selectList) {
                String value = item['value'].toString();
                String itemKey = item['key'].toString();

                if (uniqueValues.contains(value)) {
                  value = itemKey;
                } else {
                  uniqueValues.add(value);
                }
                processedOptions.add({'key': itemKey, 'value': value});
              }

              await IOSPickerWidget.showIOSPicker(
                context,
                label,
                processedOptions,
                (selectedValue) {
                  stepData[code] = selectedValue;
                  update();
                  // 结束当前埋点
                  AppEventTracker.instance.endInteraction(
                    currentStep.value,
                    code,
                  );
                  // 继续自动调起下一个选择控件
                  autoTriggerNextSelectableField(code, context);
                },
                stepData[code]?.toString() ?? '',
              );
            }
          }
          break;
      }
    }
  }

  //点击图片
  toImageClick(String type, String code, int step) async {
    await ImageSourceBottomSheet.show(
      type: type,
      code: code,
      step: step,
      onGallerySelected: () => checkGalleryPermissionAndPick(type, code),
      onCameraSelected: () => toCameraClick(type, code),
    );
  }

  //打开相机
  toCameraClick(String type, String code) async {
    final hasCamera = await PermissionUtil.checkAndRequest(Permission.camera);
    if (hasCamera) {
      final result = await Get.toNamed(Routes.cameraScreen);

      if (result != null) {
        final bytes = result as Uint8List;
        uploadImageOcrFromBytes(bytes, type, code);
      }
    } else {
      PermissionUtil.showPermissionDialog(Permission.camera);
    }
  }

  Future<void> checkGalleryPermissionAndPick(String type, String code) async {
    bool hasGallery = true;
    if (Platform.isIOS) {
      hasGallery = await PermissionUtil.checkAndRequest(Permission.photos);
    }
    if (hasGallery) {
      await pickImage(type, code);
    } else {
      PermissionUtil.showPermissionDialog(Permission.photos);
    }
  }

  Future<void> pickImage(String type, String code) async {
    try {
      Uint8List? bytes;
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (pickedFile != null) {
        bytes = await pickedFile.readAsBytes();
      }
      if (bytes != null) {
        uploadImageOcrFromBytes(bytes, type, code);
      } else {
        LogUtil.d('Image', AppStrings.noPhotoSelected);
      }
    } catch (e) {}
  }

  //压缩图片
  Future<Uint8List> compressImage(Uint8List bytes) async {
    Uint8List compressedImage = await ImageUtil.compressImageToSize(
      bytes,
      maxSizeInBytes: 250 * 1024,
    );
    return compressedImage;
    // final img.Image? image = img.decodeImage(bytes);
    // if (image == null) return bytes;
    // return Uint8List.fromList(img.encodeJpg(image, quality: 75));
  }

  //ocr上传证件
  Future<void> uploadImageOcrFromBytes(
    Uint8List bytes,
    String type,
    String code,
  ) async {
    YDToast.loading();
    try {
      // headers 已在下方直接传入使用
      final String typeParam = type;
      final Uint8List compressed = await compressImage(bytes);

      // 保存图片到沙盒
      final String localPath = await ImageUtil.saveImageToSandbox(
        compressed,
        '${type}_card_image',
      );

      final formData = dio.FormData.fromMap({
        'multipartFile': dio.MultipartFile.fromBytes(
          compressed,
          filename: '${type}_photo.png',
        ),
      });
      final result = await ApiUrls.postOcrIdentification(
        formData: formData,
        urlParameters: "?type=$typeParam",
      );
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        LogUtil.d(
          AppStrings.success,
          result.msg != "" ? result.msg : AppStrings.success,
        );
        final data = result.data ?? {};
        final url = data['url'] ?? "";
        final backUrl = data['backUrl'] ?? "";
        if (code == "40007") {
          final mapData = Map<String, dynamic>.from(data);
          dataMap.assignAll(mapData);
          handleOCRData(mapData);
          cardImage.value = localPath; // 使用本地沙盒路径
        }
        if (code == "40008") {
          cardBackImage.value = localPath;
          stepData[code] = backUrl;
        }
        stepData[code] = url != "" ? url : backUrl;

        isSubmitted.value = false;
      } else {
        LogUtil.d(
          AppStrings.error,
          result.msg != "" ? result.msg : AppStrings.unknownErrorMsg,
        );
      }
    } catch (e) {
      LogUtil.e("${e.toString()}");
    }
  }

  //人脸图片上传
  Future<void> uploadImageFaceFromBytes(Uint8List bytes, String code) async {
    YDToast.loading();
    try {
      final headers = await RequestHeaders.commonFileUploadHeaders();
      final Uint8List compressed = await compressImage(bytes);

      // 保存图片到沙盒
      final String localPath = await ImageUtil.saveImageToSandbox(
        compressed,
        'face_image',
      );

      final formData = dio.FormData.fromMap({
        'multipartFile': dio.MultipartFile.fromBytes(
          compressed,
          filename: 'photo.png',
        ),
      });
      final result = await ApiUrls.postUploadImage(
        formData: formData,
        headers: headers,
      );
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        YDToast.text(AppStrings.success);
        LogUtil.d(
          AppStrings.success,
          result.msg != "" ? result.msg : AppStrings.success,
        );
        final data = result.data ?? {};
        final url = data['url'] ?? "";
        stepData[code] = url;
        faceImage.value = localPath; // 使用本地沙盒路径
        isSubmitted.value = false;
      } else {
        YDToast.text(result.msg);
      }
    } catch (e) {
      LogUtil.e("${e.toString()}");
    }
  }

  //去人脸
  startFaceDetection(String code) async {
    var hasCamera = await PermissionUtil.checkAndRequest(Permission.camera);
    if (hasCamera) {
      if (faceLiveSteps.length == 0) {
        await fetchStartupConfig(isLoading: true);
      }

      dynamic result;
      if (Platform.isIOS) {
        result = await platform.invokeMethod('startFaceDetection', {
          'actions': faceLiveSteps,
        });
      } else {
        result = await Get.toNamed(
          Routes.andriodfaceDetectionScreen,
          arguments: {'faceLiveSteps': faceLiveSteps},
        );
      }

      // 处理iOS端新的返回格式
      List<String> imagePaths = [];
      int useARKit = 0;

      if (Platform.isIOS && result is Map) {
        final Map<String, dynamic> resultMap = Map<String, dynamic>.from(
          result,
        );

        imagePaths = List<String>.from(resultMap['images'] ?? []);
        if (imagePaths.length > 0) {
          useARKit = result['useARKit'] ?? 2;
        }
      } else if (result is List<dynamic>) {
        // Android端或旧格式
        imagePaths = List<String>.from(result);
        useARKit = 3; // 默认值，Android端使用3
      }
      // 添加埋点：记录人脸检测结果
      AppEventTracker.instance.selectInteraction(
        currentStep.value,
        code,
        useARKit, // 使用useARKit值作为clickSelect
      );

      if (imagePaths.isEmpty) {
        YDToast.text(AppStrings.faceDetectionFailed);
        return;
      } else {
        YDToast.text(AppStrings.faceDetectionCompleted);
      }

      final fileBytes = await File(imagePaths.first).readAsBytes();
      uploadImageFaceFromBytes(fileBytes, code);
    } else {
      PermissionUtil.showPermissionDialog(Permission.camera);
    }
  }
}

class _ConfirmConfig {
  final String fieldCode;
  final Widget Function(String) dialogBuilder;
  _ConfirmConfig({required this.fieldCode, required this.dialogBuilder});
}
