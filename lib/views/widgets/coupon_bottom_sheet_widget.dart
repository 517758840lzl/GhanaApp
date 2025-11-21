import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/models/coupon.dart';

class CouponBottomSheetWidget {
  static void show({
    required List<CouponInfo> couponList,
    required int selectedCouponId,
    required Function(int) onCouponSelected,
    required VoidCallback onClearCoupon,
    String? title,
  }) {
    Get.bottomSheet(
      Container(
        height: Get.height/2,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖拽条
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 标题
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title ?? 'selectCoupon'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  if (selectedCouponId != 0)
                    GestureDetector(
                      onTap: onClearCoupon,
                      child: Text(
                        'cancel'.tr,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 优惠券列表
            Flexible(
              child: couponList.isEmpty
                  ? _buildNoCouponAvailable()
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: couponList.length,
                      itemBuilder: (context, index) {
                        final coupon = couponList[index];
                        return _buildCouponItem(
                          coupon,
                          selectedCouponId,
                          onCouponSelected,
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildNoCouponAvailable() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Text(
            'noAvailableCoupons'.tr,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  static Widget _buildCouponItem(
    CouponInfo coupon,
    int selectedCouponId,
    Function(int) onCouponSelected,
  ) {
    final isSelected = selectedCouponId == coupon.couponId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : const Color(0xFFE9EEF3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.05)
            : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onCouponSelected(coupon.couponId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.local_offer,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.summary,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      if (coupon.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          coupon.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
