import 'package:dart_mappable/dart_mappable.dart';

part 'pop_dialog.mapper.dart';

@MappableClass()
class PopDialogData with PopDialogDataMappable {
  int? isPop;
  String? okText;
  String? cancelText;
  String? title;
  String? description;
  Config? config;
  int? rate;

  PopDialogData({
    this.isPop,
    this.okText,
    this.cancelText,
    this.title,
    this.description,
    this.config,
    this.rate,
  });
}

@MappableClass()
class Config with ConfigMappable {
  final int score;
  final int isShowEmail;

  Config({required this.score, required this.isShowEmail});
}
