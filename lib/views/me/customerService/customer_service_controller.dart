import 'package:get/get.dart';
import '../../../http/api_urls.dart';
import '../../../common/toast.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerServiceController extends GetxController {
  final RxMap<String, dynamic> customerServiceData = <String, dynamic>{}.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomerServiceInfo();
  }

  /// 获取客服信息
  Future<void> fetchCustomerServiceInfo() async {
    try {
      YDToast.loading();
      hasError.value = false;

      final result = await ApiUrls.getCustomerServiceInfo();
      YDToast.cleanAll();
      if (result.isSucceed && result.data != null) {
        customerServiceData.value = result.data as Map<String, dynamic>;
      } else {
        hasError.value = true;
      }
    } catch (e) {
      hasError.value = true;
    }
  }

  /// 复制到剪贴板
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    YDToast.text('textCopiedToClipboard'.tr);
  }

  /// 联系客服电话
  Future<void> launchWhatsApp(String? phone) async {
    // final Uri appUri = Uri.parse(whatsAppUrl);
    // final String? phone = _extractPhoneFromUrl(whatsAppUrl);
    //
    // if (await canLaunchUrl(appUri)) {
    //   final success = await launchUrl(
    //     appUri,
    //     mode: LaunchMode.externalApplication,
    //   );
    //   if (success) return;
    // }

    if (phone != null) {
      final Uri telUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        _showErrorToast();
      }
    } else {
      _showErrorToast();
    }
  }

  /// 从URL中提取电话号码
  String? _extractPhoneFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    return uri.queryParameters['phone'];
  }

  /// 显示错误提示
  void _showErrorToast() {
    Get.snackbar(
      'error'.tr,
      'unableToContactWhatsApp'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 启动邮件应用
  Future<void> launchEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'cannotOpenMailApplication'.tr;
    }
  }

  /// 获取客服信息
  Map<String, dynamic>? get appCustomerServiceInfo =>
      customerServiceData['appCustomerServiceInfo'];

  /// 获取客服响应信息
  List<dynamic>? get appCustomerServiceInfoResps =>
      customerServiceData['appCustomerServiceInfoResps'];

  /// 获取WhatsApp账户列表
  List<dynamic>? get whatsAppAccounts {
    final accountList = appCustomerServiceInfo?['accountList'];
    if (accountList != null) {
      return accountList.where((account) => account['type'] == 2).toList();
    }
    return null;
  }

  /// 获取邮件账户列表
  List<dynamic>? get emailAccounts {
    final accountList = appCustomerServiceInfo?['accountList'];
    if (accountList != null) {
      return accountList.where((account) => account['type'] == 3).toList();
    }
    return null;
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await fetchCustomerServiceInfo();
  }
}
