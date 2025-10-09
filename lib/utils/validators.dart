class Validators {

  // static bool isValidPhoneNumber(String phoneNumber) {
  //   final RegExp regex = RegExp(r'^9\d{8}$');
  //   return regex.hasMatch(phoneNumber);
  // }

  // 验证9位数字的手机号
  static bool isValidPhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^\d{9}$');
    return regex.hasMatch(phoneNumber);
  }
}
