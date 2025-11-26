import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/routes/routes.dart';
import '../../common/colors/app_colors.dart';

class LicenseController extends GetxController {
  // 权限数据
  List<Map<String, String>> get permissions => Platform.isIOS
      ? [
          {'title': 'locationTitle'.tr, 'description': 'locationDesc'.tr},
          {'title': 'cameraTitle'.tr, 'description': 'cameraDesc'.tr},
          {'title': 'mobileTitle'.tr, 'description': 'mobileDesc'.tr},
          {'title': 'inAppTitle'.tr, 'description': 'inAppDesc'.tr},
        ]
      : [
          {'title': 'locationTitle'.tr, 'description': 'locationDesc'.tr},
          {'title': 'cameraTitle'.tr, 'description': 'cameraDesc'.tr},
          {'title': 'smsTitle'.tr, 'description': 'smsDesc'.tr},
          {'title': 'appListTitle'.tr, 'description': 'appListDesc'.tr},
          {'title': 'mobileTitle'.tr, 'description': 'mobileDesc'.tr},
          {'title': 'inAppTitle'.tr, 'description': 'inAppDesc'.tr},
        ];

  // 显示退出确认对话框
  Future<bool> showExitConfirmationDialog(BuildContext context) async {
    final shouldExit = await Get.dialog<bool>(
      const _LicenseExitDialog(),
      barrierDismissible: false,
    );
    return shouldExit ?? false;
  }

  // 处理返回按钮点击
  Future<void> handleBackButtonPress(BuildContext context) async {
    final shouldExit = await showExitConfirmationDialog(context);
    if (shouldExit) {
      exit(0);
    }
  }

  // 处理拒绝按钮点击
  Future<void> handleRejectButtonPress(BuildContext context) async {
    final shouldExit = await showExitConfirmationDialog(context);
    if (shouldExit) {
      exit(0);
    }
  }

  // 处理同意按钮点击
  void handleAgreeButtonPress(BuildContext context) {
    Get.offAllNamed(Routes.privacy);
  }
}

/// 许可证页面退出确认对话框
class _LicenseExitDialog extends StatefulWidget {
  const _LicenseExitDialog({Key? key}) : super(key: key);

  @override
  State<_LicenseExitDialog> createState() => _LicenseExitDialogState();
}

class _LicenseExitDialogState extends State<_LicenseExitDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleButtonTap(bool shouldExit) {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      Navigator.of(context).pop(shouldExit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 图标容器
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withOpacity(0.15),
                            const Color(0xFFE6A017).withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.exit_to_app_rounded,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 标题
                    Text(
                      'exitApplication'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 内容文本
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'logoutConfirmation'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 按钮行
                    Row(
                      children: [
                        // 取消按钮
                        Expanded(
                          child: _buildButton(
                            text: 'cancel'.tr,
                            isPrimary: false,
                            onTap: () => _handleButtonTap(false),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 确认按钮
                        Expanded(
                          child: _buildButton(
                            text: 'ok'.tr,
                            isPrimary: true,
                            onTap: () => _handleButtonTap(true),
                          ),
                        ),
                      ],
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

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                colors: [AppColors.primaryColor, Color(0xFFE6A017)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isPrimary ? null : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(color: const Color(0xFFE1E5E9), width: 1.5),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : const Color(0xFF374151),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
