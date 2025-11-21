import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 语言控制器
/// 管理应用的语言设置和切换
class LanguageController extends GetxController {
  static const String _languageKey = 'app_language';
  
  /// 当前语言
  final Rx<Locale> currentLocale = const Locale('en').obs;

  @override
  void onInit() {
    super.onInit();
    initLanguage();
  }

  /// 初始化语言设置（公共方法）
  Future<void> initLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);
      
      if (savedLanguageCode != null) {
        // 如果有保存的语言设置，使用保存的语言
        currentLocale.value = Locale(savedLanguageCode);
      } else {
        // 否则使用系统语言
        final systemLocale = Get.deviceLocale ?? const Locale('en');
        currentLocale.value = _getSupportedLocale(systemLocale);
      }
      
      // 设置 GetX 的语言
      Get.updateLocale(currentLocale.value);
    } catch (e) {
      // 如果出错，默认使用英文
      currentLocale.value = const Locale('en');
      Get.updateLocale(const Locale('en'));
    }
  }

  /// 获取支持的语言
  /// 如果是西班牙语返回 es，否则返回 en（英文）
  Locale _getSupportedLocale(Locale systemLocale) {
    if (systemLocale.languageCode == 'es') {
      return const Locale('es');
    }
    // 其他所有语言默认使用英文
    return const Locale('en');
  }

  /// 切换语言
  Future<void> changeLanguage(Locale locale) async {
    try {
      currentLocale.value = locale;
      Get.updateLocale(locale);
      
      // 保存语言设置
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      // 处理错误
      print('Error changing language: $e');
    }
  }

  /// 切换到西班牙语
  Future<void> switchToSpanish() async {
    await changeLanguage(const Locale('es'));
  }

  /// 切换到英文
  Future<void> switchToEnglish() async {
    await changeLanguage(const Locale('en'));
  }
}

