# Android Security Detector Plugin

这是一个专门针对Android平台的安全检测插件，用于检测设备的安全状态。

## 功能特性

- **Root检测**: 检测设备是否已Root或越狱
- **代理检测**: 检测是否使用HTTP代理
- **VPN检测**: 检测是否连接VPN
- **USB调试检测**: 检测是否开启USB调试模式
- **模拟位置检测**: 检测是否开启模拟位置

## 权限要求

插件需要以下Android权限：
- `ACCESS_NETWORK_STATE`: 用于检测网络状态（代理、VPN）
- `INTERNET`: 用于网络相关检测

## 使用方法

```dart
import 'package:android_security_detector/android_security_detector.dart';

// 获取安全检测信息
Map<String, int> securityInfo = await AndroidSecurityDetector.getSecurityInfo();

// 返回值说明：
// isRootJailbreak: 是否Root (0=否, 1=是)
// isUsingProxyPort: 是否使用HTTP代理 (0=否, 1=是)
// isVpnConnected: 是否连接VPN (0=否, 1=是)
// isUsbDebug: 是否开启USB调试 (0=否, 1=是)
// isMockLocation: 是否开启模拟位置 (0=否, 1=是)
```

## 集成到UpDataServer

插件已经集成到`UpDataServer`的`updataAndroidDevice`方法中，会自动获取安全检测信息并填充到`GeneralInfo`对象中。

## 技术实现

- 使用Kotlin编写Android原生代码
- 基于Google官方API进行检测
- 支持Android 4.1+ (API 16+)
- 异常安全，检测失败时返回默认安全值

## 注意事项

- 仅支持Android平台
- 检测结果可能因设备厂商定制而有所差异
- 某些检测方法可能被恶意应用绕过
