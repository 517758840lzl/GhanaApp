import 'dart:convert';
import 'package:crypto/crypto.dart';

class Md5 {
  static String stringToMd5(String input) {
  final bytes = utf8.encode(input);
  final digest = md5.convert(bytes);
  return digest.toString();
  }
}