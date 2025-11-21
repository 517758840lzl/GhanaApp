import '../provider/userDataHelper.dart';
import '../controllers/language_controller.dart';
import 'package:get/get.dart';
import 'main_constant.dart';

/// 国家配置工具类
/// 统一管理根据国家代码获取对应配置的方法
class CountryConfigHelper {
  CountryConfigHelper._();

  /// 根据国家代码获取对应的索引
  /// [countryCode] 国家代码，如果为 null 或不在 COUNTRY_CODES 中，返回 0
  static int getCountryIndex(String? countryCode) {
    if (countryCode != null && Constant.COUNTRY_CODES.contains(countryCode)) {
      final index = Constant.COUNTRY_CODES.indexOf(countryCode);
      if (index >= 0) {
        return index;
      }
    }
    // 默认返回第一个索引
    return 0;
  }

  /// 根据国家代码获取对应的 BASE_URL
  /// [countryCode] 国家代码，如果为 null 或不在 COUNTRY_CODES 中，返回第一个值
  static String getBaseUrl(String? countryCode) {
    final index = getCountryIndex(countryCode);
    if (index < Constant.BASE_URL.length) {
      return Constant.BASE_URL[index];
    }
    return Constant.BASE_URL.first;
  }

  /// 异步获取 BASE_URL（自动从 UserDataHelper 获取国家代码）
  static Future<String> getBaseUrlAsync() async {
    final countryCode = await UserDataHelper.getCountry();
    return getBaseUrl(countryCode);
  }

  /// 根据国家代码获取对应的 APP_BLACK_CARD 值
  /// [countryCode] 国家代码，如果为 null 或不在 COUNTRY_CODES 中，返回第一个值
  static bool getAppBlackCard(String? countryCode) {
    final index = getCountryIndex(countryCode);
    if (index < Constant.APP_BLACK_CARD.length) {
      return Constant.APP_BLACK_CARD[index];
    }
    return Constant.APP_BLACK_CARD.first;
  }

  /// 异步获取 APP_BLACK_CARD（自动从 UserDataHelper 获取国家代码）
  static Future<bool> getAppBlackCardAsync() async {
    final countryCode = await UserDataHelper.getCountry();
    return getAppBlackCard(countryCode);
  }

  /// 根据国家代码获取对应的国家图标路径
  /// [countryCode] 国家代码，如果为 null 或不在 COUNTRY_CODES 中，返回第一个值
  static String getCountryCodeImage(String? countryCode) {
    final index = getCountryIndex(countryCode);
    if (index < Constant.COUNTRY_CODES_IMAGE.length) {
      return Constant.COUNTRY_CODES_IMAGE[index];
    }
    return Constant.COUNTRY_CODES_IMAGE.first;
  }

  /// 异步获取国家图标路径（自动从 UserDataHelper 获取国家代码）
  static Future<String> getCountryCodeImageAsync() async {
    final countryCode = await UserDataHelper.getCountry();
    return getCountryCodeImage(countryCode);
  }

  /// 根据语言获取对应的隐私政策 URL
  /// 英文（默认）返回第一个URL，西班牙语返回第二个URL
  /// 如果没有选择语言，会根据系统语言来判断
  /// [countryCode] 此参数已废弃，保留以保持向后兼容性
  static String getPrivacyPolicyUrl(String? countryCode) {
    String? currentLang;

    try {
      // 优先从 LanguageController 获取当前语言
      final languageController = Get.find<LanguageController>();
      currentLang = languageController.currentLocale.value.languageCode;
    } catch (e) {
      // 如果获取语言控制器失败，尝试使用系统语言
      try {
        final systemLocale = Get.deviceLocale;
        if (systemLocale != null) {
          currentLang = systemLocale.languageCode;
        }
      } catch (e2) {
        print('Error getting language: $e2');
      }
    }

    // 根据语言代码确定索引：西班牙语返回第二个URL（index 1），其他语言返回第一个URL（index 0）
    final index = currentLang == 'es' ? 1 : 0;
    if (index < Constant.URL_PRIVACY_POLICY.length) {
      return Constant.URL_PRIVACY_POLICY[index];
    }

    // 默认返回第一个URL
    return Constant.URL_PRIVACY_POLICY.first;
  }

  /// 异步获取隐私政策 URL（根据当前语言）
  static Future<String> getPrivacyPolicyUrlAsync() async {
    return getPrivacyPolicyUrl(null);
  }

  /// 根据国家代码获取对应的服务条款 URL
  /// [countryCode] 国家代码，如果为 null 或不在 COUNTRY_CODES 中，返回第一个值
  static String getTermServiceUrl(String? countryCode) {
    final index = getCountryIndex(countryCode);
    if (index < Constant.URL_TERM_SERVICE.length) {
      return Constant.URL_TERM_SERVICE[index];
    }
    return Constant.URL_TERM_SERVICE.first;
  }

  /// 异步获取服务条款 URL（自动从 UserDataHelper 获取国家代码）
  static Future<String> getTermServiceUrlAsync() async {
    final countryCode = await UserDataHelper.getCountry();
    return getTermServiceUrl(countryCode);
  }

  /// 根据国家代码获取贷款成功页面的 banner 图片路径
  /// [countryCode] 国家代码，如果为 null 或不是 56，返回默认图片
  static String getLoanSuccessBannerImage(String? countryCode) {
    if (countryCode == '56') {
      return 'assets/images/banner_loan_success_my.png';
    }
    return 'assets/images/banner_loan_success.webp';
  }

  /// 异步获取贷款成功页面的 banner 图片路径（自动从 UserDataHelper 获取国家代码）
  static Future<String> getLoanSuccessBannerImageAsync() async {
    final countryCode = await UserDataHelper.getCountry();
    return getLoanSuccessBannerImage(countryCode);
  }

  /// 根据国家代码和性别获取用户头像图片路径
  /// [countryCode] 国家代码
  /// [sex] 性别，1=男性，2=女性
  static String getAvatarImage(String? countryCode, int sex) {
    final isCountry56 = countryCode == '56';

    if (sex == 2) {
      // 女性头像
      return isCountry56
          ? 'assets/images/white_female.png'
          : 'assets/images/avatar_female.png';
    }
    // 男性头像
    return isCountry56
        ? 'assets/images/white_male.png'
        : 'assets/images/avatar_male.webp';
  }

  /// 异步获取用户头像图片路径（自动从 UserDataHelper 获取国家代码）
  /// [sex] 性别，1=男性，2=女性
  static Future<String> getAvatarImageAsync(int sex) async {
    final countryCode = await UserDataHelper.getCountry();
    return getAvatarImage(countryCode, sex);
  }
}
