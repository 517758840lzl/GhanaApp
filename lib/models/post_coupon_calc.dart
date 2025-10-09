import 'package:dart_mappable/dart_mappable.dart';

part 'post_coupon_calc.mapper.dart';

@MappableClass()
class PostLoanCouponData with PostLoanCouponDataMappable {
  final double? actualToAccountMoney;
  final double? loanAmount;
  final double? newLoanAmount;
  final double newRepaymentAmount;
  final double? rent;
  final double repaymentAmount;
  final double? serviceFee;
  final double totalMinRepayAmounts;

  PostLoanCouponData({
    this.actualToAccountMoney,
    this.loanAmount,
    this.newLoanAmount,
    required this.newRepaymentAmount,
    this.rent,
    required this.repaymentAmount,
    this.serviceFee,
    required this.totalMinRepayAmounts,
  });
}
