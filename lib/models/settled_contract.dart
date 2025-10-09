import 'package:dart_mappable/dart_mappable.dart';

part 'settled_contract.mapper.dart';

// 订单数据的类
@MappableClass()
class SettledContractData with SettledContractDataMappable {
  final int? current; // 当前页数
  final int? size; // 每页数量
  final int? total; // 总数
  final List<CheckoutOrderItem>? list; // 可空的订单列表

  SettledContractData({this.current, this.size, this.total, this.list});
}

@MappableClass()
class CheckoutOrderItem with CheckoutOrderItemMappable {
  final String appOrderId;
  final String productName;
  final String productLogo;
  // final String bankCardName;
  // final num loanAmount;
  final num repaidAmount;
  final int orderStatus;
  // final String orderStatusStr;
  final String repayDate;
  // final int countdownTime;

  CheckoutOrderItem({
    required this.appOrderId,
    required this.productName,
    required this.productLogo,
    // required this.bankCardName,
    // required this.loanAmount,
    required this.repaidAmount,
    required this.orderStatus,
    // required this.orderStatusStr,
    required this.repayDate,
    // required this.countdownTime,
  });
}
