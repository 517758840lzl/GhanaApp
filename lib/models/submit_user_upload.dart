import 'package:dart_mappable/dart_mappable.dart';

part 'submit_user_upload.mapper.dart';

@MappableClass()
class SubmitUserUploadDataResponse with SubmitUserUploadDataResponseMappable {
  final int code;
  final String msg;

  SubmitUserUploadDataResponse({required this.code, required this.msg});
}

@MappableClass()
class SubmitUserUploadDataReq with SubmitUserUploadDataReqMappable {
  late final int? hasCallLogPermission;
  late final int? hasContactPermission;
  late final int? hasGpsPermission;
  late final int? hasSmsPermission;
  final String? submitCallLogBytes;
  late final List<CallLog>? submitCallLogReq;
  late final List<int>? submitUserAppListBytes;
  late final List<UserApp>? submitUserAppListReq;
  late final List<int>? submitUserConnectBytes;
  late final List<UserConnect>? submitUserConnectReq;
  late final List<int>? submitUserDeviceInfoBytes;
  late final UserDeviceInfo? submitUserDeviceInfoReq;
  final List<int>? submitUserSmsBytes;
  late final List<UserSms>? submitUserSmsReq;
  final int? trackId;

  SubmitUserUploadDataReq({
    this.hasCallLogPermission,
    this.hasContactPermission,
    this.hasGpsPermission,
    this.hasSmsPermission,
    this.submitCallLogBytes,
    this.submitCallLogReq,
    this.submitUserAppListBytes,
    this.submitUserAppListReq,
    this.submitUserConnectBytes,
    this.submitUserConnectReq,
    this.submitUserDeviceInfoBytes,
    this.submitUserDeviceInfoReq,
    this.submitUserSmsBytes,
    this.submitUserSmsReq,
    this.trackId,
  });
}

@MappableClass()
class CallLog with CallLogMappable {
  final int? count;
  final String? date;
  final int? duration;
  final int? id;
  final String? name;
  final String? number;
  final int? type;

  CallLog({
    this.count,
    this.date,
    this.duration,
    this.id,
    this.name,
    this.number,
    this.type,
  });
}

@MappableClass()
class UserApp with UserAppMappable {
  final String? appName;
  final String? appPackage;
  final String? appVersion;
  final int? fiTime;
  final int? luTime;
  final String? permission;
  final int? systemApp;

  UserApp({
    this.appName,
    this.appPackage,
    this.appVersion,
    this.fiTime,
    this.luTime,
    this.permission,
    this.systemApp,
  });
}

@MappableClass()
class UserConnect with UserConnectMappable {
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? phone;

  UserConnect({this.firstName, this.lastName, this.name, this.phone});
}

@MappableClass()
class UserDeviceInfo with UserDeviceInfoMappable {
  final String? advertising_id;
  final AdvinceDeviceInfoBean? advinceDeviceInfoBean;
  final String? android_id;
  final int? androidVersionCode;
  final String? app_version;
  final String? base_band;
  final String? build_board;
  final String? build_brand;
  final String? build_host;
  final String? build_id;
  final String? build_product;
  final String? build_tags;
  final String? build_type;
  final String? build_user;
  final String? build_uuid;
  final String? cpu_cur_frequency;
  final String? cpu_max_frequency;
  final String? device_id;
  final String? device_id_9_sn;
  final int? device_root;
  final int? device_sim;
  final String? firebaseInstanceId;
  final int? hours_since_last_launch;
  final String? imei;
  final int? is_simulator;
  final String? language;
  final String? latitude;
  final String? longitude;
  final String? mac;
  final String? media_uuid;
  final String? meid;
  final String? new_imei;
  final String? os_version;
  final int? phoneAliveTime;
  final String? phone_brand;
  final String? phone_model;
  final String? screen_density;
  final String? screen_resolution;
  final int? sdcard_total_capacity;
  final int? sdcard_used_capacity;
  final int? sim_card_status;
  final String? sim_code;
  final String? sn;
  final String? sn_an9;
  final int? sysCurTimestamp;
  final int? total_memory;
  final int? total_storage;
  final int? used_memory;

  final Map<String, dynamic>? rawDeviceInfo;

  UserDeviceInfo({
    this.advertising_id,
    this.advinceDeviceInfoBean,
    this.android_id,
    this.androidVersionCode,
    this.app_version,
    this.base_band,
    this.build_board,
    this.build_brand,
    this.build_host,
    this.build_id,
    this.build_product,
    this.build_tags,
    this.build_type,
    this.build_user,
    this.build_uuid,
    this.cpu_cur_frequency,
    this.cpu_max_frequency,
    this.device_id,
    this.device_id_9_sn,
    this.device_root,
    this.device_sim,
    this.firebaseInstanceId,
    this.hours_since_last_launch,
    this.imei,
    this.is_simulator,
    this.language,
    this.latitude,
    this.longitude,
    this.mac,
    this.media_uuid,
    this.meid,
    this.new_imei,
    this.os_version,
    this.phoneAliveTime,
    this.phone_brand,
    this.phone_model,
    this.screen_density,
    this.screen_resolution,
    this.sdcard_total_capacity,
    this.sdcard_used_capacity,
    this.sim_card_status,
    this.sim_code,
    this.sn,
    this.sn_an9,
    this.sysCurTimestamp,
    this.total_memory,
    this.total_storage,
    this.used_memory,
    this.rawDeviceInfo,
  });
}

