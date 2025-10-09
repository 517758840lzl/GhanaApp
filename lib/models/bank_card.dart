import 'package:dart_mappable/dart_mappable.dart';

part 'bank_card.mapper.dart';

@MappableClass()
class BankCardListData with BankCardListDataMappable {
  final int bankCardMaxNum;
  final List<BankCardInfo> userBankCardInfoRespList;

  BankCardListData({
    required this.bankCardMaxNum,
    required this.userBankCardInfoRespList,
  });
}

@MappableClass()
class BankCardInfo with BankCardInfoMappable {
  final String? bankAccountCCI;

  /// 注意：为避免精度问题，此处转换为 String
  final String bankCardNo;
  final int bankId;
  final String bankName;
  final int? bankType;
  final String? bankTypeDesc;
  final String? holderIdCardNumber;
  final String? holderName;
  final int id;
  final int priority;

  BankCardInfo({
    this.bankAccountCCI,
    required this.bankCardNo,
    required this.bankId,
    required this.bankName,
    this.bankType,
    this.bankTypeDesc,
    this.holderIdCardNumber,
    this.holderName,
    required this.id,
    required this.priority,
  });
}
