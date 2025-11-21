import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../common/colors/app_colors.dart';
import '../../kyc_step_controller.dart';

class FaceRecognitionField extends StatelessWidget {
  final String code;
  final String label;
  final KycStepController controller;

  const FaceRecognitionField({
    Key? key,
    required this.code,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = controller.stepData[code] ?? '';
    if (code == "60002") {
      //人脸头像
      imageUrl = controller.faceImage.value;
    }

    bool hasImage = imageUrl.isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasImage
              ? AppColors.primaryColor.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: hasImage ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: hasImage
                ? AppColors.primaryColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 标题和状态指示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasImage ? Icons.check_circle : Icons.face,
                color: hasImage ? Colors.green : AppColors.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: hasImage ? Colors.green : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          SizedBox(height: 16),

          // 突出提示信息
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hasImage
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage
                    ? Colors.green.withOpacity(0.3)
                    : AppColors.primaryColor.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasImage ? Icons.check : Icons.info_outline,
                  color: hasImage ? Colors.green : AppColors.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasImage
                        ? 'faceRecognitionCompletedSuccessfully'.tr
                        : 'pleaseCompleteFaceRecognitionToContinue'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasImage
                          ? Colors.green[700]
                          : AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // 缩小的示例图片区域
          GestureDetector(
            onTap: () async {
              AppEventTracker.instance.startInteraction(
                controller.currentStep.value,
                code,
                label,
              );
              await controller.startFaceDetection(code);
              AppEventTracker.instance.endInteraction(
                controller.currentStep.value,
                code,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasImage
                      ? AppColors.primaryColor.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.3),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasImage
                        ? AppColors.primaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: hasImage
                    ? (imageUrl.contains("http")
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primaryColor,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 32,
                                );
                              },
                            )
                          : Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ))
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/bg_face.webp',
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // 操作提示
          Text(
            hasImage
                ? 'tapToRetakePhoto'.tr
                : 'tapToStartFaceRecognition'.tr,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
