import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'colors/app_colors.dart';

class YDToast {
  static void text(
    String text, {
    Axis? axis,
    Duration? duration = const Duration(milliseconds: 2000),
    bool onlyOne = true,
  }) {
    BotToast.showEnhancedWidget(
      onlyOne: onlyOne,
      allowClick: true,
      duration: duration,
      clickClose: true,

      backButtonBehavior: BackButtonBehavior.close,
      ignoreContentClick: true,
      toastBuilder: (cancelFunc) {
        final textWidget = Text(
          text,
          maxLines: 18,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        );

        final horizontalWidget = Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            textWidget,
          ],
        );

        final verticalWidget = Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            textWidget,
          ],
        );
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).padding.top + 50,
          ),
          alignment: Alignment.bottomCenter,
          child: Builder(
            builder:
                (context) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: axis == Axis.vertical ? 16 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFF323232),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child:
                      axis == null
                          ? textWidget
                          : axis == Axis.horizontal
                          ? horizontalWidget
                          : verticalWidget,
                ),
          ),
        );
      },
      // borderRadius: const BorderRadius.all(Radius.circular(4))
    );
  }

  static Function() loading({
    String? text,
    Axis axis = Axis.vertical,
    bool? only,
    bool allowClick = false,
    bool clickClose = false,//是否点击关闭
    Duration duration = const Duration(milliseconds: 50000),
  }) => BotToast.showEnhancedWidget(
    onlyOne: only ?? true,
    allowClick: allowClick,
    clickClose: clickClose,
    duration: duration,
    backButtonBehavior: BackButtonBehavior.ignore,
    toastBuilder: (cancelFunc) {
      final textWidget = Text(
        text ?? 'loading'.tr,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 17),
      );

      final _icon = SizedBox(
        width: 33,
        height: 33,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 3,
          color: Colors.white.withOpacity(.8),
        ),
      );

      final horizontalWidget = Row(
        children: [
          Padding(padding: const EdgeInsets.only(right: 5.0), child: _icon),
          textWidget,
        ],
      );

      final verticalWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: const EdgeInsets.only(bottom: 10.0), child: _icon),
          textWidget,
        ],
      );
      return Center(
        child: UnconstrainedBox(
          child: Builder(
            builder:
                (context) => Container(
                  width: 136,
                  height: 136,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xFF323232),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child:
                      axis == Axis.horizontal
                          ? horizontalWidget
                          : verticalWidget,
                ),
          ),
        ),
      );
    },
    // borderRadius: const BorderRadius.all(Radius.circular(4))
  );

  static cleanAll() {
    BotToast.cleanAll();
  }
}