@MappableClass()
class AdvinceDeviceInfoBean with AdvinceDeviceInfoBeanMappable {
  final BatteryStatusInfo? batteryStatusInfo;
  final List<CalendarEvent>? calendarEventList;
  final DeviceBaseInfo? deviceBaseInfo;
  final FileInfo? fileInfo;
  final GeneralInfo? generalInfo;
  final ImieInfo? imieInfo;
  final LocalInfo? localInfo;
  final LocationInfo? locationInfo;
  final NetworkInfo? networkInfo;
  final String? newFingerprint;
  final OtherInfo? otherInfo;
  final PhoneSignalInfo? phoneSignalInfo;
  final ScreenInfo? screenInfo;
  final List<SensorInfo>? sensorList;
  final StorageInfo? storageInfo;

  AdvinceDeviceInfoBean({
    this.batteryStatusInfo,
    this.calendarEventList,
    this.deviceBaseInfo,
    this.fileInfo,
    this.generalInfo,
    this.imieInfo,
    this.localInfo,
    this.locationInfo,
    this.networkInfo,
    this.newFingerprint,
    this.otherInfo,
    this.phoneSignalInfo,
    this.screenInfo,
    this.sensorList,
    this.storageInfo,
  });
}

@MappableClass()
class BatteryStatusInfo with BatteryStatusInfoMappable {
  final int? batteryLevel;
  final int? batteryMax;
  final int? batteryPct;
  final int? isAcCharge;
  final int? isCharging;
  final int? isUsbCharge;

  BatteryStatusInfo({
    this.batteryLevel,
    this.batteryMax,
    this.batteryPct,
    this.isAcCharge,
    this.isCharging,
    this.isUsbCharge,
  });
}

@MappableClass()
class CalendarEvent with CalendarEventMappable {
  final int? accessLevel;
  final int? advanceTime;
  final int? allDay;
  final int? availability;
  final String? description;
  final int? displayColor;
  final String? duration;
  final int? endTime;
  final String? eventEndTimeZone;
  final int? eventId;
  final String? eventLocation;
  final String? eventTimeZone;
  final int? hasAlarm;
  final int? hasAttendeeData;
  final int? lastDate;
  final String? rdate;
  final String? rrule;
  final int? startTime;
  final int? status;
  final String? title;

  CalendarEvent({
    this.accessLevel,
    this.advanceTime,
    this.allDay,
    this.availability,
    this.description,
    this.displayColor,
    this.duration,
    this.endTime,
    this.eventEndTimeZone,
    this.eventId,
    this.eventLocation,
    this.eventTimeZone,
    this.hasAlarm,
    this.hasAttendeeData,
    this.lastDate,
    this.rdate,
    this.rrule,
    this.startTime,
    this.status,
    this.title,
  });
}

@MappableClass()
class DeviceBaseInfo with DeviceBaseInfoMappable {
  final String? androidId;
  final String? board;
  final String? brand;
  final int? buildTime;
  final int? cores;
  final int? createTime;
  final int? currentSystemTime;
  final String? deviceName;
  final String? deviceUuid;
  final String? fingerprint;
  final String? gaid;
  final int? isEmulator;
  final String? manufacturer;
  final String? model;
  final int? phoneType;
  final String? release;
  final int? sdkVersion;
  final String? serialNumber;

  DeviceBaseInfo({
    this.androidId,
    this.board,
    this.brand,
    this.buildTime,
    this.cores,
    this.createTime,
    this.currentSystemTime,
    this.deviceName,
    this.deviceUuid,
    this.fingerprint,
    this.gaid,
    this.isEmulator,
    this.manufacturer,
    this.model,
    this.phoneType,
    this.release,
    this.sdkVersion,
    this.serialNumber,
  });
}

@MappableClass()
class FileInfo with FileInfoMappable {
  final int? audioExternal;
  final int? audioInternal;
  final int? downloadFiles;
  final int? imagesExternal;
  final int? imagesInternal;
  final int? videoExternal;
  final int? videoInternal;

  FileInfo({
    this.audioExternal,
    this.audioInternal,
    this.downloadFiles,
    this.imagesExternal,
    this.imagesInternal,
    this.videoExternal,
    this.videoInternal,
  });
}

@MappableClass()
class GeneralInfo with GeneralInfoMappable {
  final int? canCallPhone;
  final int? elapsedRealtime;
  final int? isMockLocation; //是否是模拟位置0/1
  final int? isRootJailbreak; //是否Root
  final int? isUsbDebug; //是否开启了USB调试模式0/1
  final int? isUsingProxyPort; //是否使用了HTTP代理 需要ACCESS_NETWORK_STATE 0/1
  final int? isVpnConnected; //是否使用了VPN 需要ACCESS_NETWORK_STATE 0/1
  final int? keyboardType;
  final int? lastBootTime;
  final int? uptimeMillis;

