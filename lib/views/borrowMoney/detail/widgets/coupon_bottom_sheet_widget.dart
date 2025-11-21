import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/models/coupon.dart';
import 'package:flutter3APP/views/borrowMoney/detail/loan_detail_controller.dart';

class CouponBottomSheetWidget {
  static void show(LoanDetailController controller) {
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_offer,
                      color: Colors.orange[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'selectCoupon'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  // 取消按钮
                  Obx(() {
                    if (controller.selectedCouponId.value != 0) {
                      return GestureDetector(
                        onTap: () {
                          controller.selectedCouponId.value = 0;
                          controller.fetchConfirmationDataWithReset();
                          Get.back();
                        },
                        child: Text(
                          'delete'.tr,
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            // 优惠券列表
            Flexible(
              child: Obx(() {
                if (controller.couponList.isEmpty) {
                  return _buildNoCouponAvailable();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.couponList.length,
                  itemBuilder: (context, index) {
                    final coupon = controller.couponList[index];
                    return _buildCouponItem(coupon, controller);
                  },
                );
              }),
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
    LoanDetailController controller,
  ) {
    final isSelected = controller.selectedCouponId.value == coupon.couponId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (controller.selectedCouponId.value == coupon.couponId) {
            controller.selectedCouponId.value = 0;
          } else {
            controller.selectedCouponId.value = coupon.couponId;
          }
          controller.fetchConfirmationDataWithReset();
          Get.back(); // Close bottom sheet after selection
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.summary,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}
