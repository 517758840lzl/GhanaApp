import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/colors/app_colors.dart';
import '../../l10n/app_strings.dart';

class ExitConfirmationDialog extends StatefulWidget {
  const ExitConfirmationDialog({Key? key}) : super(key: key);

  @override
  State<ExitConfirmationDialog> createState() => _ExitConfirmationDialogState();
}

class _ExitConfirmationDialogState extends State<ExitConfirmationDialog>
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

  void _handleButtonTap(String action) {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      Navigator.of(context).pop(action == 'confirm');
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
                    // 警告图标容器 - 增强动画效果
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B6B).withOpacity(0.1),
                            const Color(0xFFFF3939).withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: const Color(0xFFFF3939).withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF3939),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 标题 - 增强字体层次
                    Text(
                      AppStrings.exitConfirmationTitle,
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
                        AppStrings.exitConfirmationMessage,
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

                    // 按钮行 - 增强交互效果
                    Row(
                      children: [
                        // 取消按钮 - 现代化设计
                        Expanded(
                          child: _buildButton(
                            text: AppStrings.cancel,
                            isPrimary: false,
                            onTap: () => _handleButtonTap('cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 确认按钮 - 增强视觉吸引力
                        Expanded(
                          child: _buildButton(
                            text: AppStrings.confirm,
                            isPrimary: true,
                            onTap: () => _handleButtonTap('confirm'),
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
