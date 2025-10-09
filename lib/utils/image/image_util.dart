
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../common/logger/app_logger.dart';


class ImageUtil {


  // 将Widget转化为Uint8List
  static Future<Uint8List?> captureWidgetAsImage(GlobalKey _globalKey) async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0); // 获取图像，设置像素比例（提高清晰度）
      final byteData = await image.toByteData(format: ImageByteFormat.png); // 转换为 PNG 格式
      if (byteData != null) {
        return byteData.buffer.asUint8List(); // 返回Uint8List格式的二进制数据
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }


  // 压缩图像直到它的大小小于等于指定的最大字节数
  static Future<Uint8List> compressImageToSize(Uint8List imageBytes, {int maxSizeInBytes = 32 * 1024}) async {
    int quality = 100;
    int width = 1024; // 初始宽度
    int height = 1024; // 初始高度

    Uint8List result = imageBytes;

    while (result.lengthInBytes > maxSizeInBytes && quality > 10) {
      // 压缩图像
      result = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality, // 质量从 100 开始逐步降低
        minWidth: width,
        minHeight: height,
      );

      // 每次压缩后，减少质量
      quality -= 10;
      // 缩小图像尺寸
      width = (width * 0.9).toInt();
      height = (height * 0.9).toInt();
    }

    return result;
  }

  // 保存图片到沙盒
  static Future<String> saveImageToSandbox(Uint8List bytes, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${directory.path}/$fileName$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      LogUtil.e('保存图片到沙盒失败: $e');
      return '';
    }
  }
}
