import 'package:dart_mappable/dart_mappable.dart';

part 'extension.mapper.dart';

@MappableClass()
class ExtensionInfoData with ExtensionInfoDataMappable {
  final num extensionFee;
  final num newExtensionFee;
  final num extensionWaivedAmount;
  final String extensionRepaymentDate;
  final num totalSureRepayAmounts;
  final int remainingDay;

  ExtensionInfoData({
    required this.extensionFee,
    required this.newExtensionFee,
    required this.extensionWaivedAmount,
    required this.extensionRepaymentDate,
    required this.totalSureRepayAmounts,
    required this.remainingDay,
  });
}
