import 'package:dart_mappable/dart_mappable.dart';

part 'confirm_user_apply_amount_info_req.mapper.dart';

@MappableClass()
class ConfirmUserApplyAmountInfoReq with ConfirmUserApplyAmountInfoReqMappable {
  // final  int isResetCountDownTime;
  final List<Param> list;

  ConfirmUserApplyAmountInfoReq({
    // required this.isResetCountDownTime,
    required this.list,
  });
}

@MappableClass()
class Param with ParamMappable {
  final String? appOrderId;
  // final String? feeId;
  final num loanAmount;
  final String productCode;

  Param({
    this.appOrderId,
    // this.feeId,
    required this.loanAmount,
    required this.productCode,
  });
}
