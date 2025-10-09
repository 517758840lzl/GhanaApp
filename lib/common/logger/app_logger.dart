import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static AppLogger? _instance;
  late Logger _logger;

  // 私有构造函数
  AppLogger._() {
    bool DEBUG = bool.fromEnvironment('DEBUG', defaultValue: false) || kDebugMode;
    _logger = Logger(
      level: DEBUG ? Level.all : Level.off,
      printer: PrettyPrinter(
        methodCount: 2, // 显示多少行方法调用
        errorMethodCount: 8, // 错误时显示多少行
        lineLength: 120, // 每行长度
        colors: true, // 彩色日志
        printEmojis: true, // 显示表情
        printTime: true, // 显示时间
      ),
    );
  }

  // 获取单例
  static AppLogger get instance {
    _instance ??= AppLogger._();
    return _instance!;
  }

  // 调试日志
  void d(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message,error: error, stackTrace:stackTrace);
  }

  // 信息日志
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message,error: error, stackTrace:stackTrace);
  }

  // 警告日志
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace:stackTrace);
  }

  // 错误日志
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace:stackTrace);
  }

  // 详细日志
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error: error, stackTrace:stackTrace);
  }

  // 严重错误日志
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf(message, error: error, stackTrace:stackTrace);
  }
}

// 为了更方便使用，可以定义一个全局变量
final LogUtil = AppLogger.instance;
