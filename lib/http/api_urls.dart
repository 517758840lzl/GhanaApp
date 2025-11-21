import 'package:flutter3APP/http/headers/request_headers.dart';
import 'package:flutter3APP/http/reponse/common_response.dart';
import 'package:flutter3APP/http/reponse/response.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile;

import '../basa/main_constant.dart';
import 'http.dart';
import '../../models/acquisition.dart';

class ApiUrls {
  // 用户相关
  static const String checkACPElementinfoUrl =
      "/api/user/acquisition/acpElementInfo"; // 原: /api/user/acquisition/acpElementInfo
  static const String getApplyRouter =
      "/api/user/acquisition/queryAcquisitionProgress"; // 原: /api/user/acquisition/queryAcquisitionProgress
  static const String submitAcpInfoUrl =
      "/api/user/acquisition/submitAcpInfo"; // 原: /api/user/acquisition/submitAcpInfo
  static const String getBankListUrl =
      "/api/user/acquisition/queryBankList"; // 原: /api/user/acquisition/queryBankList
  static const String getUserInformationUrl =
      "/api/user/userInfo"; // 原: /api/user/userInfo
  static const String deleteAccountUrl =
      "/api/user/logout"; // 原: /api/user/logout
  static const String sendVerifyCode =
      "/api/user/sendVerifyCode"; // 原: /api/user/sendVerifyCode
  static const String userlogin = "/api/user/login"; // 原: /api/user/login
  static const String getKYCData =
      "/api/user/acquisition/queryAcqInfo"; // 原: /api/user/acquisition/queryAcqInfo

  // 银行卡相关

  // 获取用户银行卡列表
  static const String getBankCardListUrl =
      "/api/user/acquisition/queryUserBankCardList"; // 原: /api/user/acquisition/queryUserBankCardList
  // 设置默认银行卡
  static const String setDefaultBankCard =
      "/api/user/acquisition/setDefaultBankAccount"; // 原: /api/user/acquisition/setDefaultBankAccount
  // 更新银行卡
  static const String editBank =
      "/api/user/acquisition/updateBankCardInfo"; // 原: /api/user/acquisition/updateBankCardInfo
  // 保存银行卡
  static const String addBankInfoUrl =
      "/api/user/acquisition/saveBankCardInfo"; // 原: /api/user/acquisition/saveBankCardInfo
  // 确认更换银行卡
  static const String confirmChangeBank =
      "/api/order/loanOrder/confirmChangeBank"; // 原: /api/order/loanOrder/confirmChangeBank

  // 首页相关
  static const String getHomeMessageList =
      "/api/common/messages"; // 原: /api/common/messages
  static const String getBannerUrl = "/api/banner/list"; // 原: /api/banner/list
  static const String getHomeV4 = "/api/v4/home"; // 原: /api/v4/home
  static const String getHomeRetryConfig =
      "/api/home/retryConfig"; // 原: /api/home/retryConfig
  static const String rejectInfoUrl =
      "/api/order/loanOrder/rejectInfo"; // 原: /api/order/loanOrder/rejectInfo

  // 文件上传
  static const String uploadImage =
      "/api/common/uploadFile"; // 原: /api/common/uploadFile
  static const String UPLOAD_DATA =
      "/api/upload/data/submitUserUploadData"; // 原: /api/upload/data/submitUserUploadData
  static const String CHECK_UPLOAD_VALID =
      "/api/upload/data/checkUploadDataValid"; // 原: /api/upload/data/checkUploadDataValid

  // 其他
  static const String getPCADataUrl =
      "/api/common/provincesCitiesArea"; // 原: /api/common/provincesCitiesArea
  static const String ocrIdentification =
      "/api/user/acquisition/ocrVerification"; // 原: /api/user/acquisition/ocrVerification
  static const String faceDetection =
      "/api/user/acquisition/checkFace"; // 原: /api/user/acquisition/checkFace

