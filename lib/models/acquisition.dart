import 'package:dart_mappable/dart_mappable.dart';

part 'acquisition.mapper.dart';

@MappableClass()
class AcquisitionProgressData with AcquisitionProgressDataMappable {
  final int filledStep;
  final List<ProcessStep> processSteps;
  final int totalStep;

  AcquisitionProgressData({
    required this.filledStep,
    required this.processSteps,
    required this.totalStep,
  });
}

@MappableClass()
class ProcessStep with ProcessStepMappable {
  final List<EntryResp>? entries;
  final String pageTitle;
  final int pageType;
  final int step;

  ProcessStep({
    this.entries,
    required this.pageTitle,
    required this.pageType,
    required this.step,
  });
}

@MappableClass()
class EntryResp with EntryRespMappable {
  final String code;
  final String? defaultText;
  final String key;
  final int must;
  final int order;
  final String? rules;
  final List<Select>? selectList;
  final String showContent;
  final String? submitValue;
  final int type;

  EntryResp({
    required this.code,
    this.defaultText,
    required this.key,
    required this.must,
    required this.order,
    this.rules,
    this.selectList,
    required this.showContent,
    this.submitValue,
    required this.type,
  });
}

@MappableClass()
class Select with SelectMappable {
  final String key;
  final String value;

  Select({required this.key, required this.value});
}
