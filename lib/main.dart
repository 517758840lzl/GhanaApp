import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter3APP/http/http.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter3APP/basa/appsFlyer/apps_flyer_helper.dart';
import 'package:flutter3APP/basa/updateData/user_updata_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'basa/main_constant.dart';
import 'common/logger/app_logger.dart';
import 'provider/userDataHelper.dart';
import 'common/colors/app_colors.dart';

import 'provider/app_state.dart';
import 'routes/routes.dart';
import 'package:bot_toast/bot_toast.dart';
import 'http/api_urls.dart';
import 'controllers/language_controller.dart';
import 'l10n/app_translations.dart';

late TransitionBuilder botToastBuilder;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  botToastBuilder = BotToastInit();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  Get.put(AppState());
  
  // 初始化语言控制器
  final languageController = Get.put(LanguageController());
  // 等待语言初始化完成
  await languageController.initLanguage();
  
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final initialRoute = await _determineInitialRoute();
  FlutterNativeSplash.remove();

  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> _determineInitialRoute() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // if(Platform.isAndroid){
    //安卓有隐私说明，iOS不需要
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) return '/license';
    // }

    final token = await UserDataHelper.getToken();
    if (token == null) return '/login';
    final progressResponse = await ApiUrls.checkAcquisitionProgressV2();
    if (progressResponse.code != 200) {
      HttpUtil.cancelRequest();
      await UserDataHelper.clearUserToken();
      return '/login';
    } else {
      UserDataHelper.updateUserId();
    }
    final filledStep = progressResponse.data?['filledStep'] ?? 0;
    final totalStep = progressResponse.data?['totalStep'] ?? 0;
    return filledStep < totalStep ? '/kyc' : '/home';
  } catch (_) {
    return '/login';
  }
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppsFlyerHelper().requestTrackingPermission();
      await AppsFlyerHelper().initAppsFlyer();
      AppsFlyerHelper().getReferrer();
      UpDataServer().start();
    });
  }

  @override
  void dispose() {
    UpDataServer().stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      UpDataServer().stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return DisplayMetricsWidget(
      child: Obx(() => GetMaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: AppColors.white,
          ),
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
          ),
        ),
        // 配置支持的语言列表
        supportedLocales: const [
          Locale('en'), // 英文
          Locale('es'), // 西班牙语
        ],
        // 设置当前语言（响应式更新）
        locale: languageController.currentLocale.value,
        // 设置回退语言为英文
        fallbackLocale: const Locale('en'),
        // GetX 官方推荐的多语言翻译
        translations: AppTranslations(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        initialRoute: widget.initialRoute,
        opaqueRoute: false,
        getPages: routes,
        title: Constant.APP_NAME,
        routingCallback: (route) => printRoute(route),
        builder: (context, child) {
          child = botToastBuilder(context, child);
          return child;
        },
      )),
    );
  }

  printRoute(Routing? route) {
    if (route == null) {
      return;
    }

    LogUtil.d(
      'Navigate route ---------🔥🔥🔥--------->\nprevious:${route.previous} \n current:${route.current}, args:${route.args}',
    );
  }
}
