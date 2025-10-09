import 'dart:io';

import '../../../common/colors/app_colors.dart';
import '../../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart' as AppSettings;
import 'package:webview_flutter/webview_flutter.dart';
import '../../../basa/main_constant.dart';
import '../../../common/logger/app_logger.dart';
import '../../../common/permission/permission_util.dart';
import 'package:get/get.dart';
import '../../../routes/routes.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  static const double dp10 = 10.0;
  static const double dp11 = 11.0;
  static const double dp16 = 16.0;
  static const double dp20 = 20.0;
  static const double dp25 = 25.0;
  static const double dp3 = 3.0;
  static const double dp6 = 6.0;
  static const double dp22 = 22.0;
  static const double dp46 = 46.0;
  static const double sp16 = 16.0;

  bool _isLoading = true;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initWebView();
    // //获取定位
    // _requestGpsPermission();
  }

  @override
  void dispose() {
    _webViewController = WebViewController();
    _webViewController.clearCache();
    _isLoading = false;
    super.dispose();
  }

  void _initWebView() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              Platform.isIOS
                  ? Constant.URL_PRIVACY_POLICY
                  : Constant.URL_PRIVACY_POLICY_ANDROIF,
            ),
          );
  }

  Future<void> _requestGpsPermission() async {
    final hasLocation = await PermissionUtil.checkAndRequest(
      Permission.location,
    );
    if (hasLocation) {
      LogUtil.d('GPS permission granted');
    } else {
      LogUtil.d('GPS permission denied');
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text(AppStrings.locationPermissionRequired),
                content: const Text(AppStrings.locationPermissionMessage),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(AppStrings.cancel),
                  ),
                  TextButton(
                    onPressed: () async {
                      AppSettings.openAppSettings();
                      Get.back();
                    },
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
        );
      }
    }
  }

  void _onAgreePressed() async {
    await getPermission();
    Get.offNamed(Routes.login);
  }

  getPermission() async {
    if (Platform.isAndroid) {
      await PermissionUtil.checkAndRequest(Permission.camera);
      await PermissionUtil.checkAndRequest(Permission.location);

      //根据配置来
      await PermissionUtil.checkAndRequest(Permission.sms);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text(AppStrings.exitApplication),
                content: const Text(AppStrings.logoutConfirmation),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text(AppStrings.cancel),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text(AppStrings.goOut),
                  ),
                ],
              ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text(
            AppStrings.privacyPolicy,
          ),
          titleTextStyle:TextStyle(color: Colors.black,fontSize: 20),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () async {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text(AppStrings.exitApplication),
                      content: const Text(AppStrings.logoutConfirmation),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text(AppStrings.cancel),
                        ),
                        TextButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text(AppStrings.goOut),
                        ),
                      ],
                    ),
              );
              if (shouldExit ?? false) {
                exit(0);
              }
            },
          ),
          backgroundColor: AppColors.primaryColor,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: dp10),
                  decoration: const BoxDecoration(
                    color: AppColors.whiteBgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(dp11, dp11, dp11, dp20),
                    padding: const EdgeInsets.symmetric(horizontal: dp10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteBgColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WebView 和 ProgressBar
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: Stack(
                              children: [
                                WebViewWidget(controller: _webViewController),
                                if (_isLoading)
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.progressBarColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.fromLTRB(dp20, 0, dp20, 0),
                height: dp46,
                child: ElevatedButton(
                  onPressed: _onAgreePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.buttonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, dp46),
                  ),
                  child: Text(
                    AppStrings.agreeButtonText,
                    style: const TextStyle(fontSize: sp16),
                  ),
                ),
              ),
              SizedBox(
                height: dp46,
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    final shouldExit = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text(AppStrings.exitApplication),
                            content: const Text(AppStrings.logoutConfirmation),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(result: false),
                                child: const Text(AppStrings.cancel),
                              ),
                              TextButton(
                                onPressed: () => Get.back(result: true),
                                child: const Text(AppStrings.goOut),
                              ),
                            ],
                          ),
                    );
                    if (shouldExit ?? false) {
                      exit(0);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    minimumSize: const Size(double.infinity, dp46),
                  ),
                  child: Text(
                    AppStrings.rejection,
                    style: const TextStyle(
                      fontSize: sp16,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
