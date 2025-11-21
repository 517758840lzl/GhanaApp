import 'package:flutter/material.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:get/get.dart';

/// 退出登录确认弹框
class MeituanLogoutDialog {
  /// 显示退出登录确认弹框
  static void show({
    required VoidCallback onConfirm,
    String? title,
    String? confirmText,
    String? cancelText,
  }) {
    Get.dialog(
      _buildDialog(
        title: title ?? 'areYouSureLogout'.tr,
        confirmText: confirmText ?? 'confirm'.tr,
        cancelText: cancelText ?? 'cancel'.tr,
        onConfirm: onConfirm,
      ),
      barrierDismissible: true,
    );
  }

  /// 构建弹框UI
  static Widget _buildDialog({
    required String title,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部图标区域
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 32, bottom: 16),
              child: Column(
                children: [
                  // 图标容器
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      size: 25,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 标题
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // 按钮区域
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.dividerColor, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: _buildButton(
                      text: cancelText,
                      isPrimary: false,
                      onTap: () => Get.back(),
                    ),
                  ),
                  // 分割线
                  Container(
                    height: 56,
                    width: 0.5,
                    color: AppColors.dividerColor,
                  ),
                  // 确认按钮
                  Expanded(
                    child: _buildButton(
                      text: confirmText,
                      isPrimary: true,
                      onTap: () {
                        Get.back();
                        onConfirm();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建按钮
  static Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryColor : Colors.transparent,
          borderRadius: isPrimary
              ? const BorderRadius.only(bottomRight: Radius.circular(16))
              : const BorderRadius.only(bottomLeft: Radius.circular(16)),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
