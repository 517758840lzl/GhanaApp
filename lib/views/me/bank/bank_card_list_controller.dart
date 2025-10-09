import 'package:get/get.dart';
import '../../../basa/main_constant.dart';
import '../../../models/bank_card.dart';
import '../../../common/toast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../http/api_urls.dart';
import '../../../l10n/app_strings.dart';
import '../../../routes/routes.dart';
import '../../../common/logger/app_logger.dart';
import 'bank_card_list_page.dart';
import 'edit/bank_card_form_page.dart';

class BankCardListController extends GetxController {
  final bankCardInfoList = <BankCardInfo>[].obs;
  final Rx<BankCardInfo?> selectedCard = Rx<BankCardInfo?>(null);

  //是否可编辑
  final edit = Constant.APP_BLACK_CARD;
  @override
  void onInit() {
    super.onInit();
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
        final mapped =
            rawList.map((e) => BankCardInfoMapper.fromMap(e)).toList() ?? [];
        return mapped;
      } else {
        YDToast.text(
          result.msg.isNotEmpty
              ? result.msg
              : AppStrings.errorFetchingBankCards,
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
          result.msg.isNotEmpty
              ? result.msg
              : AppStrings.errorSettingDefaultCard,
        );
      }
    } catch (e) {
      LogUtil.d('catch-Error:$e');
    }
    return false;
  }

  Future<void> setDefaultCard() async {
    if (selectedCard.value == null) {
      YDToast.text(AppStrings.pleaseSelectCard);
      return;
    }
    final success = await setDefaultBankCard(
      Get.context!,
      selectedCard.value!.id,
    );
    if (success) {
      YDToast.text(AppStrings.defaultCardSetSuccessfully);

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
  //         result.msg.isNotEmpty ? result.msg : AppStrings.errorDeletingBankCard,
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
  //           title: const Text(AppStrings.deleteCard),
  //           content: const Text(AppStrings.areYouSureDeleteCard),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Get.back(result: false),
  //               child: const Text(AppStrings.cancel),
  //             ),
  //             TextButton(
  //               onPressed: () => Get.back(result: true),
  //               child: const Text(AppStrings.ok),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false;
  //   if (!confirm) return;
  //   final success = await deleteBankCardInfo(context, card.id);
  //   if (success) {
  //     YDToast.text(AppStrings.cardSuccessfullyRemoved);
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
