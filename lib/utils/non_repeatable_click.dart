class NonRepeatableClick {
 static DateTime? _lastClickTime;

 /// 检查是否可以点击，防重
 static Future<void> checkClick({Duration debounceDuration = const Duration(milliseconds: 500),void Function()? click}) async{
    DateTime now = DateTime.now();
    if (_lastClickTime == null ||
        now.difference(_lastClickTime!) >= debounceDuration) {
      _lastClickTime = now;
      if(click!=null) {
        click.call();
      }
    }
  }

}