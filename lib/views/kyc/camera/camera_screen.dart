import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/colors/app_colors.dart';
import 'camera_controller.dart';

//拍照证件
class CameraScreen extends GetView<CameraScreenController> {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraScreenController>(
      init: CameraScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'takePhotoTitle'.tr,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // 切换相机按钮
              Obx(() {
                return controller.isInitializing.value
                    ? const SizedBox()
                    : IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                      ),
                      onPressed: controller.switchCamera,
                    );
              }),
            ],
          ),
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // 主要内容
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 相机预览区域
                    Container(
                      width: controller.frameWidth,
                      height: controller.frameHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Obx(() {
                          if (controller.isInitializing.value) {
                            return Container(
                              color: Colors.black87,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'cameraLoadingMessage'.tr,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (controller.hasError.value) {
                            return Container(
                              color: Colors.black87,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      controller.errorMessage.value,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: controller.retry,
                                      child: Text('cameraErrorRetry'.tr),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return controller.buildCameraPreview();
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 拍照按钮
                    Obx(() {
                      return controller.isCapturing.value
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          )
                          : IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 60,
                              color: Colors.white,
                            ),
                            onPressed: controller.captureImage,
                          );
                    }),
                  ],
                ),
              ),

              // 提示信息
              Obx(() {
                return controller.showTips.value
                    ? Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'cameraTipsTitle'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'cameraTipsMessage'.tr,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    )
                    : const SizedBox();
              }),
            ],
          ),
        );
      },
    );
  }
}
