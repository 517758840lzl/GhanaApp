import 'package:dart_mappable/dart_mappable.dart';

part 'loan_reject_info.mapper.dart';

@MappableClass()
class LoanRejectInfoData with LoanRejectInfoDataMappable {
  final String rejectDescription;
  final int rejectProducts;
  final num rejectTotalAmount;
  final int term;

  LoanRejectInfoData({
    required this.rejectDescription,
    required this.rejectProducts,
    required this.rejectTotalAmount,
    required this.term,
  });
}
