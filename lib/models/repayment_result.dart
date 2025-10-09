import 'package:dart_mappable/dart_mappable.dart';
part 'repayment_result.mapper.dart';



@MappableClass()
class RepaymentResultData with RepaymentResultDataMappable {
  final String? payChannel;
  final String payUrl;
  final String? paymentCode;
  final String? productLogo;
  final String? productName;
  final num? repayAmount;
  final num? repaymentAmount;
  final int? type;

  RepaymentResultData({
    this.payChannel,
    required this.payUrl,
    this.paymentCode,
    this.productLogo,
    this.productName,
    this.repayAmount,
    this.repaymentAmount,
    this.type,
  });
}

class Allocation {
  final num allocationAmount;
  final String appOrderId;
  final int installmentId;

  Allocation({
    required this.allocationAmount,
    required this.appOrderId,
    required this.installmentId,
  });

  Map<String, dynamic> toJson() => {
    "allocationAmount": allocationAmount,
    "appOrderId": appOrderId,
    "installmentId": installmentId,
  };
}