  static const String userRepayment =
      "/api/order/loanOrder/userRepayment"; // 原: /api/order/loanOrder/userRepayment
  static const String lockGroupOrder =
      "/api/order/loanOrder/lockGroupOrder"; // 原: /api/order/loanOrder/lockGroupOrder
  static const String confirmUserApplyAmountUrl =
      "/api/order/loanOrder/confirmUserApplyAmountInfo"; // 原: /api/order/loanOrder/confirmUserApplyAmountInfo   // 额度确认
  static const String billDetail =
      "/api/order/loanOrder/api/order/billDetails"; // 原: /api/order/loanOrder/api/order/billDetails
  static const String channelList =
      "/api/order/loanOrder/channelList"; // 原: /api/order/loanOrder/channelList
  static const String generatesUrl =
      "/api/order/loanOrder/generatesUrl"; // 原: /api/order/loanOrder/generatesUrl//还款确认接口
  static const String confirmOrderUrl =
      "/api/order/loanOrder/confirmOrder"; // 原: /api/order/loanOrder/confirmOrder
  static const String applyExtensionUrl =
      "/api/order/loanOrder/api/order/extension"; // 原: /api/order/loanOrder/api/order/extension
  static const String getCustomerUrl =
      "/api/appExtraInfo/customerServiceInfo"; // 原: /api/appExtraInfo/customerServiceInfo
  static const String getCouponList =
      "/api/customer/coupon/v2/list"; // 原: /api/customer/coupon/v2/list  // 获取优惠券列表
  static const String calculatedAmountaUrl =
      "/api/customer/coupon/pre/use"; // 原: /api/customer/coupon/pre/use  // 计算优惠券借款金额
  static const String calculatePostAmount =
      "/api/customer/coupon/post/use"; // 原: /api/customer/coupon/post/use  // 计算贷后使用优惠券金额
  static const String getAppSystemConfig =
      "/api/common/startup/config"; // 原: /api/common/startup/config   // 获取系统配置接口
  static const String cancelAutoOrder =
      "/api/order/loanOrder/removeAutoLoan"; // 原: /api/order/loanOrder/removeAutoLoan   // 取消自动放款
  static const String removeCountDownTime =
      "/api/order/loanOrder/removeLoanCountDown"; // 原: /api/order/loanOrder/removeLoanCountDown   // 删除倒计时，关单
  static const String getRejectInfo =
      "/api/order/loanOrder/rejectInfo"; // 原: /api/order/loanOrder/rejectInfo   // 获取拒绝信息
  static const String getAppUpgradeConfig =
      "/api/common/appVersion"; // 原: /api/common/appVersion  // 获取APP升级配置
  static const String getPopDialogConfig =
      "/api/common/pop/config"; // 原: /api/common/pop/config   // 获取弹窗配置
  static const String getSettledOrderList =
      "/api/contract/settled/list"; // 原: /api/contract/settled/list   // 获取已结算订单列表

  static const String faceCompareUrl =
      "/api/user/acquisition/checkFace"; // 原: /api/user/acquisition/checkFace
  static const String ocrUrl =
      "/api/user/acquisition/ocrVerification"; //原: /api/user/acquisition/ocrVerification
  static const String userSignOut =
      "/api/user/signOut"; //  原:  /api/user/signOut
  static const String getRePopDialogConfig =
      "/api/common/pop/config"; // 原: /api/common/pop/config

  static const String postSysmetaEvents =
      "/api/common/event"; //原  /api/common/event,
  static const String getCouponAllList =
      "/api/customer/coupon/list/all"; // 原: /api/customer/coupon/list/all  // 获取所有优惠券列表

  //获取验证码
  static Future<ResponseModel<RawResponseModel>> postSendVerifyCode({
    required String type,
    required String phone,
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.sendVerifyCode,
      body: {'type': type, 'phone': phone},
    );
  }

