import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../basa/main_constant.dart';
import 'package:dart_des/dart_des.dart';
import 'package:flutter/foundation.dart';

import '../../common/logger/app_logger.dart';

class DESCryptUtil {
  // static String encryptClick(Map data, {String? key}) {
  //   if (Constant.APP_ENCRYPTION) {
  //       return encryptECB(data);
  //   }
  //   return data;
  // }

  //解密
  static Map<String, dynamic> decryptClick(dynamic data, {String? key}) {
    if (Constant.APP_ENCRYPTION && data is String) {
      return decryptECB(data);
    }
    if (data != null && data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {};
  }

  /// 异步加密方法 - ECB模式，避免主线程阻塞
  static Future<String> encryptECBAsync(String plainText, {String? key}) async {
    return await compute(_encryptECBCompute, {
      'plainText': plainText,
      'key': key,
    });
  }

  // compute专用的静态方法
  static String _encryptECBCompute(Map<String, dynamic> params) {
    final String plainText = params['plainText'];
    final String? key = params['key'];
    return encryptECB(plainText, key: key);
  }

  /// 加密方法 - ECB模式
  static String encryptECB(String plainText, {String? key}) {


    key ??= Constant.DES_KEY;
    // String plainText=jsonEncode(data);
    final des = DES(
      key: utf8.encode(_fixKey(key)),
      mode: DESMode.ECB,
      paddingType: DESPaddingType.PKCS7,
    );
    final encrypted = des.encrypt(utf8.encode(plainText));
    final encoded = base64Encode(encrypted);

    return encoded;
  }

  /// 解密方法 - ECB模式
  static Map<String, dynamic> decryptECB(dynamic encryptedText, {String? key}) {
    if (encryptedText is Map<String, dynamic>) {
      return encryptedText;
    }

    key ??= Constant.DES_KEY;
    final des = DES(
      key: utf8.encode(_fixKey(key)),
      mode: DESMode.ECB,
      paddingType: DESPaddingType.PKCS7,
    );
    final decrypted = des.decrypt(base64.decode(encryptedText));
    final uf = utf8.decode(decrypted);
    Map<String, dynamic> jsonMap = jsonDecode(uf) ?? {};
    return jsonMap;
  }

  /// 异步解密方法 - ECB模式，避免主线程阻塞
  static Future<Map<String, dynamic>> decryptECBAsync(
    String encryptedText, {
    String? key,
  }) async {
    return await compute(_computeDecryptECBCompute, {
      'encryptedText': encryptedText,
      'key': key,
    });
  }

  // compute专用的静态方法（解密）
  static Map<String, dynamic> _computeDecryptECBCompute(
    Map<String, dynamic> params,
  ) {
    final String encryptedText = params['encryptedText'];
    final String? key = params['key'];
    return decryptECB(encryptedText, key: key);
  }

  /// 加密方法 - CBC模式
  static String encryptCBC(String plainText, String iv, {String? key}) {
    key ??= Constant.DES_KEY;
    final des = DES(
      key: utf8.encode(_fixKey(key)),
      mode: DESMode.CBC,
      iv: utf8.encode(_fixIV(iv)),
      paddingType: DESPaddingType.PKCS7,
    );
    final encrypted = des.encrypt(utf8.encode(plainText) as Uint8List);
    return base64.encode(encrypted);
  }

  /// 解密方法 - CBC模式
  static String decryptCBC(String encryptedText, String iv, {String? key}) {
    key ??= Constant.DES_KEY;
    final des = DES(
      key: utf8.encode(_fixKey(key)),
      mode: DESMode.CBC,
      iv: utf8.encode(_fixIV(iv)),
      paddingType: DESPaddingType.PKCS7,
    );
    final decrypted = des.decrypt(base64.decode(encryptedText));
    return utf8.decode(decrypted);
  }

  /// 修正密钥长度为8字节
  static String _fixKey(String key) {
    var bytes = utf8.encode(key);
    if (bytes.length == 8) return key;
    if (bytes.length > 8) return utf8.decode(bytes.sublist(0, 8));
    return key.padRight(8, '0');
  }

  /// 修正IV长度为8字节
  static String _fixIV(String iv) {
    var bytes = utf8.encode(iv);
    if (bytes.length == 8) return iv;
    if (bytes.length > 8) return utf8.decode(bytes.sublist(0, 8));
    return iv.padRight(8, '0');
  }



  /// 将Map转换为压缩后的字节
  static Future<List<int>> mapToCompressedBytes(Map<String, dynamic> map) async {
    try {
      // 1. 将Map序列化为JSON字符串（也可使用其他格式如protobuf，JSON更通用）
      String jsonString = json.encode(map);

      // 2. 将JSON字符串转换为UTF-8字节
      List<int> jsonBytes = utf8.encode(jsonString);

      // 3. 使用GZIP压缩字节（压缩率高，适合文本类数据）
      List<int> compressedBytes = ZLibEncoder(level: 6).convert(jsonBytes);

      LogUtil.i('压缩前大小: ${jsonBytes.length} 字节');
      LogUtil.i('压缩后大小: ${compressedBytes.length} 字节');
      LogUtil.i('压缩率: ${(compressedBytes.length / jsonBytes.length * 100).toStringAsFixed(2)}%');

      return compressedBytes;
    } catch (e) {
      LogUtil.i('转换或压缩失败: $e');
      throw e; // 抛出异常让调用方处理
    }
  }

  // 将List转换为字节并压缩
  static Uint8List compressList(List<dynamic> list) {
    try {
      // 1. 将List转换为JSON字符串
      String jsonString = json.encode(list);

      // 2. 将JSON字符串转换为字节数组
      Uint8List bytes = utf8.encode(jsonString);

      // 3. 使用ZIP压缩算法（DEFLATE）压缩字节数组
      // 这种方式压缩的结果可以被Java的Inflater正确解压
      List<int> compressedBytes = ZLibEncoder(level: 6).convert(bytes);

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      LogUtil.i('压缩失败: $e');
      throw Exception('无法压缩列表数据');
    }
  }
}
