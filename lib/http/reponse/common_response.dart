import 'package:equatable/equatable.dart';

import '../../models/safe_convert.dart';

class RawResponseModel extends Equatable {
  final Map<String, dynamic>? data;

  RawResponseModel({this.data});

  factory RawResponseModel.fromJson(Map<String, dynamic> json) {
    return RawResponseModel(data: json);
  }

  Map<String, dynamic> toJson() => data ?? {};

  @override
  List<Object?> get props => [data];

  @override
  String toString() {
    return 'RawResponseModel{data: $data}';
  }
}

class BusinessResponse extends Equatable {
  final CommonResp? commonResp;

  BusinessResponse({this.commonResp});

  @override
  List<Object?> get props => [commonResp];

  factory BusinessResponse.fromJson(Map<String, dynamic>? json) => BusinessResponse(
        commonResp: CommonResp.fromJson(asMap(json, 'commonResp')),
      );

  Map<String, dynamic> toJson() => {
        'commonResp': commonResp?.toJson(),
      };

  bool get isSuccess => commonResp == null || commonResp!.errCode == null || commonResp!.errCode == 0;

  String? get message => commonResp?.errMsg;
}

class CommonResp extends Equatable {
  int? errCode;
  String? errMsg;

  CommonResp({this.errCode = 0, this.errMsg = ''});

  @override
  List<Object?> get props => [this.errCode, this.errMsg];

  factory CommonResp.fromJson(Map<String, dynamic>? json) => CommonResp(
        errCode: asInt(json, 'errCode'),
        errMsg: asString(json, 'errMsg'),
      );

  Map<String, dynamic> toJson() => {'errMsg': errMsg, 'errCode': errCode};
}
