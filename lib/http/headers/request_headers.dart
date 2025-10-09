import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../basa/main_constant.dart';
import '../../common/logger/app_logger.dart';
import '../../provider/userDataHelper.dart';

class RequestHeaders {

  static Future<Map<String, String>> getDeviceInfo() async {
    String osName = 'Unknown';
    String userAgent = 'Unknown';
    String  idfv = 'Unknown';

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      // 获取设备信息
      if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        osName = 'iOS ${iosInfo.systemVersion}';
        userAgent = iosInfo.utsname.machine ?? 'Unknown';
        idfv = iosInfo.identifierForVendor ?? 'Unknown';

      }
      else{
        String udid = await FlutterUdid.udid;
        final androidInfo = await deviceInfoPlugin.androidInfo;
        osName = '${androidInfo.display}';
        userAgent = androidInfo.model ?? 'Unknown';
        idfv = udid ?? 'Unknown';
      }
    } catch (e) {
      LogUtil.i('Error fetching device info or ad ID: $e');
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final updatedVersion = packageInfo.buildNumber;
    // 检查本地是否已有广告 ID
    final prefs = await SharedPreferences.getInstance();
    final storedAdFa = Platform.isAndroid?prefs.getString('gaid'):prefs.getString('id_fa');
    final storedAfID = prefs.getString('flyer_uid');
    final mediaSource = prefs.getString('mediaSource');
    final referrer = prefs.getString('referrer');
    return {
      // 'X-Device-OS': osName,
      'userAgent': userAgent,
      'gaid': storedAdFa ?? '',//原gaid
      'deviceId': idfv,//原deviceId
      'afid': storedAfID ?? '',//原afid
      'mediaSource': mediaSource ?? '',//原mediaSource
      'referrer': referrer ?? '',//原referrer
      'clientType': Platform.isIOS ? 'ios' : 'android',//原clientType
      'appVersion': updatedVersion,//原appVersion
    };
  }

  static Future<Map<String, dynamic>> commonAppJsonHeaders({bool encryption=Constant.APP_ENCRYPTION}) async {
    // final deviceInfo = await getDeviceInfo();
    String? token = await UserDataHelper.getToken();
    if (token == null) {
      LogUtil.i('No token found');
    }
    return {
      'Content-Type': 'application/json',
      'Eingangskanal': 'GHQU',//原acqChannel
      'EingangskanalIndex': '2',//原acqChannelIndex
      if (token != null) 'Autogramm': token,//原token
      if (encryption==false)'disableEncBody': 'false',
      // ...deviceInfo,
    };
  }


  static Future<Map<String, dynamic>> commonFileUploadHeaders({bool encryption=Constant.APP_ENCRYPTION}) async {
    // final deviceInfo = await getDeviceInfo();
    String? token = await UserDataHelper.getToken();
    return {
      'Content-Type': 'application/json',
      'Eingangskanal': 'GHQU',
      'EingangskanalIndex': '2',
      if (token != null) 'Autogramm': token,
      if (encryption==false)'disableEncBody': 'false',
      // ...deviceInfo,
    };
  }
}