import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/logger/app_logger.dart';

class StringUtil {


  //自动换行空白问题
  static String breakWord(String text) {
    if (text.isEmpty) {
      return text;
    }
    String breakWord = '';
    text.runes.forEach((element) {
      breakWord += String.fromCharCode(element);
      breakWord += '\u200B'; //'\u200B'不可见空格符
    });
    return breakWord;
  }


  //数字默认为两位--01，超过两位正常展示
  //unit位数默认为2位数
  static String numberToString(int index,{int unit=2}) {
    if (index < 1000 && index > 0) {
      String formattedNumber = index.toString().padLeft(unit, '0');
      return formattedNumber;
    }
    return index.toString();
  }


  //随机码
  static String generateAlphanumericRandomCode(int length) {
    const String alphanumeric =
        '0123456789';
    final random = Random();
    String code = '';
    for (int i = 0; i < length; i++) {
      code += alphanumeric[random.nextInt(alphanumeric.length)];
    }
    return code;
  }

  static String getFormatTotal(double total){
    var formatter = NumberFormat('0.00');
    String formattedDouble = formatter.format(total);
    return formattedDouble;
  }

  static String getIntFormatTotal(int total){
    double num = double.parse(total.toString());
    var formatter = NumberFormat('0.00');
    String formattedDouble = formatter.format(num);
    return formattedDouble;
  }

  static String formatAmount(num amount) {
    final formatter = NumberFormat('#,##0.###', 'en_GH');
    return formatter.format(amount);
  }

  static String formatDecimalAmount(num amount) {
    // 如果是整数，直接返回整数形式
    if (amount % 1 == 0) {
      return NumberFormat('0', 'en_GH').format(amount);
    }
    // 否则保留最多 3 位小数
    String result = NumberFormat('0.###', 'en_GH').format(amount);
    return result;
  }

  /// 将包含时分秒的日期字符串转换为仅包含年月日的格式
  /// [dateString] 输入格式如: "2025-07-03 00:00:00"
  /// 返回格式如: "2025-07-03"
  static String extractYmd(String dateString) {
    try {
      if (dateString=="") {
        return "";
      }
      // 解析原始日期字符串
      DateTime dateTime = DateTime.parse(dateString);

      // 格式化日期为年月日
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      // 处理解析错误，返回原始字符串或空值
      LogUtil.i('日期格式转换失败: $e');
      return dateString; // 或返回空字符串 ''，根据需求调整
    }
  }

  static String maskCardNumber(String cardNo) {
    if (cardNo.length <= 4) return cardNo;
    return '**** **** ${cardNo.substring(cardNo.length - 4)}';
  }
}
