import 'package:get/get.dart';
import '../../../models/coupon.dart';
import '../../../http/api_urls.dart';
import '../../../common/toast.dart';
import '../../../l10n/app_strings.dart';

class CouponListController extends GetxController {
  final couponList = <CouponInfo>[].obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCouponList();
  }

  /// 获取优惠券列表
  Future<void> fetchCouponList() async {
    YDToast.loading();
    try {
      final resp = await ApiUrls.PostCouponAllList();
      YDToast.cleanAll();
      if (resp.isSucceed && resp.data != null) {
        final data = CouponListDataMapper.fromMap(resp.data!);
        couponList.value = data.coupons;
      } else {
        YDToast.text(
          resp.msg.isNotEmpty ? resp.msg : AppStrings.errorLoadingData,
        );
      }
    } catch (e) {
      YDToast.text(AppStrings.errorLoadingData);
    } finally {
      isRefreshing.value = false;
    }
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    isRefreshing.value = true;
    await fetchCouponList();
  }

  /// 获取优惠券状态文本
  String getCouponStatusText(CouponInfo coupon) {
    switch (coupon.status) {
      case -1:
        return AppStrings.expired;
      case 0:
        return AppStrings.available;
      case 1:
        return AppStrings.used;
      case 2:
        return AppStrings.notYetAvailable;
      case 3:
        return AppStrings.unavailable;
      default:
        return AppStrings.unknown;
    }
  }

  /// 获取优惠券状态颜色
  int getCouponStatusColor(CouponInfo coupon) {
    switch (coupon.status) {
      case 0:
        return 0xFF4CAF50; // 绿色 - 可用
      case 1:
        return 0xFF9E9E9E; // 灰色 - 已使用
      case -1:
        return 0xFFF44336; // 红色 - 过期
      case 2:
        return 0xFFFF9800; // 橙色 - 未到时间
      case 3:
        return 0xFF607D8B; // 蓝灰色 - 不可用
      default:
        return 0xFF9E9E9E; // 灰色 - 未知
    }
  }

  /// 获取优惠券类型文本
  String getCouponTypeText(CouponInfo coupon) {
    switch (coupon.type) {
      case 'PRE':
        return AppStrings.Loan;
      case 'POST':
        return AppStrings.repayment;
      default:
        return AppStrings.unknown;
    }
  }

  /// 格式化有效期
  String formatValidDate(CouponInfo coupon) {
    int normalizeToMillis(int ts) {
      // 小于 1e12 视为秒，需要转毫秒；否则按毫秒处理
      return ts < 1000000000000 ? ts * 1000 : ts;
    }

    final fromMillis = normalizeToMillis(coupon.validFrom);
    final toMillis = normalizeToMillis(coupon.validTo);

    // 后端常用 UTC 时间戳，这里统一按 UTC 解析并转本地，避免时区偏移导致日期不准
    final validFrom = DateTime.fromMillisecondsSinceEpoch(
      fromMillis,
      isUtc: true,
    ).toLocal();
    final validTo = DateTime.fromMillisecondsSinceEpoch(
      toMillis,
      isUtc: true,
    ).toLocal();

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return '${fmt(validFrom)} ~ ${fmt(validTo)}';
  }
}
