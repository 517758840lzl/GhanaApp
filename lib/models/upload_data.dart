import 'package:dart_mappable/dart_mappable.dart';

part 'upload_data.mapper.dart';

@MappableClass()
class UploadDataCheckData with UploadDataCheckDataMappable {
  final int appTrackId;
  final int isValid;
  final int isValidAppList; //app列表 0需要 1不需要
  final int isValidCallLog; //通话记录
  final int isValidContacts; //联系人
  final int isValidDeviceInfo; //设备信息
  final int isValidSmsRecord; //短信

  UploadDataCheckData({
    required this.appTrackId,
    required this.isValid,
    required this.isValidAppList,
    required this.isValidCallLog,
    required this.isValidContacts,
    required this.isValidDeviceInfo,
    required this.isValidSmsRecord,
  });
}
