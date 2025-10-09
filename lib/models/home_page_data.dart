import 'package:dart_mappable/dart_mappable.dart';

part 'home_page_data.mapper.dart';

/// 首页详情数据
@MappableClass()
class HomePageDetails with HomePageDetailsMappable {
  final bool? hasAvailableCoupons;

  final String? couponsTitle;
  final ConfirmData? confirmData;

  HomePageDetails({
    this.hasAvailableCoupons,
    this.couponsTitle,
    this.confirmData,
  });
}

/// 产品信息
@MappableClass()
class Product with ProductMappable {
  final int? actualToAccount;
  final String? appOrderIdStr;
  final String? appOrderId;
  final int?
  appOrderStatus; //订单状态。20:审核中，22:审核拒绝 3:放款中 4:还款中 5:放款失败未关闭 6:还款完成 结清订单 7-异常关闭
  final int? customerLevelUnlock;
  final double? dailyInterestRateFrom;
  final double? dailyInterestRateTo;
  final int? daysPerTermFrom;
  final int? daysPerTermTo;
  final String? dueDate;
  final int? loanLimitFrom;
  final int? loanLimitTo;
  final num? productAccount;
  final String? productCode;
  final int? productInterest;
  final int? productLevel;
  final String? productLogo;
  final String? productName;
  final int? productStatus; //0：可借，1：还款中，2：申请中，3：锁定中（包含不可借锁定和拒绝锁定）4拒绝中
  final int? serviceFee;
  final int? totalServiceDays;
  final int? repayAmount;
  final int? loanAmount;
  final int? receiptAmount;
  final int? interest;
  final int? term;
  final int? remainingDays;
  final String? repayDate;
  final String? repayDateStr;
  final int? repaidAmount;
  final String? bankCardNo;
  final String? bankCardName;
  final String? bankCardType;
  final bool? isExtensionSwitch;
  final String? borrowRetryDate;
  bool isSelected;

  Product({
    this.actualToAccount,
    this.appOrderIdStr,
    this.appOrderId,
    this.appOrderStatus,
    this.customerLevelUnlock,
    this.dailyInterestRateFrom,
    this.dailyInterestRateTo,
    this.daysPerTermFrom,
    this.daysPerTermTo,
    this.dueDate,
    this.loanLimitFrom,
    this.loanLimitTo,
    this.productAccount,
    this.productCode,
    this.productInterest,
    this.productLevel,
    this.productLogo,
    this.productName,
    this.productStatus,
    this.serviceFee,
    this.totalServiceDays,
    this.repayAmount,
    this.loanAmount,
    this.receiptAmount,
    this.interest,
    this.term,
    this.remainingDays,
    this.repayDate,
    this.repayDateStr,
    this.repaidAmount,
    this.bankCardNo,
    this.bankCardName,
    this.bankCardType,
    this.isExtensionSwitch,
    this.borrowRetryDate,
    this.isSelected = false,
  });
}

/// 确认数据
@MappableClass()
class ConfirmData with ConfirmDataMappable {
  final int? actualToAccountMoney;
  final String? autoConfirmTips;
  final int? autoLoan;
  final int? bankCardId;
  final String? bankCardName;
  final String? bankCardNo;
  final String? bankCardType;
  final int? cancelAutoConfirmSwitch;
  final int? countDownTime;
  final int? isPopUpConfirmAutoLoan;
  final List<Product>? list;
  final int? loanAmount;
  final String? payDate;
  final int? rent;
  final String? repayDate;
  final int? serviceFee;

  ConfirmData({
    this.actualToAccountMoney,
    this.autoConfirmTips,
    this.autoLoan,
    this.bankCardId,
    this.bankCardName,
    this.bankCardNo,
    this.bankCardType,
    this.cancelAutoConfirmSwitch,
    this.countDownTime,
    this.isPopUpConfirmAutoLoan,
    this.list,
    this.loanAmount,
    this.payDate,
    this.rent,
    this.repayDate,
    this.serviceFee,
  });
}

/// 订单处理中视图数据
@MappableClass()
class OrderProcessingViewData with OrderProcessingViewDataMappable {
  final int? allLockProductAccount;
  final ConfirmData? confirmData;
  final List<Product>? lockProductList;
  final List<Order>? orderListDue;
  final List<Order>? orderListProcessing;
  final List<Order>? processingOrderList;

  OrderProcessingViewData({
    this.allLockProductAccount,
    this.confirmData,
    this.lockProductList,
    this.orderListDue,
    this.orderListProcessing,
    this.processingOrderList,
  });
}

/// 订单信息
@MappableClass()
class Order with OrderMappable {
  final String? acqChannel;
  final String? appOrderId;
  final String? bankCardName;
  final String? bankCardNo;
  final String? bankCardType;
  final int? closeTime;
  final int? countdownTime;
  final String? createTime;
  final int? interest;
  final bool? isExtensionSwitch;
  final int? loanAmount;
  final int? orderStatus;
  final String? orderStatusStr;
  final int? productLevel;
  final String? productLogo;
  final String? productName;
  final String? productSetCode;
  final int? rejectTime;
  final int? remainingDays;
  final int? repaidAmount;
  final int? repayAmount;
  final String? repayDate;
  final String? repayDateStr;
  final int? sort;
  final int? term;
  final int? totalServiceDays;
  final String? updateTime;

  Order({
    this.acqChannel,
    this.appOrderId,
    this.bankCardName,
    this.bankCardNo,
    this.bankCardType,
    this.closeTime,
    this.countdownTime,
    this.createTime,
    this.interest,
    this.isExtensionSwitch,
    this.loanAmount,
    this.orderStatus,
    this.orderStatusStr,
    this.productLevel,
    this.productLogo,
    this.productName,
    this.productSetCode,
    this.rejectTime,
    this.remainingDays,
    this.repaidAmount,
    this.repayAmount,
    this.repayDate,
    this.repayDateStr,
    this.sort,
    this.term,
    this.totalServiceDays,
    this.updateTime,
  });
}

/// 锁定组订单数据
@MappableClass()
class LockGroupOrder with LockGroupOrderMappable {
  final int? countDownTime;
  final List<LockGroupOrderItem>? list;
  final int? total;

  LockGroupOrder({this.countDownTime, this.list, this.total});
}

/// 锁定组中单个订单项
@MappableClass()
class LockGroupOrderItem with LockGroupOrderItemMappable {
  final String? appOrderId;
  final String? feeId;
  final int? loanAmount;
  final String? productCode;
  final String? productLogo;
  final String? productName;

  LockGroupOrderItem({
    this.appOrderId,
    this.feeId,
    this.loanAmount,
    this.productCode,
    this.productLogo,
    this.productName,
  });
}
