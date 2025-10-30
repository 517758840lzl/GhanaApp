import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter3APP/basa/analytics/app_event_tracker.dart';
import '../../common/permission/permission_util.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_constant.dart';
import '../../../http/api_urls.dart';
import '../../../http/http.dart';
import '../../common/logger/app_logger.dart';

class AppsFlyerHelper {
  static final AppsFlyerHelper _instance = AppsFlyerHelper._internal();
  factory AppsFlyerHelper() => _instance;

  AppsFlyerHelper._internal();
  late AppsflyerSdk _appsflyerSdk;

  String appsFlyerUID = "";

  bool checkInit = false;//是否完成初始化

  Future<void> initAppsFlyer() async {
    try {
      if (checkInit) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();

      // SDK Options
      final AppsFlyerOptions options = AppsFlyerOptions(
        afDevKey: Constant.afDevKey,
        appId: Platform.isAndroid ? "" : Constant.appId,
        showDebug: kDebugMode ? true : false,
        timeToWaitForATTUserAuthorization: 15,
        disableAdvertisingIdentifier: false,
      );
      _appsflyerSdk = AppsflyerSdk(options);



      // Conversion data callback
      _appsflyerSdk.onInstallConversionData((res) {
        try {
          LogUtil.d("onInstallConversionData res: " + res.toString());
          checkInit=true;
          firstClick();
          Map<String, dynamic> stringKeyMap = {};
          if (res is Map) {
            stringKeyMap = Map<String, dynamic>.from(res);
            // upDataClick(stringKeyMap);
          }
          if (stringKeyMap.containsKey("status") &&
              stringKeyMap["status"] == "success" &&
              stringKeyMap.containsKey("payload")) {
            final mediaSource = getMediaSource(
              Map<String, dynamic>.from(stringKeyMap["payload"]),
            );
            final mediaSourceStr = prefs.getString('mediaSource') ?? "";
            if (mediaSourceStr == "Organic" ||
                mediaSourceStr == "organic" ||
                mediaSourceStr == "") {
              String mediaSourceRm = removeDiacritics(mediaSource);
              prefs.setString('mediaSource', mediaSourceRm);
            }
          }
        } catch (e) {

          LogUtil.d("mediaSource--err-----${e}");
        }
      });

      _appsflyerSdk.onAppOpenAttribution((res) {
        LogUtil.d("onAppOpenAttribution res: " + res.toString());
      });

      _appsflyerSdk.onDeepLinking((DeepLinkResult res) {
        LogUtil.d("onDeepLinking res: " + res.toString());
      });

      await _appsflyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );


      String? afUID = await _appsflyerSdk.getAppsFlyerUID();
      appsFlyerUID = afUID ?? "";
      await prefs.setString('flyer_uid', afUID ?? '');
      LogUtil.d("AppsFlyer UID: $appsFlyerUID");
    }
    catch(e){
      LogUtil.d("af--err-----${e}");
    }

  }



  upDataClick(Map<String, dynamic> data) async {
    try {
      String gaid = await AdvertisingId.id(true) ?? "";
      String appsFlyerUID = await _appsflyerSdk.getAppsFlyerUID() ?? "";
      final req = {
        "eventId": "0",
        "eventName": "submitAppFlyerData",
        "argsMap": data,
        "arg1": gaid,
        "arg2": appsFlyerUID,
        "arg3": "",
        "arg4": "",
        "clientTimestamp": DateTime.now().millisecondsSinceEpoch,
      };

      final up = await HttpUtil.fetchModel(
        FetchType.post,
        url: ApiUrls.postSysmetaEvents,
        body: req,
      );
      if (up.isSucceed) {
        LogUtil.d('✔ 上报AF数据 成功');
        LogUtil.d('req:$req\n');
      } else {
        LogUtil.d('✖ 上报AF数据 failed: ${up.msg}');
      }
    } catch (e, st) {
      LogUtil.d('❌ 上报AF数据: $e');
    }
  }

  /// 检查字符串是否已经被URL编码
  bool _isUrlEncoded(String str) {
    if (str.isEmpty) return false;

    try {
      // 检查是否包含URL编码的特征字符（%后跟两个十六进制字符）
      RegExp urlEncodedPattern = RegExp(r'%[0-9A-Fa-f]{2}');

      // 如果包含编码模式，进一步验证
      if (urlEncodedPattern.hasMatch(str)) {
        // 尝试解码整个字符串
        String decoded = Uri.decodeComponent(str);

        // 如果解码成功且结果不同，说明确实被编码过
        if (decoded != str) {
          // 再次检查解码后的字符串是否还包含编码模式
          // 如果解码后还包含编码模式，说明是部分编码，需要重新编码
          if (urlEncodedPattern.hasMatch(decoded)) {
            return false; // 部分编码，需要重新编码
          }
          return true; // 完全编码
        }
      }

      return false; // 没有编码模式，未编码
    } catch (e) {
      // 如果解码失败，说明可能包含无效的编码字符，认为未编码
      LogUtil.d("URL编码检查失败: $e");
      return false;
    }
  }

  Future<void> getReferrer() async {
    // String acrStr = Uri.encodeComponent("Señor López");
    // String acrStr1 = Uri.encodeComponent("utm_source=(not%20set)&utm_medium=(not%20set)");
    // String acrStr2 = Uri.encodeComponent("utm_source=google-play&utm_medium=organic");
    try {
      if (Platform.isAndroid) {
        final prefs = await SharedPreferences.getInstance();
        final referrer = prefs.getString('referrer');
        if (referrer == null || referrer == "") {
          //注意：安装引荐来源信息的保留期限为 90 天，除非用户重新安装应用，否则这些信息不会发生变化。为避免在应用中进行不必要的 API 调用，您应该仅在应用安装后的首次执行期间调用该 API 一次。
          ReferrerDetails referrerDetails =
          await AndroidPlayInstallReferrer.installReferrer;
          // 获取关键信息
          final referrerUrl =
              referrerDetails.installReferrer ?? ""; // 完整 referrer URL
          if (referrerUrl != "") {
            // 检查是否已经被URL编码，如果没有则进行编码
            String referrerRd = removeDiacritics(referrerUrl);
            // String acrStr =
            // _isUrlEncoded(referrerRd)
            //     ? referrerRd
            //     : Uri.encodeComponent(referrerRd);
            await prefs.setString('referrer', referrerRd);
          }
        }
      }
      } catch (e) {}

  }

  Future<void> requestTrackingPermission() async {
    //需要区分安卓和ios
    if (Platform.isAndroid) {
      try {
        bool isLimitAdTrackingEnabled =
            await AdvertisingId.isLimitAdTrackingEnabled ?? false;
        if (!isLimitAdTrackingEnabled) {
          String? gaid = await AdvertisingId.id(true);
          if (gaid != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('gaid', gaid);
            LogUtil.d("GAID: $gaid");
          }
        }
      } catch (e) {
        LogUtil.d("获取gaid失败：${e.toString()}");
      }
    } else {
      try {
        // 请求追踪授权
        TrackingStatus status =
        await AppTrackingTransparency.requestTrackingAuthorization();
        final prefs = await SharedPreferences.getInstance();
        // 处理授权结果
        switch (status) {
          case TrackingStatus.authorized:
            String idfa =
            await AppTrackingTransparency.getAdvertisingIdentifier();
            await prefs.setString('id_fa', idfa);
            LogUtil.d("IDFA: $idfa");
            break;
          case TrackingStatus.denied:
            LogUtil.d("Tracking permission denied");
            break;
          case TrackingStatus.notDetermined:
            LogUtil.d("Tracking permission not determined");
            break;
          case TrackingStatus.restricted:
            LogUtil.d("Tracking permission restricted");
            break;
          case TrackingStatus.notSupported:
            throw UnimplementedError();
        }
      }
      catch(e){

      }
    }
  }

  String getMediaSource(Map<String, dynamic>? conversionData) {
    if (conversionData == null) return "";

    String status = "";

    if (conversionData.containsKey("af_status")) {
      status = conversionData["af_status"].toString();
    }

    if (status.isEmpty || status.toLowerCase() == "organic") {
      return "Organic";
    }

    String campaign = conversionData["campaign"]?.toString() ?? "";
    if (campaign.isNotEmpty && campaign != "None") {
      return campaign;
    }

    String mediaSource = conversionData["media_source"]?.toString() ?? "";
    if (mediaSource.isNotEmpty && mediaSource != "None") {
      return mediaSource;
    }

    return "No-Organic";
  }

  Future<bool> _logEvent(
      String eventName, {
        String? body,
        String? heads,
        String? msg,
      }) async {
    bool? result;
    try {
      final time = DateFormat("dd/MM/yyyy HH:mm:ss").format(DateTime.now());
      Map<String, dynamic> paramMap = {"create_time": time};
      if (body != null || heads != null) {
        paramMap = {"create_time": time, "body": body, "heads": heads};
      }
      if (msg != null) {
        paramMap = {"create_time": time, "msg": msg};
      }
      result = await _appsflyerSdk.logEvent(eventName, paramMap);
      LogUtil.d("Result logEvent: $result");
      return result ?? false;
    }  catch (e) {
      LogUtil.d("Result logEvent: $e");
      return false;
    }
  }

  void setCustomerUserId(String customerUserId) {
    try {
      _appsflyerSdk.setCustomerUserId(customerUserId);
    } on Exception catch (e) {
      LogUtil.d(e);
    }
  }

  void firstClick() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstOpen = prefs.getBool("isFirstOpen")?? true;
    if(isFirstOpen) {
      eventFirstOpen();
    }
  }

  void eventFirstOpen() async {
    _logEvent("first_open");
  }

  Future<void> eventRegisterApply({String? body, String? heads}) async {

    _logEvent("register_apply", body: body, heads: heads);
  }

  void eventRegisterApplyResult({String? msg}) {
    _logEvent("register_apply_result", msg: msg);
  }

  void eventRegisterErr({String? msg}) {
    _logEvent("register_err", msg: msg);
  }

  void eventOtpApply({String? body}) async {
    _logEvent("otp_apply", body: body);
  }

  void eventRequestErr({String? msg}) async {
    _logEvent("request_err", msg: msg);
  }

  void eventOtpApplyResult({String? msg}) async {
    _logEvent("otp_apply_result", msg: msg);
  }

  void eventRegisterSuccess({String? msg}) async {
    _logEvent("register_success",msg: msg);
  }

  void eventAutoOrder() async {
    _logEvent("auto_order");
  }

  void eventWithdrawApply() async {
    _logEvent("withdraw_apply");
  }

  void eventWithdrawSuccess() async {
    _logEvent("withdraw_success");
  }
}