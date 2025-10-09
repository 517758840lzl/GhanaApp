import 'package:get/get.dart';
import 'package:flutter3APP/basa/face/andriod_fase_server.dart';
import 'package:flutter3APP/common/web/web_view_page.dart';

import 'package:flutter3APP/views/borrowMoney/borrow_page.dart';
import 'package:flutter3APP/views/borrowMoney/detail/loan_detail_page.dart';
import 'package:flutter3APP/views/borrowMoney/success/loan_result_page.dart';

import 'package:flutter3APP/views/kyc/camera/camera_screen.dart';
import 'package:flutter3APP/views/login/login_page.dart';
import 'package:flutter3APP/views/me/customerService/customer_service_page.dart';
import 'package:flutter3APP/views/repayMoney/multipleRepayments/all_repayment_submit_page.dart';

import '../views/borrowMoney/contract/loan_contract_view.dart';
import '../views/home_page.dart';
import '../views/kyc/kyc_step_page.dart';
import '../views/me/my_page.dart';
import '../views/repayMoney/extension/extension_request_page.dart';
import '../views/repayMoney/repayment_page.dart';
import '../views/repayMoney/singleRepayment/repayment_submit_page.dart';
import '../views/me/bank/bank_card_list_page.dart';
import '../views/me/bank/edit/bank_card_form_page.dart';
import '../views/me/order/history_page.dart';
import '../views/me/person/person_information_page.dart';
import '../views/me/privacy/privacy_page.dart';

import '../views/me/privacy/privacy_policy_web_view_page.dart';
import '../views/me/coupon/coupon_list_page.dart';
import '../views/license/license_page.dart';
import '../views/borrowMoney/detail/loan_application_detail_page.dart';

class Routes {
  static String login = '/login';
  static String home = '/home';
  static String borrowPage = '/borrowPage';
  static String repayment = '/repayment';
  static String repaymentSubmit = '/repaymentSubmit';
  static String repaymentAllSubmit = '/repaymentAllSubmit';
  static String profile = '/profile';
  static String kyc = '/kyc';
  static String reject = '/reject';
  static String bankCardList = '/bankCardList';
  static String bankCardForm = '/bankCardForm';
  static String history = '/history';
  static String loanConfirm = '/loanConfirm';
  static String loanResult = '/loanResult';
  static String personInfo = '/personInfo';
  static String privacy = '/privacy';
  static String webView = '/webView';
  static String andriodfaceDetectionScreen = '/faceDetectionScreen';
  static String faceLiveness = '/faceLiveness';
  static String imageUpload = '/imageUpload';

  static String cameraScreen = '/cameraScreen';
  static String loanContract = '/loanContract';
  static String loanApplication = '/loanApplication';
  static String extensionRequest = '/extensionRequest';
  static String privacyPolicy = '/privacyPolicy';
  static String contact = '/contact';
  static String couponList = '/couponList';
  static String license = '/license';
  static String loanApplicationDetail = '/loanApplicationDetail';
}

final List<GetPage> routes = [
  GetPage(
      name: Routes.login,
      page: () => LoginPage()
  ),
  GetPage(
      name: Routes.home,
      page: () => HomePage()
  ),
  GetPage(
    name: Routes.borrowPage,
    page: () => BorrowPage(), // Callback parameter required
  ),
  GetPage(name: Routes.repayment, page: () => RepaymentPage()),
  GetPage(name: Routes.repaymentSubmit, page: () => RepaymentSubmitPage()),
  GetPage(name: Routes.repaymentAllSubmit, page: () => AllRepaymentSubmitPage()),
  GetPage(name: Routes.profile, page: () => MyPage()),
  GetPage(name: Routes.kyc, page: () => KycStepPage()),
  GetPage(name: Routes.bankCardList, page: () => BankCardListPage()),
  GetPage(name: Routes.bankCardForm, page: () => BankCardFormPage()), // Parameters required
  GetPage(name: Routes.history, page: () => HistoryPage()),
  GetPage(
    name: Routes.loanConfirm,
    page: () => LoanDetailPage(), // Parameters required
  ),
  GetPage(name: Routes.loanResult, page: () => LoanResultPage()),
  GetPage(name: Routes.personInfo, page: () => PersonInformationPage()),
  GetPage(name: Routes.privacy, page: () => PrivacyPage()),
  GetPage(name: Routes.webView, page: () => WebViewPage()), // Parameters required
  GetPage(name: Routes.andriodfaceDetectionScreen, page: () => FaceDetectionScreen()),
  GetPage(name: Routes.loanContract, page: () => LoanContractPage()), // 需传递参数
  GetPage(name: Routes.extensionRequest, page: () => ExtensionRequestPage()), // 需传递参数
  GetPage(name: Routes.privacyPolicy, page: () => PrivacyPolicyPage()), // 需传递参数
  GetPage(name: Routes.contact, page: () => CustomerServicePage()),
  GetPage(name: Routes.couponList, page: () => CouponListPage()),
  GetPage(name: Routes.cameraScreen, page: () => const CameraScreen()),
  GetPage(name: Routes.license, page: () => LicensePage()),
  GetPage(name: Routes.loanApplicationDetail, page: () => LoanApplicationDetailPage()),
];
