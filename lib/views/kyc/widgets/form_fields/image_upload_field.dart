import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../common/colors/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../../kyc_step_controller.dart';

class ImageUploadField extends StatelessWidget {
  final String label;
  final String code;
  final String defaultText;
  final KycStepController controller;

  const ImageUploadField({
    Key? key,
    required this.label,
    required this.code,
    required this.defaultText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String type = (code == '40007') ? 'FRONT' : 'BACK';
    String imageUrl = controller.stepData[code] ?? '';
    if (code == "40007") {
      //身份证
      imageUrl = controller.cardImage.value;
    }
    if (code == "40008") {
      //身份证
      imageUrl = controller.cardBackImage.value;
    }
    bool isValidValue = imageUrl.isNotEmpty;
    bool hasError = controller.isSubmitted.value && !isValidValue;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            AppEventTracker.instance.startInteraction(
              controller.currentStep.value,
              code,
              label,
            );
            await controller.toImageClick(
              type,
              code,
              controller.currentStep.value,
            );

            AppEventTracker.instance.endInteraction(
              controller.currentStep.value,
              code,
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                // 状态指示和标题
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: hasError
                            ? Colors.red[100]
                            : isValidValue
                            ? Colors.green[100]
                            : AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        hasError
                            ? Icons.error_outline
                            : isValidValue
                            ? Icons.check_circle
                            : Icons.photo_camera,
                        color: hasError
                            ? Colors.red[600]
                            : isValidValue
                            ? Colors.green[600]
                            : AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: hasError
                                  ? Colors.red[800]
                                  : isValidValue
                                  ? Colors.green[800]
                                  : Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            hasError
                                ? (defaultText.isEmpty
                                      ? AppStrings.uploadIdPhoto
                                      : defaultText)
                                : isValidValue
                                ? AppStrings.uploadCompleted
                                : defaultText,
                            style: TextStyle(
                              fontSize: 14,
                              color: hasError
                                  ? Colors.red[600]
                                  : isValidValue
                                  ? Colors.green[600]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isValidValue)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppStrings.done,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 20),

                // 图片预览区域
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasError
                          ? Colors.red[200]!
                          : isValidValue
                          ? Colors.green[200]!
                          : Colors.grey[200]!,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: isValidValue
                        ? (imageUrl.contains("http")
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey[100],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppColors.primaryColor),
                                                  strokeWidth: 3,
                                                ),
                                                SizedBox(height: 12),
                                                Text(
                                                  AppStrings.loading,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.red[50],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red[400],
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              AppStrings.failedToLoadImage,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Image.file(File(imageUrl), fit: BoxFit.cover))
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.grey[100]!, Colors.grey[200]!],
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 背景示例图片
                                Positioned.fill(
                                  child: Image.asset(
                                    code == '40008'
                                        ? 'assets/images/card_id_back.webp'
                                        : 'assets/images/card_id_front.webp',
                                    fit: BoxFit.fill,
                                    opacity: AlwaysStoppedAnimation(0.7),
                                  ),
                                ),
                                // 上传提示
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.cloud_upload_outlined,
                                        color: AppColors.primaryColor,
                                        size: 32,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      AppStrings.uploadPhoto,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      AppStrings.tapToSelectFromGalleryOrCamera,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
