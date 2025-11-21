import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../basa/main_constant.dart';
import '../../../basa/country_config_helper.dart';
import '../../../common/colors/app_colors.dart';
import '../../../controllers/language_controller.dart';
import '../../../provider/userDataHelper.dart';

class PrivacyPolicyPage extends StatefulWidget {
  PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  Future<String> _getDefaultPrivacyPolicyUrl() async {
    final countryCode = await UserDataHelper.getCountry();
    return Platform.isIOS
        ? CountryConfigHelper.getPrivacyPolicyUrl(countryCode)
        : Constant.URL_PRIVACY_POLICY_ANDROIF;
  }

  bool _isPrivacyPolicyUrl(String url) {
    return Constant.URL_PRIVACY_POLICY.contains(url) ||
        url == Constant.URL_PRIVACY_POLICY_ANDROIF;
  }

  String _privacyPolicyUrl = "";

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 从GetX arguments获取url，如果没有则使用默认url
    final arguments = Get.arguments;
    if (arguments != null &&
        arguments['url'] != null &&
        arguments['url'] != "") {
      _privacyPolicyUrl = arguments['url'];
    } else {
      _getDefaultPrivacyPolicyUrl().then((url) {
        setState(() {
          _privacyPolicyUrl = url;
        });
        _controller.loadRequest(Uri.parse(_privacyPolicyUrl));
      });
    }
    // Initialize WebViewController
    _controller = WebViewController()
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
      );
      if (_privacyPolicyUrl!="") {
        _controller.loadRequest(Uri.parse(_privacyPolicyUrl));
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_isPrivacyPolicyUrl(_privacyPolicyUrl))
              ? 'privacyPolicy'.tr
              : 'termsOfService'.tr,
        ),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
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
