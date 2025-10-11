import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/colors/app_colors.dart';
import '../../../../l10n/app_strings.dart';
import '../kyc_step_controller.dart';

class KycHeaderView extends StatelessWidget {
  final KycStepController controller;

  const KycHeaderView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int currentStep = controller.filledStep.value;
      int totalStep = controller.totalStep.value;
      final currentCode =
          controller.processSteps.isNotEmpty &&
              controller.processSteps.first != null &&
              controller.processSteps.first["entries"] != null &&
              controller.processSteps.first["entries"].isNotEmpty &&
              controller.processSteps.first["entries"][0] != null
          ? (controller.processSteps.first["entries"][0]["code"] ?? "")
          : "";
      final endBool = currentCode.contains("7000");

      // 如果是最后一步，显示图片
      if (currentStep == totalStep && endBool) {
        return Container(
          width: Get.width,
          child: Image.asset(
            'assets/images/banner_kyc_completion.png',
            fit: BoxFit.cover,
          ),
        );
      }

      // 计算进度百分比
      double progress = totalStep > 0
          ? (currentStep / totalStep).clamp(0.0, 1.0)
          : 0.0;
      int progressPercentage = (progress * 100).round();

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          children: [
            // 顶部间距
            SizedBox(height: 5),

            // 进度标题
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.completionProgress,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$progressPercentage%',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5),

            // 进度条容器
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 主进度条
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Stack(
                      children: [
                        // 背景
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // 进度填充
                        AnimatedContainer(
                          duration: Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                          width:
                              MediaQuery.of(Get.context!).size.width *
                              0.9 *
                              progress,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
