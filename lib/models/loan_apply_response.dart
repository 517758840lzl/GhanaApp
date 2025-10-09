import 'package:dart_mappable/dart_mappable.dart';

part 'loan_apply_response.mapper.dart';

@MappableClass()
class LoanApplyData with LoanApplyDataMappable {
  final List<OrderDetail>? list;

  LoanApplyData({this.list});
}

@MappableClass()
class OrderDetail with OrderDetailMappable {
  final String? appOrderId;
  // final String feeId;
  final num loanAmount;
  final String productCode;

  OrderDetail({
    this.appOrderId,
    // required this.feeId,
    required this.loanAmount,
    required this.productCode,
  });
}
