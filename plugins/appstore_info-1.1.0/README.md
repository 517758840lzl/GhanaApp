# AppStore Info Plugin

一个Flutter插件，用于在应用内展示App Store页面，并支持截图和文字识别功能。

## 功能特性

- 在应用内展示App Store页面
- 自动截图并识别页面中的文字
- 将识别结果返回给Flutter应用

## 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  appstore_info: ^1.1.0
```

## 使用方法

### 基本用法

```dart
import 'package:appstore_info/appstore_info.dart';

final AppstoreInfo appstoreInfo = AppstoreInfo();

// 设置文字识别回调
appstoreInfo.setTextRecognizedCallback((String recognizedText) {
  print('识别到的文字: $recognizedText');
});

// 打开App Store页面
bool? success = await appstoreInfo.presentAppStore(appID: '389801252');
```

### 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:appstore_info/appstore_info.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppstoreInfo _appstoreInfo = AppstoreInfo();
  String _recognizedText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 设置文字识别回调
    _appstoreInfo.setTextRecognizedCallback((String text) {
      setState(() {
        _recognizedText = text;
        _isLoading = false;
      });
    });
  }

  Future<void> _openAppStore() async {
    setState(() {
      _isLoading = true;
      _recognizedText = '';
    });

    try {
      final bool? success = await _appstoreInfo.presentAppStore(appID: '389801252');
      if (success != true) {
        setState(() {
          _isLoading = false;
        });
        // 处理错误
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 处理异常
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AppStore Info Example')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _openAppStore,
            child: _isLoading 
                ? Text('正在识别文字...') 
                : Text('打开App Store并识别文字'),
          ),
          if (_recognizedText.isNotEmpty)
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(_recognizedText),
              ),
            ),
        ],
      ),
    );
  }
}
```

## API 参考

### AppstoreInfo

#### 方法

- `Future<bool?> presentAppStore({required String appID})`
  - 打开App Store页面
  - 参数：`appID` - 应用的App Store ID
  - 返回：成功返回true，失败返回false

- `void setTextRecognizedCallback(Function(String) callback)`
  - 设置文字识别回调
  - 参数：`callback` - 识别到文字时的回调函数

## 平台支持

- ✅ iOS (使用Vision框架进行文字识别)
- ❌ Android (暂不支持)

## 注意事项

1. 此插件仅在iOS平台上支持文字识别功能
2. 文字识别需要设备支持Vision框架
3. 识别结果的质量取决于页面内容的清晰度和文字的可读性
4. 建议在页面完全加载后再进行识别，插件会自动延迟2秒后开始识别

## 许可证

MIT License