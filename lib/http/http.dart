import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response hide MultipartFile hide FormData;
import 'package:flutter3APP/http/reponse/response.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../basa/main_constant.dart';
import '../basa/country_config_helper.dart';
import '../common/logger/app_logger.dart';
import '../../utils/des/des.dart';
import '../common/toast.dart';
import '../provider/app_state.dart';
import '../provider/userDataHelper.dart';
import '../routes/routes.dart';
import 'err_code.dart';
import 'headers/request_headers.dart';

// import 'log_util.dart';
// import 'package_util.dart';

enum FetchType { head, get, post, put, patch, delete }

enum CodeType { success, fail }

class HttpUtil {
  const HttpUtil._();

  static const String _tag = '🌐 HttpUtil';

  static bool isOffline = true; //是否需要掉线检测

  /// 根据国家代码获取对应的 BASE_URL
  static Future<String> getBaseUrl() async {
    try {
      return await CountryConfigHelper.getBaseUrlAsync();
    } catch (e) {
      LogUtil.d('Failed to get base URL: $e');
      return Constant.BASE_URL.first;
    }
  }

  static BaseOptions get dioBaseOptions {
    return BaseOptions(
      baseUrl: Constant.BASE_URL.first, // 默认使用第一个，实际会在拦截器中动态更新
      connectTimeout: Duration(milliseconds: 60000),
      sendTimeout: Duration(milliseconds: 60000),
      receiveTimeout: Duration(milliseconds: 60000),
      receiveDataWhenStatusError: true,
    );
  }

  static final Dio dio = Dio()
    ..options = dioBaseOptions
    ..interceptors.addAll(dioInterceptors);

  static CancelToken cancelToken = CancelToken();

  static List<Interceptor> get dioInterceptors => <Interceptor>[
    if (kDebugMode) PrettyDioLogger(requestHeader: true, requestBody: true, responseHeader: true),
    _interceptor,
  ];

  static ResponseModel<T> successModel<T extends DataModel>() => ResponseModel<T>.succeed();

  static ResponseModel<T> _failModel<T extends DataModel>(String message) =>
      ResponseModel<T>.failed(msg: '${ResponseModel.errorInternalRequest}: $message');

  //headers可以使用commonAppJsonHeaders或commonAppXwwwFormHeaders，默认commonAppJsonHeaders
  static Future<ResponseModel<T>> fetchModel<T>(
    FetchType fetchType, {
    required String url,
    Map<String, dynamic>? queryParameters,
    Object? body,
    Json? headers,
    bool encryption = Constant.APP_ENCRYPTION,
    ResponseType responseType = ResponseType.json,
    bool Function(Json json)? modelFilter,
    bool toastError = true,
  }) async {
    final stopwatch1 = Stopwatch()..start();
    final encryptData = encryption && body != null ? DESCryptUtil.encryptECB(jsonEncode(body)) : body;
    LogUtil.d('${stopwatch1.elapsedMilliseconds} ms');
    stopwatch1.stop();
    // final stopwatch2 = Stopwatch()..start();
    // final encryptData = encryption&&body!=null ?await NativeDes.encrypt(data:jsonEncode(body), key: Constant.DES_KEY) : body;
    // stopwatch2.stop();
    if (cancelToken.isCancelled) {
      cancelToken = CancelToken();
    }
    final header = headers == null ? await RequestHeaders.commonAppJsonHeaders() : headers;
    final Response<Json> response = await getResponse(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      body: encryptData,
      headers: header,
      responseType: responseType,
      cancelToken: cancelToken,
    );

    final Json? resBody = response.data;
    if (resBody?.isNotEmpty ?? false) {
      final ResponseModel<T> model = ResponseModel<T>.fromJson(resBody!, modelFilter: modelFilter);

      if (!model.isSucceed) {
        switch (model.code) {
          case ErrCode.CODE_KICK_OUT:
            break;
          default:
            if (toastError) {
              if (model.code != 404) {
                if (toastError) {}
              }
              LogUtil.i("${model.msg}");
            }
            break;
        }
      }
      return model;
    } else {
      return _handleStatusCode(response);
    }
  }

