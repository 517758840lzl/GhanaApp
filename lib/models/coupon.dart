import 'package:dart_mappable/dart_mappable.dart';

part 'coupon.mapper.dart';

@MappableClass()
class CouponListData with CouponListDataMappable {
  final List<CouponInfo> coupons;
  final int showCouponCard;

  CouponListData({required this.coupons, required this.showCouponCard});
}

@MappableClass()
class CouponInfo with CouponInfoMappable {
  final int couponId;
  final String description; //优惠券长描述
  final int discountType; //优惠类型。0：固定金额，1：百分比
  final double discountValue; //优惠金额。（固定金额或百分比）
  final double maxDiscountValue; //最大优惠金额（优惠类型为百分比时使用）
  final double minDiscountValue; //最小优惠金额（优惠类型为百分比时使用）
  final int repaymentType; //还款方式。0：不限，1：全额，2：展期
  final int status; //状态。-1：过期，0：可使用，1：已使用，2：未到使用时间，3：因其他条件限制不可用
  final String summary;
  final String title;
  final String type; //类型。PRE：贷前，POST：贷后
  final int validFrom;
  final int validTo;

  CouponInfo({
    required this.couponId,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscountValue,
    required this.minDiscountValue,
    required this.repaymentType,
    required this.status,
    required this.summary,
    required this.title,
    required this.type,
    required this.validFrom,
    required this.validTo,
  });
}
