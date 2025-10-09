import 'dart:async';

import 'package:flutter/services.dart';

class AndroidSecurityDetector {
  static const MethodChannel _channel =
      MethodChannel('android_security_detector');

  /// 获取安全检测信息
  /// 返回包含以下字段的Map:
  /// - isRootJailbreak: 是否Root (0/1)
  /// - isUsingProxyPort: 是否使用HTTP代理 (0/1)
  /// - isVpnConnected: 是否连接VPN (0/1)
  /// - isUsbDebug: 是否开启USB调试 (0/1)
  /// - isMockLocation: 是否开启模拟位置 (0/1)
  static Future<Map<String, int>> getSecurityInfo() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getSecurityInfo');
      return Map<String, int>.from(result);
    } on PlatformException catch (e) {
      // 如果出现异常，返回默认值（全部为0，表示安全）
      return {
        'isRootJailbreak': 0,
        'isUsingProxyPort': 0,
        'isVpnConnected': 0,
        'isUsbDebug': 0,
        'isMockLocation': 0,
      };
    }
  }
}
