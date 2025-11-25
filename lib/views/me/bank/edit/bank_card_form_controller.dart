import 'package:get/get.dart';
import 'package:flutter3APP/views/me/bank/edit/bank_card_form_page.dart';
import '../../../../common/toast.dart';
import '../../../../http/api_urls.dart';
import '../../../../models/bank_card.dart';
import 'package:flutter/material.dart';

class BankCardFormController extends GetxController {
  final Rx<TextEditingController> bvnTextController =
      TextEditingController().obs;
  final Rx<TextEditingController> bankCardNoController =
      TextEditingController().obs;
  final RxString selectedBankId = ''.obs;
  final RxString selectedBankType = ''.obs;
  final RxList<Map<String, String>> bankTypes = <Map<String, String>>[].obs;
  final RxList<dynamic> bankList = <dynamic>[].obs;

  // 缓存处理后的银行选项，避免重复计算
  List<Map<String, dynamic>>? _cachedBankOptions;

  BankCardMode mode = BankCardMode.add;

  final Rx<BankCardInfo?> bankCardInfo = Rx<BankCardInfo?>(null);

  //
  // 用于UI更新的方法
  void updateBankType(String value) {
    selectedBankType.value = value;
  }

  void updateBankId(String value) {
    selectedBankId.value = value;
  }

  // 获取处理后的银行选项，使用缓存提高性能
  List<Map<String, dynamic>> getBankOptions() {
    if (_cachedBankOptions == null) {
      _cachedBankOptions = bankList
          .map(
            (bank) => {
              'key': bank['id'].toString(),
              'value': bank['bankName'].toString(),
            },
          )
          .toList();
    }
    return _cachedBankOptions!;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    mode = args['bankCardInfo'] == null
        ? BankCardMode.add
        : BankCardMode.update;
    bankCardInfo.value = args['bankCardInfo'] ?? null;
    if (mode == BankCardMode.update && bankCardInfo.value != null) {
      bankCardNoController.value.text = bankCardInfo.value?.bankCardNo ?? '';
      selectedBankId.value = bankCardInfo.value?.bankId.toString() ?? '';
       selectedBankType.value = bankCardInfo.value?.bankType?.toString() ?? '';
    }
    fetchDropdownData();
  }

  @override
  void onClose() {
    bankCardNoController.value.dispose();
    super.onClose();
  }

  Future<void> fetchDropdownData() async {
    try {
      YDToast.loading();
      final result = await ApiUrls.getStepElements(step: 3);
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        final data = result.data;
        if (data != null &&
            data['stepInfoList'] != null &&
            data['stepInfoList'] is List) {
          List<dynamic> stepInfoList = data['stepInfoList'];
          if (stepInfoList.isNotEmpty) {
            List<dynamic> entries = stepInfoList[0]['entries'] ?? [];
            final bankTypeEntry = entries.firstWhere(
              (entry) => entry['code'] == '50001',
              orElse: () => null,
            );
            if (bankTypeEntry != null && bankTypeEntry['selectList'] != null) {
              bankTypes.value = List<Map<String, String>>.from(
                bankTypeEntry['selectList'].map(
                  (item) => {
                    'key': item['key'].toString(),
                    'value': item['value'].toString(),
                  },
                ),
              );
            }
            final bankNameEntry = entries.firstWhere(
              (entry) => entry['code'] == '50005',
              orElse: () => null,
            );
            if (bankNameEntry != null && bankNameEntry['selectList'] != null) {
              bankList.value = bankNameEntry['selectList'];
            } else {
              await fetchBankList();
            }
          }
        }
      } else {
        YDToast.text(result.msg);
      }
    } catch (e) {
      print('Error fetching dropdown data: $e');
    }
  }

  Future<void> fetchBankList() async {
    try {
      YDToast.loading();
      final result = await ApiUrls.getBankList();
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        final responseData = result.data ?? {};
        List<dynamic> _bankList = responseData['bankInfoList'];
        bankList.value = _bankList;
        // 清除缓存，强制重新计算
        _cachedBankOptions = null;
      } else {
        YDToast.text(result.msg);
      }
    } catch (e) {
      print('Error fetching bank list: $e');
    }
  }

  Future<bool> addBankCardInfo(
    BuildContext context, {
    required String bankCardNo,
    required String bankId,
    required String bankType,
  }) async {
    try {
      final result = await ApiUrls.addBankCardInfo(
        bankCardNo: bankCardNo,
        bankId: bankId,
        bankType: bankType,
      );
      YDToast.cleanAll();
      if (result.isSucceed) {
        return true;
      } else {
        YDToast.text(
          result.msg.isNotEmpty ? result.msg : 'errorAddingBankCard'.tr,
        );
      }
    } catch (e) {}
    return false;
  }

  Future<bool> updateBankCardInfo(
    BuildContext context, {
    required String bankCardNo,
    required String bankId,
    required String bankType,
    required int id,
  }) async {
    try {
      final result = await ApiUrls.updateBankCardInfo(
        bankCardNo: bankCardNo,
        bankId: bankId,
        bankType: bankType,
        id: id,
      );
      YDToast.cleanAll();
      if (result.isSucceed) {
        return true;
      } else {
        YDToast.text(
          result.msg.isNotEmpty ? result.msg : 'errorUpdatingBankCard'.tr,
        );
      }
    } catch (e) {}
    return false;
  }

  Future<void> submitBankCard(
    BuildContext context, {
    bool isUpdate = false,
    int? cardId,
  }) async {
    try {
      final cardNo = bankCardNoController.value.text.trim();
      final bankId = selectedBankId.value;
      final bankType = selectedBankType.value;

      // 数据验证
      // if (cardNo.isEmpty || bankId.isEmpty || bankType.isEmpty) {
      if (cardNo.isEmpty || bankId.isEmpty) {
        YDToast.text('pleaseFillAllFields'.tr);
        return;
      }
      // if (cardNo.length<10) {
      //   YDToast.text('cardNumberMustBe10Digits'.tr);
      //   return;
      // }

      YDToast.loading();
      bool success = false;
      if (isUpdate && cardId != null) {
        success = await updateBankCardInfo(
          context,
          bankCardNo: cardNo,
          bankId: bankId,
          bankType: bankType,
          id: cardId,
        );
      } else {
        success = await addBankCardInfo(
          context,
          bankCardNo: cardNo,
          bankId: bankId,
          bankType: bankType,
        );
      }

      if (success) {
        YDToast.text('bankCardSubmittedSuccessfully'.tr);
        await Future.delayed(Duration(milliseconds: 500)); // 给用户一点时间看到成功消息
        Get.back(result: true);
      }
    } catch (e) {}
  }
}
