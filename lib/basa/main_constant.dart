class Constant {

  static const String BASE_URL = "https://www.sikaswift.pro";   //测试https://www.sikaswift.pro  本地测试:http://192.168.0.156:8091
  static const bool APP_RELEASER= false;//上架发布开关

  static const bool APP_ENCRYPTION = false;//接口加密开关 false关 true开

  static const bool APP_BLACK_CARD = false;//银行卡是否可编辑 false关 true开
  static const String COUNTRY_CODE = "233";




  static const String APP_NAME = "GhanaApp";
  static const String afDevKey = 'FYiVnBWPbxjw3HsyfqnUtL';//FYiVnBWPbxjw3HsyfqnUtL
  static const String appId = '';
  static const String DES_KEY = 'p4f8g7j1k2l9m6d0b3g7h8r5t6y2w4q';//des加密Key
  static const String URL_PRIVACY_POLICY="https://www.maximerge.finance/static/privacy-policy-ios/index.html";
  static const String URL_TERM_SERVICE="https://www.maximerge.finance/static/terms-conditions/index.html";

  static const String URL_PRIVACY_POLICY_ANDROIF="https://www.mobimeta.org/static/privacy/index.html";




//隐私协议

  static const String locationTitle = 'LOCATION DATA COLLECTION';
  static const String locationDesc = 'We collect your approximate location to verify your stated place of residence and to ensure compliance with geographic eligibility requirements. This process helps prevent fraudulent activities and ensures that loans are only granted to qualified local residents.';

  static const String cameraTitle = 'CAMERA DATA COLLECTION';
  static const String cameraDesc = 'For identity verification and information security, please allow the app to access your camera to capture documents and photographs required for loan applications.';

  static const String smsTitle = 'SMS DATA COLLECTION';
  static const String smsDesc = 'To evaluate your creditworthiness and repayment capacity, this app requires access to your SMS data (including transaction alerts, payment amounts, and other relevant financial details). We only collect finance-related information and do not read personal messages or unrelated sensitive content. All data is encrypted, used solely for fraud prevention and credit assessment, and will never be shared with unauthorized third parties. You may revoke this permission at any time via the app settings or by contacting customer support to request data deletion.';

  static const String appListTitle = 'INSTALLED APP DATA COLLECTION';
  static const String appListDesc = 'This app may request access to the list of apps installed on your device. We collect only app names, package identifiers, and update timestamps—strictly for risk evaluation and fraud prevention, never for marketing or advertising purposes. All data is transmitted securely via HTTPS and will not be disclosed to third parties. You may contact our customer support team to request data deletion, which will be processed within 7 business days.';

// Android only
  static const String mobileTitle = 'PHONE DATA COLLECTION';
  static const String mobileDesc = 'We collect certain device-specific information, such as the unique device identifier, to accurately identify each user and detect or prevent any unauthorized devices from acting on your behalf.';

  static const String inAppTitle = 'IN-APP INTERACTION DATA COLLECTION';
  static const String inAppDesc = 'We collect and share in-app user behavior data with our analytics partner, Appsflyer, to analyze how users engage with GhanaApp and to assess application performance.';

  static const String licenseSummary = 'By clicking "Accept," you authorize us to collect and synchronize your location and device data. All information will be securely transmitted and stored using modern encryption (via HTTPS) by GhanaApp. This data will never be sold but may be shared with authorized credit rating institutions.';

}
