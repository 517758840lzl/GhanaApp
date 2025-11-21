import 'package:flutter3APP/http/http.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import '../../../http/api_urls.dart';
import '../../../provider/userDataHelper.dart';
import '../../../common/toast.dart';
import '../../../routes/routes.dart';
import '../../../controllers/language_controller.dart';
import '../dialogs/delete_account_dialog.dart';
import '../dialogs/clear_data_dialog.dart';

class PersonInformationController extends GetxController {
  final version = "".obs;

  final build_number = "".obs;

  @override
  void onInit() {
    super.onInit();
    getVersion();
  }

  getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    build_number.value = packageInfo.buildNumber;
  }

  Future<void> deleteAccount() async {
    YDToast.loading();
    try {
      final result = await ApiUrls.deleteAccount();
      YDToast.cleanAll();
      if (result.isSucceed) {
        Get.offAllNamed(Routes.login);
        YDToast.text(
          result.msg != "" ? result.msg : 'accountSuccessfullyDeleted'.tr,
        );
        HttpUtil.cancelRequest();
        await UserDataHelper.clearUserToken();
      } else {
        YDToast.text(result.msg != "" ? result.msg : 'errorDeletingAccount'.tr);
      }
    } catch (e) {
      // ignore
    }
  }

  void showDeleteAccountDialog(BuildContext context) {
    DeleteAccountDialog.show(onConfirm: deleteAccount);
  }

  void clearData() {
    ClearDataDialog.show(onConfirm: _performClearCache);
  }

  void _performClearCache() {
    YDToast.loading();
    // 模拟清除缓存的过程
    Future.delayed(const Duration(seconds: 1), () {
      YDToast.cleanAll();
      YDToast.text('dataDeletedSuccessfully'.tr);
    });
  }

  /// 切换语言到英文
  Future<void> switchToEnglish() async {
    final languageController = Get.find<LanguageController>();
    await languageController.switchToEnglish();
  }

  /// 切换语言到西班牙语
  Future<void> switchToSpanish() async {
    final languageController = Get.find<LanguageController>();
    await languageController.switchToSpanish();
  }
}
