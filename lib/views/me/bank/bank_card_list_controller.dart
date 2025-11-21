import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../basa/country_config_helper.dart';
import '../../../models/bank_card.dart';
import '../../../common/toast.dart';
import '../../../http/api_urls.dart';
import '../../../routes/routes.dart';
import '../../../common/logger/app_logger.dart';
import 'edit/bank_card_form_page.dart';

class BankCardListController extends GetxController {
  final bankCardInfoList = <BankCardInfo>[].obs;
  final Rx<BankCardInfo?> selectedCard = Rx<BankCardInfo?>(null);

  //是否可编辑
  final  edit = true.obs;
  @override
  void onInit() async {
    super.onInit();
    edit.value = await CountryConfigHelper.getAppBlackCardAsync();
    refreshBankCardList();
  }

  Future<List<BankCardInfo>> queryUserBankCardList({
    bool loading = true,
  }) async {
    try {
      if (loading) {
        YDToast.loading();
      }

      final result = await ApiUrls.getBankCardList();
      if (loading) {
        YDToast.cleanAll();
      }
      if (result.isSucceed && result.rawData != null) {
        final List<Map<String, dynamic>> rawList =
            List<Map<String, dynamic>>.from(
              result.rawData["userBankCardInfoRespList"],
            );
        final mapped = rawList
            .map((e) => BankCardInfoMapper.fromMap(e))
            .toList();
        return mapped;
      } else {
        YDToast.text(
          result.msg.isNotEmpty ? result.msg : 'errorFetchingBankCards'.tr,
        );
      }
    } catch (e) {
      LogUtil.d('catch-Error:$e');
    }
    return [];
  }

  Future<void> refreshBankCardList({bool loading = true}) async {
    try {
      bankCardInfoList.value = await queryUserBankCardList(loading: loading);
    } finally {}
  }

  Future<bool> setDefaultBankCard(BuildContext context, int cardId) async {
    try {
      YDToast.loading();
      final result = await ApiUrls.setDefaultBankCardRequest(cardId: cardId);
      YDToast.cleanAll();
      if (result.isSucceed) {
        return true;
      } else {
        YDToast.text(
          result.msg.isNotEmpty ? result.msg : 'errorSettingDefaultCard'.tr,
        );
      }
    } catch (e) {
      LogUtil.d('catch-Error:$e');
    }
    return false;
  }

  Future<void> setDefaultCard() async {
    if (selectedCard.value == null) {
      YDToast.text('pleaseSelectCard'.tr);
      return;
    }
    final success = await setDefaultBankCard(
      Get.context!,
      selectedCard.value!.id,
    );
    if (success) {
      YDToast.text('defaultCardSetSuccessfully'.tr);

      refreshBankCardList(loading: false);
    }
  }

  // Future<bool> deleteBankCardInfo(BuildContext context, int cardId) async {
  //   try {
  //     YDToast.loading();
  //     final result = await ApiUrls.deleteBankCardInfo(cardId: cardId);
  //     YDToast.cleanAll();
  //     if (result.isSucceed) {
  //       return true;
  //     } else {
  //       YDToast.text(
  //         result.msg.isNotEmpty ? result.msg : 'errorDeletingBankCard'.tr,
  //       );
  //     }
  //   } catch (e) {
  //     LogUtil.d('catch-Error:$e');
  //   }
  //   return false;
  // }

  // Future<void> deleteBankCard(BuildContext context, BankCardInfo card) async {
  //   bool confirm =
  //       await Get.dialog<bool>(
  //         AlertDialog(
  //           title: const Text('deleteCard'.tr),
  //           content: const Text('areYouSureDeleteCard'.tr),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Get.back(result: false),
  //               child: const Text('cancel'.tr),
  //             ),
  //             TextButton(
  //               onPressed: () => Get.back(result: true),
  //               child: const Text('ok'.tr),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false;
  //   if (!confirm) return;
  //   final success = await deleteBankCardInfo(context, card.id);
  //   if (success) {
  //     YDToast.text('cardSuccessfullyRemoved'.tr);
  //     refreshBankCardList();
  //   }
  // }

  navigateToAddCard(BankCardListController controller) {
    Get.toNamed(Routes.bankCardForm)?.then((value) {
      if (value == true) {
        controller.refreshBankCardList();
      }
    });
  }

  navigateToEditCard(BankCardInfo card, BankCardListController controller) {
    Get.toNamed(
      Routes.bankCardForm,
      arguments: {'mode': BankCardMode.update, 'bankCardInfo': card},
    )?.then((value) {
      if (value == true) {
        controller.refreshBankCardList();
      }
    });
  }
}