  static Future<Response<T>> getResponse<T>(
    FetchType fetchType, {
    required String url,
    Map<String, dynamic>? queryParameters,
    Object? body,
    required Json headers,
    ResponseType? responseType = ResponseType.json,
    CancelToken? cancelToken,
    bool Function(Json json)? modelFilter,
  }) async {
    final Json effectiveHeaders = headers.map<String, dynamic>(
      (String key, dynamic value) => MapEntry<String, dynamic>(key, value.toString()),
    );

    Uri replacedUri = Uri.parse(url).replace(
      queryParameters: queryParameters?.map<String, String>(
        (String key, dynamic value) => MapEntry<String, String>(key, value.toString()),
      ),
    );

    final Options options = Options(
      followRedirects: true,
      headers: effectiveHeaders,
      receiveDataWhenStatusError: true,
      responseType: responseType,
    );

    final Response<T> response;
    switch (fetchType) {
      case FetchType.head:
        response = await dio.headUri(replacedUri, data: body, options: options, cancelToken: cancelToken);
        break;
      case FetchType.get:
        response = await dio.getUri(replacedUri, options: options, cancelToken: cancelToken);
        break;
      case FetchType.post:
        response = await dio.postUri(replacedUri, data: body, options: options, cancelToken: cancelToken);
        break;
      case FetchType.put:
        response = await dio.putUri(replacedUri, data: body, options: options, cancelToken: cancelToken);
        break;
      case FetchType.patch:
        response = await dio.patchUri(replacedUri, data: body, options: options, cancelToken: cancelToken);
        break;
      case FetchType.delete:
        response = await dio.deleteUri(replacedUri, data: body, options: options, cancelToken: cancelToken);
        break;
    }
    if (response.data == '') {
      response.data = null;
    }
    return response;
  }

  static ResponseModel<T> _handleStatusCode<T extends DataModel>(Response<dynamic> response) {
    final int statusCode = response.statusCode ?? 0;
    // _log('Response status code: ${response.statusCode}');
    if (statusCode >= 200 && statusCode < 300) {
      // _log('Response code success: $statusCode');
      return successModel();
    } else if (statusCode >= 300 && statusCode < 400) {
      // _log('Response code moved: $statusCode');
      return successModel();
    } else if (statusCode >= 400 && statusCode < 500) {
      final String message = 'Response code client error: $statusCode';
      // _log(message);
      return _failModel(message);
    } else if (statusCode >= 500) {
      final String message = 'Response code server error: $statusCode';
      // _log(message);
      return _failModel(message);
    } else {
      final String message = 'Response code unknown status: $statusCode';
      // _log(message);
      return _failModel(message);
    }
  }

  //做数据解析的拦截器，http正常数据已使用requestDataCheck做数据处理，该拦截器只做异常错误处理
  static QueuedInterceptorsWrapper get _interceptor {
    return QueuedInterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        // 根据国家代码动态设置 baseUrl
        try {
          final baseUrl = await getBaseUrl();
          if (options.baseUrl != baseUrl) {
            options.baseUrl = baseUrl;
          }
        } catch (e) {
          LogUtil.d('Failed to update baseUrl in interceptor: $e');
        }
        handler.next(options); // 继续处理请求
        options.extra["startTime"] = DateTime.now().millisecondsSinceEpoch;
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) async {
        int startTime = response.requestOptions.extra["startTime"] ?? 0;
        int endTime = DateTime.now().millisecondsSinceEpoch;
        int requestTime = endTime - startTime;
        LogUtil.i("${response.requestOptions.path}----${requestTime}");
        final responseJson = response;
        final stopwatch1 = Stopwatch()..start();
        final responseData = DESCryptUtil.decryptClick(response.data);
        LogUtil.d('${stopwatch1.elapsedMilliseconds} ms');
        stopwatch1.stop();
        // final stopwatch2 = Stopwatch()..start();
        // final responseData = response.data!=null?await NativeDes.decrypt(data:response.data, key: Constant.DES_KEY):response.data;
        // stopwatch2.stop();

        responseJson.data = responseData;
        if (responseJson.data["code"] == ErrCode.CODE_KICK_OUT) {
          if (!Get.currentRoute.contains(Routes.login) && AppState.to.isLoggedIn.value == true) {
            YDToast.text('accountLoggedOut'.tr);
            AppState.to.logout();
            Get.offAllNamed(Routes.login);
          }
        }
        handler.next(responseJson); // 继续处理响应
      },
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        String? errorMsg;
        int? code;
        final sourceResp = e.response;

        final error = e.error;
        if (error is DioException) {
          errorMsg = error.message;
        } else if (error is HandshakeException) {
          errorMsg = "$error";
        } else if (error is SocketException) {
          errorMsg = error.message;
        } else {
          errorMsg = "$error";
        }

        if (errorMsg == null||errorMsg =="null"||errorMsg =="") {
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
              errorMsg = 'Request timeout';
              break;
            case DioExceptionType.sendTimeout:
              errorMsg = 'Request timeout';
              break;
            case DioExceptionType.receiveTimeout:
              errorMsg = 'Request timeout';
              break;
            default:
              errorMsg = 'Request err';
              break;
          }
        }

        final resp = Response<Json>(
          requestOptions: e.requestOptions,
          data: ResponseModel(
            msg: errorMsg,
            code: code ?? e.response?.statusCode ?? -1,
          ).toJson(),
        );

        handler.resolve(resp);
      },
    );
  }

  // 需要的时候调用取消
  static cancelRequest() {
    cancelToken.cancel("cancel");
  }
}
