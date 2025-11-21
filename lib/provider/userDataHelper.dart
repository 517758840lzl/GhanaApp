import 'package:flutter/cupertino.dart';
import 'package:flutter3APP/http/http.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/provider/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/logger/app_logger.dart';

class UserDataHelper {
  // String? _phoneNumber;
  // String? _token;
  // String? _userId;
  // bool? _cacheData; //是否审核人员

  static const String _keyPhoneNumber = 'phone_number';
  static const String _keyToken = 'token';
  static const String _keyUserId = 'user_id';
  static const String _keyCacheData = 'cacheData'; //是否审核人员

  static const String _keyCountry = 'country'; //是国家
  static Future<void> saveUserData(String phoneNumber, String token, int? userId, int cacheData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyPhoneNumber, phoneNumber);
      await prefs.setString(_keyToken, token);
      await prefs.setInt(_keyUserId, userId??0);
      await prefs.setInt(_keyCacheData, cacheData);
      AppState.to.login((userId??0).toString());
    } catch (e) {
      LogUtil.d('Failed to save user data: $e');
    }
  }

  //本地保存国家
  static Future<void> saveCountry(String country) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyCountry, country);
    } catch (e) {
      LogUtil.d('Failed to save country data: $e');
    }
  }

  static Future<String?> getCountry() async {
    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyCountry);
    } catch (e) {
      LogUtil.d('Failed to get country: $e');
      return null;
    }
  }

  static updateUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final user =prefs.getInt(_keyUserId);
      AppState.to.login(user.toString());
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getToken() async {
    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyToken);
    } catch (e) {
      // LogUtil.d('Failed to get token: $e');
      return null;
    }
  }

  static Future<int?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserId);
    } catch (e) {
      return null;
    }
  }

  //获取是否审核人员
  static Future<int> getCacheData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyCacheData) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<String?> getPhoneNumber() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyPhoneNumber);
    } catch (e) {
      return null;
    }
  }

  static clearUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPhoneNumber);
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyCacheData);
    } catch (e) {
      LogUtil.d('Failed to clear user data: $e');
    }
  }

  static clearUserToken() async {
    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUserId);
    } catch (e) {
      LogUtil.d('Failed to clear user data: $e');
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
