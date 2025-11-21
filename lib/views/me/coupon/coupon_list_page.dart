import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/colors/app_colors.dart';
import '../../../models/coupon.dart';
import 'coupon_list_controller.dart';

class CouponListPage extends StatefulWidget {
  const CouponListPage({Key? key}) : super(key: key);

  @override
  State<CouponListPage> createState() => _CouponListPageState();
}

class _CouponListPageState extends State<CouponListPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponListController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('couponList'.tr),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black45,
          tabs: [
            Tab(text: 'Loan'.tr),
            Tab(text: 'repayment'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // PRE 贷前
          _buildCouponTab(controller, 'PRE'),
          // POST 贷后
          _buildCouponTab(controller, 'POST'),
        ],
      ),
    );
  }

  Widget _buildCouponTab(CouponListController controller, String type) {
    return Obx(() {
      final list = controller.couponList.where((e) => e.type == type).toList();

      return RefreshIndicator(
        onRefresh: controller.onRefresh,
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        child: list.isEmpty
            ? _buildEmptyView(type)
            : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final coupon = list[index];
                  return _buildMeituanStyleCouponCard(
                    coupon,
                    controller,
                    index,
                  );
                },
              ),
      );
    });
  }

  /// 空状态
  Widget _buildEmptyView(String type) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(Get.context!).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    'assets/images/state_empty.webp',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'noCouponsAvailable'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  type == 'PRE'
                      ? 'noLoanCouponsAvailable'.tr
                      : 'noRepaymentCouponsAvailable'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, color: Colors.black, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'pullDownToRefresh'.tr,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 现代简约风格的优惠券卡片
  Widget _buildMeituanStyleCouponCard(
    CouponInfo coupon,
    CouponListController controller,
    int index,
  ) {
    final isAvailable = coupon.status == 0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: () => _onCouponTap(coupon, controller),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable
                        ? AppColors.primaryColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 左侧优惠金额区域
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.primaryColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            coupon.type == 'PRE'
                                ? Icons.account_balance_wallet
                                : Icons.payment,
                            color: isAvailable
                                ? AppColors.primaryColor
                                : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            coupon.summary,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isAvailable
                                  ? Colors.black
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 右侧内容区域
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 标题和状态
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    coupon.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isAvailable
                                          ? const Color(0xFF333333)
                                          : Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 类型标签
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? AppColors.primaryColor.withOpacity(
                                            0.1,
                                          )
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    controller.getCouponStatusText(coupon),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isAvailable
                                          ? AppColors.primaryColor
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    controller.getCouponTypeText(coupon),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            // 描述
                            if (coupon.description.isNotEmpty) ...[
                              Text(
                                coupon.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                            ],
                            // 有效期
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    controller.formatValidDate(coupon),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 优惠券点击事件
  void _onCouponTap(CouponInfo coupon, CouponListController controller) {
    // // 添加触觉反馈
    // // HapticFeedback.lightImpact();
    //
    // // 显示优惠券详情或执行相应操作
    // if (coupon.status == 0) {
    //   // 可用优惠券，可以点击使用
    //   _showCouponDetailDialog(coupon, controller);
    // } else {
    //
    // }
  }
}
