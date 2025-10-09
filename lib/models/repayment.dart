import 'package:dart_mappable/dart_mappable.dart';

part 'repayment.mapper.dart';

@MappableClass()
class RepaymentItem with RepaymentItemMappable {
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
  final int orderStatus;
  final String orderStatusStr;
  final int? productLevel;
  final String productLogo;
  final String productName;
  final String productSetCode;
  final int? rejectTime;
  final int remainingDays;
  final num repaidAmount;
  final num repayAmount;
  final String repayDate;
  final String repayDateStr;
  final int sort;
  final int term;
  final int totalServiceDays;
  final String updateTime;

  RepaymentItem({
    required this.acqChannel,
    required this.appOrderId,
    required this.bankCardName,
    required this.bankCardNo,
    required this.bankCardType,
    this.closeTime,
    this.countdownTime,
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
