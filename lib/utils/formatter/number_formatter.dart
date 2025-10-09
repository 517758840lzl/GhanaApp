import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 输入数值格式化： 10000000.22，保留小数点后两位
class NumberInputFormatter extends TextInputFormatter {
  final num max;
  final num min;

  /// 小数位数
  final double decimalNum;

  NumberInputFormatter(
      {this.max = 10000000000, this.min = 0, this.decimalNum = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length <= oldValue.text.length) {
      return newValue;
    }

    var split = newValue.text.split(".");
    // 多个 .
    if (split.length > 2) {
      return oldValue;
    }

    // . 开头
    if (split[0].isEmpty) {
      return TextEditingValue();
    }

    var newNum = double.tryParse(newValue.text);
    if (newNum == null) {
      return oldValue;
    }

    if (newNum > max) {
      return oldValue;
    }

    if (newNum < min) {
      return oldValue;
    }

    if (split.length > 1 && split[1].length > decimalNum) {
      var format = NumberFormat('############.00');
      var price = double.tryParse(newValue.text);

      final finalPrice = format.format(price);
      return price == null
          ? newValue
          : TextEditingValue(
              text: finalPrice,
              selection: TextSelection.fromPosition(
                  TextPosition(offset: finalPrice.length)));
    }

    return newValue;
  }
}
