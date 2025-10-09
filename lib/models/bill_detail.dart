import 'package:dart_mappable/dart_mappable.dart';

part 'bill_detail.mapper.dart';

@MappableClass()
class BillDetailsData with BillDetailsDataMappable {
  final bool? extensionSwitch;
  final bool? isExtensionSwitch;
  final List<LoanOrderDetail>? loanOrderDetails;
  final int? remainingDay;
  final int? sureRepayPeriods;
  final num? totalMinRepayAmounts;
  final num? totalSureRepayAmounts;
  final num? waivedAmount;

  BillDetailsData({
    this.extensionSwitch,
    this.isExtensionSwitch,
    this.loanOrderDetails,
    this.remainingDay,
    this.sureRepayPeriods,
    this.totalMinRepayAmounts,
    this.totalSureRepayAmounts,
    this.waivedAmount,
  });
}

@MappableClass()
class LoanOrderDetail with LoanOrderDetailMappable {
  final String acqChannel;
  final String appOrderId;
  final int bankAccountId;
  final String? bankAccountType;
  final String bankCardNo;
  final String bankName;
  final int? closeTime;
  final int daysPerTerm;
  final int installmentId;
  final int installmentNum;
  final num interest;
  final num loanAmount;
  final int orderStatus;
  final String? orderStatusDesc;
  final num overdueInterest;
  final String productCode;
  final String productLogo;
  final String productName;
  final num receiptAmount;
  final int? rejectTime;
  final int remainingDay;
  final String repayDate;
  final num repaymentAmount;
  final num serviceFee;
  final int term;
  final String updateTime;
  final num waivedAmount;

  LoanOrderDetail({
    required this.acqChannel,
    required this.appOrderId,
    required this.bankAccountId,
    this.bankAccountType,
    required this.bankCardNo,
    required this.bankName,
    this.closeTime,
    required this.daysPerTerm,
    required this.installmentId,
    required this.installmentNum,
    required this.interest,
    required this.loanAmount,
    required this.orderStatus,
    this.orderStatusDesc,
    required this.overdueInterest,
    required this.productCode,
    required this.productLogo,
    required this.productName,
    required this.receiptAmount,
    this.rejectTime,
    required this.remainingDay,
    required this.repayDate,
    required this.repaymentAmount,
    required this.serviceFee,
    required this.term,
    required this.updateTime,
    required this.waivedAmount,
  });
}
