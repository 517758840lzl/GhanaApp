import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/basa/main_constant.dart';
import 'package:flutter3APP/l10n/app_strings.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'license_controller.dart';

class LicensePage extends GetView<LicenseController> {
  LicensePage({Key? key}) : super(key: key);

  final controller = Get.put(LicenseController());

  static const double dp8 = 8.0;
  static const double dp12 = 12.0;
  static const double dp16 = 16.0;
  static const double dp20 = 20.0;
  static const double dp24 = 24.0;
  static const double dp32 = 32.0;
  static const double dp48 = 48.0;
  static const double dp56 = 56.0;
  static const double dp64 = 64.0;
  static const double sp12 = 12.0;
  static const double sp14 = 14.0;
  static const double sp16 = 16.0;
  static const double sp18 = 18.0;
  static const double sp20 = 20.0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await controller.showExitConfirmationDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            AppStrings.permissionsStatement,
            style: const TextStyle(
              color: Colors.white,
              fontSize: sp18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => controller.handleBackButtonPress(context),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [


              // Content Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.whiteBgColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(dp20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Permissions List
                        ...controller.permissions.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, String> permission = entry.value;
                          return _buildModernPermissionCard(
                            title: permission['title']!,
                            description: permission['description']!,
                            icon: _getPermissionIcon(index),
                            isLast: index == controller.permissions.length - 1,
                          );
                        }).toList(),

                        const SizedBox(height: 5),

                        // Summary Section
                        Container(
                          padding: const EdgeInsets.all(dp20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(dp16),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.primaryColor,
                                    size: dp20,
                                  ),
                                  const SizedBox(width: dp8),
                                  const Text(
                                    'Important Notice',
                                    style: TextStyle(
                                      fontSize: sp16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: dp12),
                              Text(
                                Constant.licenseSummary,
                                style: const TextStyle(
                                  fontSize: sp14,
                                  color: AppColors.textColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: dp32),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(dp20),
                decoration: const BoxDecoration(
                  color: AppColors.whiteBgColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Agree Button
                    SizedBox(
                      width: double.infinity,
                      height: dp56,
                      child: ElevatedButton(
                        onPressed:
                            () => controller.handleAgreeButtonPress(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppColors.primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(dp16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: dp20),
                            const SizedBox(width: dp8),
                            Text(
                              AppStrings.agreeButtonText,
                              style: const TextStyle(
                                fontSize: sp16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: dp12),

                    // Reject Button
                    SizedBox(
                      width: double.infinity,
                      height: dp48,
                      child: TextButton(
                        onPressed:
                            () => controller.handleRejectButtonPress(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(dp16),
                            side: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.close, size: dp16),
                            const SizedBox(width: dp8),
                            Text(
                              AppStrings.rejection,
                              style: const TextStyle(
                                fontSize: sp14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernPermissionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isLast,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 5),
      padding: const EdgeInsets.all(dp20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(dp16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(dp12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(dp12),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: dp24),
              ),
              const SizedBox(width: dp16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: sp16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: dp16),
          Text(
            description,
            style: const TextStyle(
              fontSize: sp14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPermissionIcon(int index) {
    switch (index) {
      case 0: // Location
        return Icons.location_on_outlined;
      case 1: // Camera
        return Icons.camera_alt_outlined;
      case 2: // Phone
        return Icons.phone_android_outlined;
      case 3: // In-app
        return Icons.analytics_outlined;
      default:
        return Icons.security_outlined;
    }
  }
}
