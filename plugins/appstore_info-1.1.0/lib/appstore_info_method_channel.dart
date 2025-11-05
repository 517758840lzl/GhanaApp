import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'appstore_info_platform_interface.dart';

/// An implementation of [AppstoreInfoPlatform] that uses method channels.
class MethodChannelAppstoreInfo extends AppstoreInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('appstore_info');

  Function(String)? _textRecognizedCallback;

  MethodChannelAppstoreInfo() {
    // 设置方法调用处理器
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onTextRecognized':
        final String recognizedText = call.arguments['recognizedText'] ?? '';
        _textRecognizedCallback?.call(recognizedText);
        break;
      default:
        throw MissingPluginException('方法 ${call.method} 未实现');
    }
  }

  @override
  Future<bool?> presentAppStore({required String appID}) async {
    try {
      final isPresented =
          await methodChannel.invokeMethod<bool>('presentAppStore', {
        'appID': appID,
      });
      return isPresented;
    } on PlatformException catch (e) {
      log('Error in presentAppStore: $e');
      return false;
    } catch (e) {
      log('Error in presentAppStore: $e');
      return false;
    }
  }

  @override
  void setTextRecognizedCallback(Function(String) callback) {
    _textRecognizedCallback = callback;
  }
}
