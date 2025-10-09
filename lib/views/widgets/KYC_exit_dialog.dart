import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/colors/app_colors.dart';
import '../../provider/app_state.dart';
import '../../l10n/app_strings.dart';

class KYCExitDialog extends StatefulWidget {
  const KYCExitDialog({super.key});

  @override
  State<KYCExitDialog> createState() => _KYCExitDialogState();
}

class _KYCExitDialogState extends State<KYCExitDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      Navigator.of(context).pop(false);
    });
  }

  void _handleExit() {
    HapticFeedback.mediumImpact();
    _animationController.reverse().then((_) {
      Navigator.of(context).pop(false);
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        AppState.to.logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
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
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题和图标行
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 主标题
                                Text(
                                  AppStrings.exitWithoutSaving,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // 继续按钮 - 增强设计
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: _buildPrimaryButton(
                          text: AppStrings.continueText,
                          onTap: _handleContinue,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 退出按钮
                      Center(
                        child: _buildSecondaryButton(
                          text: AppStrings.noNecesitoDinero,
                          onTap: _handleExit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, const Color(0xFFE6A017)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryColor,
                decorationThickness: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
