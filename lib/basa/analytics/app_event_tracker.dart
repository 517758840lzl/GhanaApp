import 'dart:async';

import '../../common/logger/app_logger.dart';
import '../../http/api_urls.dart';
import '../../http/http.dart';
import 'package:flutter_udid/flutter_udid.dart';

class _ControlEvent {
  _ControlEvent({required this.code, required this.eventName});

  final String code;
  final String eventName;
  int clickCount = 0;
  int clickSelect = 0; //0无选择 1相册 2拍照 3live
  int? lastStartTimeMs;
  int? lastEndTimeMs;

  Map<String, dynamic> toArgs() {
    return {
      "clickCount": clickCount,
      "clickSelect": clickSelect,
      "startTime": (lastStartTimeMs ?? 0).toString(),
      "endTime": (lastEndTimeMs ?? 0).toString(),
    };
  }
}

class _PageEvent {
  _PageEvent({required this.step, required this.pageTitle});

  final int step;
  final String pageTitle;
  int? startTimeMs;
  int? endTimeMs;
  int stayDuration = 0; // 停留时长，单位秒

  Future<Map<String, dynamic>> toMap() async {
    String udid = await FlutterUdid.udid;
    return {
      "eventId": udid,
      "eventName": "PAGE",
      "clientTimestamp": endTimeMs ?? DateTime.now().millisecondsSinceEpoch,
      "argsMap": {},
      "arg1": step,
      "arg2": "",
      "arg3": stayDuration.toString(),
      "arg4": "",
    };
  }
}

class _ExitEvent {
  _ExitEvent({required this.step});

  final int step;
  int exitCount = 0;
  int? lastExitTimeMs;

  Future<Map<String, dynamic>> toMap() async {
    String udid = await FlutterUdid.udid;
    return {
      "eventId": udid,
      "eventName": "EXIT",
      "clientTimestamp":
          lastExitTimeMs ?? DateTime.now().millisecondsSinceEpoch,
      "argsMap": {},
      "arg1": step,
      "arg2": "",
      "arg3": exitCount.toString(),
      "arg4": "",
    };
  }
}

class AppEventTracker {
  AppEventTracker._();
  static final AppEventTracker instance = AppEventTracker._();

  /// step -> (code -> event)
  Map<int, Map<String, _ControlEvent>> _stepEvents = {};

  /// step -> page event
  Map<int, _PageEvent> _pageEvents = {};

  /// step -> exit event
  Map<int, _ExitEvent> _exitEvents = {};

  void _ensureStep(int step) {
    _stepEvents.putIfAbsent(step, () => <String, _ControlEvent>{});
  }

  // 开始页面事件
  void startPageEvent(int step, String pageTitle) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _pageEvents[step] = _PageEvent(step: step, pageTitle: pageTitle);
    _pageEvents[step]!.startTimeMs = now;
  }

  // 结束页面事件
  void endPageEvent(int step) {
    final pageEvent = _pageEvents[step];
    if (pageEvent != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      pageEvent.endTimeMs = now;
      if (pageEvent.startTimeMs != null) {
        pageEvent.stayDuration = (now - pageEvent.startTimeMs!).round();
      }
    }
  }

  // 记录退出事件
  void recordExitEvent(int step) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _exitEvents.putIfAbsent(step, () => _ExitEvent(step: step));
    _exitEvents[step]!.exitCount += 1;
    _exitEvents[step]!.lastExitTimeMs = now;
  }

  void startInteraction(int step, String code, String eventName) {
    if (code.isEmpty) return;
    _ensureStep(step);
    final events = _stepEvents[step]!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final evt = events.putIfAbsent(
      code,
      () => _ControlEvent(code: code, eventName: eventName),
    );
    evt.clickCount += 1;
    evt.lastStartTimeMs = now;
  }

  //选择某个选项比如相册和拍照
  void selectInteraction(int step, String code, int index) {
    final events = _stepEvents[step];
    if (events == null) return;
    final evt = events[code];
    if (evt == null) return;
    evt.clickSelect = index;
  }

  void endInteraction(int step, String code) {
    final events = _stepEvents[step];
    if (events == null) return;
    final evt = events[code];
    if (evt == null) return;
    evt.lastEndTimeMs = DateTime.now().millisecondsSinceEpoch;
  }

  void endAllOpenForStep(int step) {
    final events = _stepEvents[step];
    if (events == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final evt in events.values) {
      if (evt.lastStartTimeMs != null &&
          (evt.lastEndTimeMs == null ||
              evt.lastEndTimeMs! < evt.lastStartTimeMs!)) {
        evt.lastEndTimeMs = now;
      }
    }
  }

  void cleanData() {
    _stepEvents = {};
    _pageEvents = {};
    _exitEvents = {};
  }

  // 构建所有事件的数组
  Future<List<Map<String, dynamic>>> _buildAllEventsPayload(int step) async {
    final list = <Map<String, dynamic>>[];
    String udid = await FlutterUdid.udid;

    // 添加页面事件
    final pageEvent = _pageEvents[step];
    if (pageEvent != null) {
      list.add(await pageEvent.toMap());
    }

    // 添加控件事件
    final events = _stepEvents[step] ?? {};
    for (final evt in events.values) {
      list.add({
        "eventId": udid,
        "eventName": "UI",
        "clientTimestamp":
            evt.lastEndTimeMs ?? DateTime.now().millisecondsSinceEpoch,
        "argsMap": {},
        "arg1": step,
        "arg2": evt.code,
        "arg3": evt.clickCount.toString(),
        "arg4":
            evt.clickSelect == 0
                ? ""
                : (evt.clickSelect == 1
                    ? "ALBUM"
                    : (evt.clickSelect == 2 ? "TAKE" : "LIVE")),
      });
    }

    // 添加退出事件
    final exitEvent = _exitEvents[step];
    if (exitEvent != null) {
      list.add(await exitEvent.toMap());
    }

    return list;
  }

  Future<void> flushCurrentStep(int step, String pageTitle) async {
    try {
      // 结束页面事件
      endPageEvent(step);

      // 结束所有未结束的交互
      endAllOpenForStep(step);

      // 构建事件数组
      final eventsList = await _buildAllEventsPayload(step);

      if (eventsList.isEmpty) return;

      // 上报事件数组
      final up = await HttpUtil.fetchModel(
        FetchType.post,
        url: ApiUrls.postSysmetaEvents,
        body: {"list": eventsList},
      );

      if (up.isSucceed) {
        LogUtil.d(
          '✔ 埋点上报成功 step=$step, page=$pageTitle, events=${eventsList.length}',
        );
      } else {
        LogUtil.d('✖ 埋点上报失败: ${up.msg}');
      }
    } catch (e) {
      LogUtil.d('❌ 埋点上报异常: $e');
    } finally {
      // 清理当前步骤的数据
      _stepEvents.remove(step);
      _pageEvents.remove(step);
      _exitEvents.remove(step);
    }
  }
}
