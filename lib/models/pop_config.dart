import 'package:dart_mappable/dart_mappable.dart';

part 'pop_config.mapper.dart';


@MappableClass()
class PopConfigData with PopConfigDataMappable {
  final String? cancelText;
  final Map<String, dynamic>? config;
  final String? description;
  final int isPop;
  final String? okText;
  final int? rate;
  final String? title;

  PopConfigData({
    this.cancelText,
    this.config,
    this.description,
    required this.isPop,
    this.okText,
    this.rate,
    this.title,
  });
}