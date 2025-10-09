import 'package:flutter/material.dart';
import 'package:flutter3APP/l10n/app_strings.dart';
import 'package:flutter3APP/views/home_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../../provider/app_state.dart';
import '../colors/app_colors.dart';
import '../../routes/routes.dart';
import '../logger/app_logger.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage>
    with TickerProviderStateMixin {
  late final WebViewController webViewController;
  late final AnimationController _animationController;
  double progress = 0;
  String? errorMessage;
  bool _isInitialLoad = true;
  bool canGoBack = false;
  late String url;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    url = args['url'] ?? "";
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animationController.repeat();

    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..addJavaScriptChannel(
            'quickSave',
            onMessageReceived: (JavaScriptMessage message) {
              switch (message.message) {
                case 'goBakHome':
                  Get.find<HomeController>().refreshWithPage();
                  Get.until((route) => route.settings.name == Routes.home);
                  break;
                case 'finish':
                  Get.back();
                  break;
                default:
                  LogUtil.d(
                    'quickSave: Unsupported message: ${message.message}',
                  );
              }
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progressValue) {
                if (_isInitialLoad) {
                  setState(() {
                    progress = progressValue / 100;
                  });
                  if (progressValue == 100) {
                    _animationController.stop();
                  }
                }
              },
              onPageStarted: (String url) {
                setState(() {
                  errorMessage = null;
                  if (_isInitialLoad) {
                    progress = 0;
                    _animationController.repeat();
                  }
                });
                webViewController.canGoBack().then((value) {
                  setState(() {
                    canGoBack = value;
                  });
                });
              },
              onPageFinished: (String finishedUrl) {
                if (_isInitialLoad && finishedUrl == url) {
                  setState(() {
                    progress = 1.0;
                    _animationController.stop();
                    _isInitialLoad = false;
                  });
                }
                webViewController.runJavaScript("""
              window.quickSave = window.quickSave || {};
              window.quickSave.goBakHome = function() {
                quickSave.postMessage('goBakHome');
              };
              window.quickSave.finish = function() {
                quickSave.postMessage('finish');
              };
            """);
              },
              onWebResourceError: (WebResourceError error) {
                setState(() {
                  errorMessage =
                      "The page could not be loaded: ${error.description}";
                  _animationController.stop();
                  _isInitialLoad = false;
                });
              },
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(url)).catchError((e) {
            setState(() {
              errorMessage = "Error loading: $e";
              _animationController.stop();
              _isInitialLoad = false;
            });
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            AppStrings.repayment
        ),
        titleTextStyle:TextStyle(color: Colors.white,fontSize: 20),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              webViewController.goBack();
            } else {
              Get.find<HomeController>().refreshWithPage();
              Get.until((route) => route.settings.name == Routes.home);

            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child:
              _isInitialLoad && progress < 1.0
                  ? LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ),
      body: WebViewWidget(controller: webViewController),
    );
  }
}
