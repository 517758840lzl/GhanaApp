import 'package:dart_mappable/dart_mappable.dart';

part 'step.mapper.dart';

@MappableClass()
class StepData with StepDataMappable {
  final int? userId;
  final int nextStep;
  final int isFinished;

  StepData({this.userId, required this.nextStep, required this.isFinished});
}
