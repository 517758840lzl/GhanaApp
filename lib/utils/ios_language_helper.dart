import 'dart:io';
import 'package:flutter/services.dart';

/// iOS语言同步工具类
/// 用于在Flutter切换语言时同步更新iOS原生语言设置
class IOSLanguageHelper {
  static const MethodChannel _channel = MethodChannel('com.example.app/language');

  /// 更新iOS原生语言设置
  /// [languageCode] 语言代码，如 'en' 或 'es'
  static Future<void> updateIOSLanguage(String languageCode) async {
    if (!Platform.isIOS) {
      return; // 只在iOS平台执行
    }

    try {
      await _channel.invokeMethod('updateLanguage', {'languageCode': languageCode});
    } catch (e) {
      print('Error updating iOS language: $e');
    }
  }
}

