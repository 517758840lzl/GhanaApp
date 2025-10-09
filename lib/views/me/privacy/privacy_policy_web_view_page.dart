import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../basa/main_constant.dart';
import '../../../common/colors/app_colors.dart';
import '../../../l10n/app_strings.dart';

class PrivacyPolicyPage extends StatefulWidget {
  PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String _privacyPolicyUrl =
      Platform.isIOS
          ? Constant.URL_PRIVACY_POLICY
          : Constant.URL_PRIVACY_POLICY_ANDROIF;

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 从GetX arguments获取url，如果没有则使用widget.url
    final arguments = Get.arguments;
    if (arguments != null && arguments['url'] != null) {
      _privacyPolicyUrl = arguments['url'];
    }
    // Initialize WebViewController
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {},
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(_privacyPolicyUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_privacyPolicyUrl == Constant.URL_PRIVACY_POLICY ||
                  _privacyPolicyUrl == Constant.URL_PRIVACY_POLICY_ANDROIF)
              ? AppStrings.privacyPolicy
              : AppStrings.termsOfService,
        ),
        titleTextStyle:TextStyle(color: Colors.black,fontSize: 20),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
