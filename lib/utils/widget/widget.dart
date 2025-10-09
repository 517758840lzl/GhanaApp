import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  Widget infinity() => Container(child: this, width: double.infinity, height: double.infinity);
  GestureDetector onTap(Function()? fn) => GestureDetector(
        child: this,
        onTap:fn,
        behavior: HitTestBehavior.opaque,
      );
  GestureDetector onDoubleTap(Function()? fn) => GestureDetector(
        child: this,
        onDoubleTap: fn,
        behavior: HitTestBehavior.opaque,
      );
  GestureDetector onLongPress(Function()? fn) => GestureDetector(
        child: this,
        onLongPress: fn,
        behavior: HitTestBehavior.opaque,
      );


}


