import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/colors/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../basa/analytics/app_event_tracker.dart';

class ImageSourceBottomSheet {
  /// Show image selection bottom sheet
  /// [type] Image type (FRONT/BACK)
  /// [code] Field code
  /// [step] Current step
  /// [onGallerySelected] Gallery selection callback
  /// [onCameraSelected] Camera selection callback
  static Future<void> show({
    required String type,
    required String code,
    required int step,
    required VoidCallback onGallerySelected,
    required VoidCallback onCameraSelected,
  }) async {
    await Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Text(
                  AppStrings.pleaseSelect,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppStrings.chooseHowToUploadImage,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Option buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Gallery selection
                    _buildOptionButton(
                      icon: Icons.photo_library_outlined,
                      title: AppStrings.uploadFromGallery,
                      subtitle: AppStrings.selectFromGallery,
                      onTap: () {
                        AppEventTracker.instance.selectInteraction(
                          step,
                          code,
                          1,
                        );
                        Get.back();
                        onGallerySelected();
                      },
                    ),

                    SizedBox(height: 16),

                    // Camera capture
                    _buildOptionButton(
                      icon: Icons.camera_alt_outlined,
                      title: AppStrings.takePhoto,
                      subtitle: AppStrings.takePhotoWithCamera,
                      onTap: () {
                        AppEventTracker.instance.selectInteraction(
                          step,
                          code,
                          2,
                        );
                        Get.back();
                        onCameraSelected();
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Cancel button
              Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  /// Build option button
  static Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),

              SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
