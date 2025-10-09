import 'package:dart_mappable/dart_mappable.dart';

part 'order_history.mapper.dart';

@MappableClass()
class OrderHistoryItem with OrderHistoryItemMappable {
  final String acqChannel;
  final String appOrderId;
  final String bankCardName;
  final String bankCardNo;
  final String bankCardType;
  final int? closeTime;
  final int? countdownTime;
  final String createTime;
  final num interest;
  final bool isExtensionSwitch;
  final num loanAmount;
  final int
  orderStatus; //20:审核中 22:审核拒绝 3:放款中 4:还款中 5:放款失败未关闭 6:还款完成 结清订单 7-异常关闭
  final String orderStatusStr;
  final int? productLevel;
  final String productLogo;
  final String productName;
  final String productSetCode;
  final int? rejectTime;
  final int remainingDays;
  final num repaidAmount;
  final num receiptAmount;
  final num repayAmount;
  final String repayDate;
  final String repayDateStr;
  final int sort;
  final int term;
  final int totalServiceDays;
  final String updateTime;

  OrderHistoryItem({
    required this.acqChannel,
    required this.appOrderId,
    required this.bankCardName,
    required this.bankCardNo,
    required this.bankCardType,
    this.closeTime,
    this.countdownTime,
    required this.receiptAmount,
    required this.createTime,
    required this.interest,
    required this.isExtensionSwitch,
    required this.loanAmount,
    required this.orderStatus,
    required this.orderStatusStr,
    this.productLevel,
    required this.productLogo,
    required this.productName,
    required this.productSetCode,
    this.rejectTime,
    required this.remainingDays,
    required this.repaidAmount,
    required this.repayAmount,
    required this.repayDate,
    required this.repayDateStr,
    required this.sort,
    required this.term,
    required this.totalServiceDays,
    required this.updateTime,
  });
}
