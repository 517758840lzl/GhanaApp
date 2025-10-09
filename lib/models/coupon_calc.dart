import 'package:dart_mappable/dart_mappable.dart';

part 'coupon_calc.mapper.dart';

@MappableClass()
class OrderCustomerCouponData with OrderCustomerCouponDataMappable {
  final double? actualToAccountMoney;
  final double? loanAmount;
  final double? newLoanAmount;
  final double? newRepaymentAmount;
  final double? rent;
  final double? repaymentAmount;
  final double? serviceFee;
  final double? totalMinRepayAmounts;

  final int? totalServiceDays; //天数

  OrderCustomerCouponData({
    required this.actualToAccountMoney,
    required this.loanAmount,
    required this.newLoanAmount,
    required this.newRepaymentAmount,
    required this.rent,
    required this.repaymentAmount,
    required this.serviceFee,
    required this.totalMinRepayAmounts,
    required this.totalServiceDays,
  });
}