  // 登录/注册
  static Future<ResponseModel<RawResponseModel>> postLoginOrRegister({
    required String phone,
    required String authCode,
    int onlyLogin = 0,
    String? countryCode,
  }) async {
    countryCode ??= Constant.COUNTRY_CODES.first;
    final deviceInfo = await RequestHeaders.getDeviceInfo();
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.userlogin,
      body: {
        'authCode': authCode,
        'onlyLogin': onlyLogin,
        'phone': '$countryCode|$phone',
        ...deviceInfo,
      },
    );
  }

  // 上传图片
  static Future<ResponseModel<RawResponseModel>> postUploadImage({
    required FormData formData,
    String urlParameters = "",
    Map<String, dynamic>? headers,
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.uploadImage + urlParameters,
      body: formData,
      headers: headers,
      encryption: false,
    );
  }

  // 上传图片进行ocr识别
  static Future<ResponseModel<RawResponseModel>> postOcrIdentification({
    required FormData formData,
    String urlParameters = "",
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      headers: await RequestHeaders.commonFileUploadHeaders(encryption: false),
      url: ApiUrls.ocrIdentification + urlParameters,
      body: formData,
      encryption: false,
    );
  }

  // 上传用户数据,不加密
  static Future<ResponseModel<RawResponseModel>> submitUserUploadData({
    required Map<String, dynamic> data,
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      headers: await RequestHeaders.commonAppJsonHeaders(encryption: false),
      encryption: false,
      url: ApiUrls.UPLOAD_DATA,
      body: data,
    );
  }

  // 获取进度
  static Future<ResponseModel<AcquisitionProgressData>>
  getAcquisitionProgress() async {
    return await HttpUtil.fetchModel<AcquisitionProgressData>(
      FetchType.get,
      url: ApiUrls.getApplyRouter,
    );
  }

  // 获取客服信息
  static Future<ResponseModel<RawResponseModel>>
  getCustomerServiceInfo() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getCustomerUrl,
    );
  }

  // 获取银行卡列表
  static Future<ResponseModel<RawResponseModel>> getBankCardList() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getBankCardListUrl,
    );
  }

  // 获取银行列表
  static Future<ResponseModel<RawResponseModel>> getBankList() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getBankListUrl,
    );
  }

  // 获取KYC进度
  static Future<ResponseModel<RawResponseModel>>
  getAcquisitionProgressRaw() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getApplyRouter,
    );
  }

  // 获取KYC步骤元素
  static Future<ResponseModel<RawResponseModel>> getStepElements({
    required int step,
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.checkACPElementinfoUrl,
      queryParameters: {'step': step},
    );
  }

  // 提交KYC步骤数据
  static Future<ResponseModel<RawResponseModel>> submitStepData({
    required Map<String, dynamic> data,
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.submitAcpInfoUrl,
      body: data,
    );
  }

  // 获取省市数据
  static Future<ResponseModel<RawResponseModel>> getProvincesCities() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getPCADataUrl,
    );
  }

  // 新增银行卡
  static Future<ResponseModel<RawResponseModel>> addBankCardInfo({
    required String bankCardNo,
    required String bankId,
    required String bankType,
  }) async {
    final postData = {
      "bankCardNo": bankCardNo,
      "bankId": bankId,
      "bankType": bankType,
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.addBankInfoUrl,
      body: postData,
    );
  }

  // 修改银行卡
  static Future<ResponseModel<RawResponseModel>> updateBankCardInfo({
    required String bankCardNo,
    required String bankId,
    required String bankType,
    required int id,
  }) async {
    final postData = {
      "bankCardNo": bankCardNo,
      "bankId": bankId,
      "bankType": bankType,
      "id": id,
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.editBank,
      body: postData,
    );
  }

  // 获取还款数据
  static Future<ResponseModel<RawResponseModel>> fetchRepaymentData() async {
    final data = {
      "statusList": ["4"],
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.userRepayment,
      body: data,
    );
  }

  // 生成还款码
  static Future<ResponseModel<RawResponseModel>> generateRepaymentUrl({
    required List<Map<String, dynamic>> allocations,
    List<int> couponIds = const [],
    required int orderType,
    required num originalTotalRepayAmount,
    required num repayAmount,
  }) async {
    final data = {
      "allocations": allocations,
      "couponIds": couponIds,
      "orderType": orderType,
      "originalTotalRepayAmount": originalTotalRepayAmount,
      "repayAmount": repayAmount,
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.generatesUrl,
      body: data,
    );
  }

  // 用户登出
  static Future<ResponseModel<RawResponseModel>> userSignOutRequest({
    required String phone,
  }) async {
    final postData = {"type": "phone", "phone": phone};
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.userSignOut,
      body: postData,
    );
  }

  // 删除账号
  static Future<ResponseModel<RawResponseModel>> deleteAccount() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.deleteAccountUrl,
    );
  }

  // 申请展期
  static Future<ResponseModel<RawResponseModel>> applyExtension({
    required int installmentId,
    List<String>? couponIds,
  }) async {
    final data = {"installmentId": installmentId, "couponIds": couponIds ?? []};
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.applyExtensionUrl,
      body: data,
    );
  }

  // 获取历史订单
  static Future<ResponseModel<RawResponseModel>> fetchOrderHistory({
    List<int>? statusList,
  }) async {
    final body = {"statusList": statusList ?? []};
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.userRepayment,
      body: body,
    );
  }

  // 结账订单
  static Future<ResponseModel<RawResponseModel>> checkoutOrderRequest({
    required int pageIndex,
  }) async {
    final queryParameters = {'pageIndex': pageIndex};
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getSettledOrderList,
      queryParameters: queryParameters,
    );
  }

  // 取消倒计时
  static Future<ResponseModel<RawResponseModel>> removeLoanCountDown({
    required String appOrderId,
  }) async {
    final body = {
      "appOrderIds": [appOrderId],
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.removeCountDownTime,
      body: body,
    );
  }

  // 获取用户信息
  static Future<ResponseModel<RawResponseModel>> getUserInformation() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getUserInformationUrl,
    );
  }

  // 设置默认银行卡
  static Future<ResponseModel<RawResponseModel>> setDefaultBankCardRequest({
    required int cardId,
  }) async {
    final postData = {'id': cardId};
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.setDefaultBankCard,
      body: postData,
    );
  }

  // 计算贷前使用优惠券金额
  static Future<ResponseModel<RawResponseModel>> calculatePreLoanCoupon({
    List<int>? appOrderIds,
    List<int>? couponIds,
    List<String>? productCodes,
  }) async {
    final data = {
      'appOrderIds': appOrderIds ?? [],
      'couponIds': couponIds ?? [],
      'productCodes': productCodes ?? [],
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.calculatedAmountaUrl,
      body: data,
    );
  }

  // 计算贷后使用优惠券金额
  static Future<ResponseModel<RawResponseModel>> calculatePostLoanCoupon({
    List<String>? appOrderIds,
    List<int>? couponIds,
    List<String>? productCodes,
    List<int>? installmentId,
  }) async {
    final data = {
      'appOrderIds': appOrderIds ?? [],
      'couponIds': couponIds ?? [],
      'productCodes': productCodes ?? [],
      'installmentId': installmentId,
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.calculatePostAmount,
      body: data,
    );
  }

  // 人脸识别
  static Future<ResponseModel<RawResponseModel>> checkFaceRecognition({
    required bool isUpdate,
    required MultipartFile file,
    required String processId,
    required String step,
    Map<String, dynamic>? headers,
  }) async {
    final formData = FormData.fromMap({
      'multipartFile': file,
      'isUpdate': isUpdate ? '1' : '0',
      'processId': processId,
      'step': step,
    });
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.faceCompareUrl,
      body: formData,
      headers: headers,
    );
  }

  // 获取系统配置
  static Future<ResponseModel<RawResponseModel>> fetchStartupConfig() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.getAppSystemConfig,
    );
  }

  // 确认贷款额度
  static Future<ResponseModel<RawResponseModel>> confirmLoanAmount({
    required Map<String, dynamic> data,
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.confirmUserApplyAmountUrl,
      body: data,
    );
  }

  // 移除自动贷款
  static Future<ResponseModel<RawResponseModel>> removeAutoLoan({
    List<int>? appOrderIds,
    List<int>? appOrderStatus,
    List<String>? productCodes,
  }) async {
    final body = {
      "appOrderIds": appOrderIds ?? [],
      "appOrderStatus": appOrderStatus ?? [],
      "productCodes": productCodes ?? [],
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.cancelAutoOrder,
      body: body,
    );
  }

  // 提交贷款申请
  static Future<ResponseModel<RawResponseModel>> submitLoanRequest({
    required dynamic jsonBody,
  }) async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.confirmOrderUrl,
      body: jsonBody,
    );
  }

  // 获取账单详情
  static Future<ResponseModel<RawResponseModel>> fetchBillDetails({
    required List<String> orderIds,
  }) async {
    final data = {"appOrderIds": orderIds};
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.billDetail,
      body: data,
    );
  }

  // 获取优惠券列表
  static Future<ResponseModel<RawResponseModel>> getCouponListV2({
    List<String>? appOrderIds,
    String? couponType, //PRE：贷前，POST：贷后
    List<String>? productCodes,
    int? repaymentType, //还款方式。0：不限，1：全额，2：展期
  }) async {
    final postData = {
      'appOrderIds': appOrderIds ?? [],
      'couponType': couponType ?? '',
      'productCodes': productCodes ?? [],
      'repaymentType': repaymentType ?? 0,
    };
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.post,
      url: ApiUrls.getCouponList,
      body: postData,
    );
  }

  static Future<ResponseModel<RawResponseModel>> PostCouponAllList() async {
    final postData = {};
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getCouponAllList,
      body: postData,
    );
  }

  // 校验上传数据有效性
  static Future<ResponseModel<RawResponseModel>> checkDataValidity() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.CHECK_UPLOAD_VALID,
    );
  }

  // 获取进度（V2）
  static Future<ResponseModel<RawResponseModel>>
  checkAcquisitionProgressV2() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getApplyRouter,
    );
  }

  // 获取拒绝信息
  static Future<ResponseModel<RawResponseModel>> fetchRejectInfo() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.rejectInfoUrl,
    );
  }

  // 获取弹窗配置
  static Future<ResponseModel<RawResponseModel>> getPopConfig({
    int? type,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (type != null) queryParameters['type'] = type;
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getPopDialogConfig,
      queryParameters: queryParameters,
    );
  }

  // 获取首页数据
  static Future<ResponseModel<RawResponseModel>> fetchHomePageData() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getHomeV4,
    );
  }

  // 获取进件进度
  static Future<ResponseModel<RawResponseModel>>
  fetchAcquisitionProgress() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getApplyRouter,
    );
  }

  // 获取弹窗配置（type=1）
  static Future<ResponseModel<RawResponseModel>> fetchPopDialogConfig() async {
    return await HttpUtil.fetchModel<RawResponseModel>(
      FetchType.get,
      url: ApiUrls.getRePopDialogConfig,
      queryParameters: {'type': 1},
    );
  }
}