  GeneralInfo({
    this.canCallPhone,
    this.elapsedRealtime,
    this.isMockLocation,
    this.isRootJailbreak,
    this.isUsbDebug,
    this.isUsingProxyPort,
    this.isVpnConnected,
    this.keyboardType,
    this.lastBootTime,
    this.uptimeMillis,
  });
}

@MappableClass()
class ImieInfo with ImieInfoMappable {
  final String? imei1;
  final String? imei2;
  final String? line1Number;
  final String? simSerialNumber;
  final int? subscriberId;

  ImieInfo({
    this.imei1,
    this.imei2,
    this.line1Number,
    this.simSerialNumber,
    this.subscriberId,
  });
}

@MappableClass()
class LocalInfo with LocalInfoMappable {
  final String? language;
  final String? localeDisplayLanguage;
  final String? localeIso3Country;
  final String? localeIso3Language;
  final String? networkOperatorName;
  final String? simCountryIso;
  final String? timeZoneId;

  LocalInfo({
    this.language,
    this.localeDisplayLanguage,
    this.localeIso3Country,
    this.localeIso3Language,
    this.networkOperatorName,
    this.simCountryIso,
    this.timeZoneId,
  });
}

@MappableClass()
class LocationInfo with LocationInfoMappable {
  final String? accuracy;
  final String? address;
  final List<dynamic>? addressList;
  final String? addressObject;
  final String? adminArea;
  final String? countryCode;
  final String? countryName;
  final String? featureName;
  final String? latitude;
  final String? locality;
  final String? longitude;
  final String? subAdminArea;
  final int? time;

  LocationInfo({
    this.accuracy,
    this.address,
    this.addressList,
    this.addressObject,
    this.adminArea,
    this.countryCode,
    this.countryName,
    this.featureName,
    this.latitude,
    this.locality,
    this.longitude,
    this.subAdminArea,
    this.time,
  });
}

@MappableClass()
class NetworkInfo with NetworkInfoMappable {
  final List<NetWorkInfo>? configuredWifi;
  final NetWorkInfo? currentWifi;
  final String? ip;
  final String? mac;
  final String? networkType;

  NetworkInfo({
    this.configuredWifi,
    this.currentWifi,
    this.ip,
    this.mac,
    this.networkType,
  });
}

@MappableClass()
class NetWorkInfo with NetWorkInfoMappable {
  final String? bssid;
  final String? mac;
  final String? name;
  final String? ssid;

  NetWorkInfo({this.bssid, this.mac, this.name, this.ssid});
}

@MappableClass()
class OtherInfo with OtherInfoMappable {
  final int? appFreeMemory;
  final int? appMaxMemory;
  final int? appTotalMemory;

  OtherInfo({this.appFreeMemory, this.appMaxMemory, this.appTotalMemory});
}

@MappableClass()
class PhoneSignalInfo with PhoneSignalInfoMappable {
  final int? dbm;
  final int? level;
  final int? type;

  PhoneSignalInfo({this.dbm, this.level, this.type});
}

@MappableClass()
class ScreenInfo with ScreenInfoMappable {
  final String? density;
  final int? densityDpi;
  final int? heightPixels;
  final String? physicalSize;
  final String? scaledDensity;
  final int? widthPixels;
  final String? xdpi;
  final String? ydpi;

  ScreenInfo({
    this.density,
    this.densityDpi,
    this.heightPixels,
    this.physicalSize,
    this.scaledDensity,
    this.widthPixels,
    this.xdpi,
    this.ydpi,
  });
}

@MappableClass()
class SensorInfo with SensorInfoMappable {
  final num? maxRange;
  final int? minDelay;
  final String? name;
  final num? power;
  final num? resolution;
  final int? type;
  final String? vendor;
  final int? version;

  SensorInfo({
    this.maxRange,
    this.minDelay,
    this.name,
    this.power,
    this.resolution,
    this.type,
    this.vendor,
    this.version,
  });
}

@MappableClass()
class StorageInfo with StorageInfoMappable {
  final int? internalStorageTotal;
  final int? internalStorageUsable;
  final int? memoryCardSize;
  final int? memoryCardSizeUse;
  final int? ramTotalSize;
  final int? ramUsableSize;
  final int? storageDirSize;
  final int? storageDirSizeUsable;

  StorageInfo({
    this.internalStorageTotal,
    this.internalStorageUsable,
    this.memoryCardSize,
    this.memoryCardSizeUse,
    this.ramTotalSize,
    this.ramUsableSize,
    this.storageDirSize,
    this.storageDirSizeUsable,
  });
}

@MappableClass()
class UserSms with UserSmsMappable {
  final String? body;
  final int? date;
  final int? dateSent;
  final String? id;
  final String? md5;
  final String? person;
  final String? phone;
  final int? type;

  UserSms({
    this.body,
    this.date,
    this.dateSent,
    this.id,
    this.md5,
    this.person,
    this.phone,
    this.type,
  });
}
