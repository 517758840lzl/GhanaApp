import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter3APP/models/home_page_data.dart';

part 'loan_amount_confirm_response.mapper.dart';

@MappableClass()
class LoanAmountConfirmData with LoanAmountConfirmDataMappable {
  double actualToAccountMoney;
  String autoConfirmTips;
  int? autoLoan;
  int bankCardId;
  String bankCardName;
  String bankCardNo;
  String bankCardType;
  int cancelAutoConfirmSwitch;
  int countDownTime;
  List<Product> list;
  double loanAmount;
  String payDate;
  double rent;
  String repayDate;
  double serviceFee;

  LoanAmountConfirmData({
    required this.actualToAccountMoney,
    required this.autoConfirmTips,
    this.autoLoan,
    required this.bankCardId,
    required this.bankCardName,
    required this.bankCardNo,
    required this.bankCardType,
    required this.cancelAutoConfirmSwitch,
    required this.countDownTime,
    required this.list,
    required this.loanAmount,
    required this.payDate,
    required this.rent,
    required this.repayDate,
    required this.serviceFee,
  });
}
