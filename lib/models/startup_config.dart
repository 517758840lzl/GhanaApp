import 'package:dart_mappable/dart_mappable.dart';

part 'startup_config.mapper.dart';

@MappableClass()
class StartupConfigData with StartupConfigDataMappable {
  final AppListConfig appListConfig;
  final int compressionRatio;
  final String countryCode;
  final List<String> faceLiveStep;
  final Switches switches;

  StartupConfigData({
    required this.appListConfig,
    required this.compressionRatio,
    required this.countryCode,
    required this.faceLiveStep,
    required this.switches,
  });
}

@MappableClass()
class AppListConfig with AppListConfigMappable {
  final List<String> permission;
  final int wayType;

  AppListConfig({required this.permission, required this.wayType});
}

@MappableClass()
class Switches with SwitchesMappable {
  final int idConfirmationPopup;

  Switches({required this.idConfirmationPopup});
}
