import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class CameraScreenController extends GetxController {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;

  // 响应式变量
  final RxBool isInitializing = true.obs;
  final RxBool isCapturing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool showTips = true.obs;

  final frameWidth = 320.0;
  final frameHeight = 230.0;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      isInitializing.value = true;
      hasError.value = false;
      
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        hasError.value = true;
        errorMessage.value = 'noCamerasFound'.tr;
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _cameraController!.initialize().then((_) {
        isInitializing.value = false;
        showTips.value = true;
      }).catchError((error) {
        hasError.value = true;
        errorMessage.value = 'errorInitializingCamera'.tr;
        isInitializing.value = false;
      });
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'errorInitializingCamera'.tr;
      isInitializing.value = false;
    }
  }

  Future<void> captureImage() async {
    if (isCapturing.value || _cameraController == null) return;
    
    try {
      isCapturing.value = true;
      await _initializeControllerFuture;
      
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();
      final croppedBytes = cropImageAccurate(bytes);
      
      Get.back(result: croppedBytes);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'errorTakingPhoto'.tr;
    } finally {
      isCapturing.value = false;
    }
  }

  void switchCamera() async {
    if (_cameraController == null) return;
    
    try {
      final cameras = await availableCameras();
      if (cameras.length < 2) return;
      
      final currentIndex = cameras.indexWhere((camera) => camera.name == _cameraController!.description.name);
      final nextIndex = (currentIndex + 1) % cameras.length;
      
      await _cameraController!.dispose();
      
      _cameraController = CameraController(
        cameras[nextIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      _initializeControllerFuture = _cameraController!.initialize().then((_) {
        update();
      });
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'errorInitializingCamera'.tr;
    }
  }

  void hideTips() {
    showTips.value = false;
  }

  void retry() {
    _initializeCamera();
  }

  Uint8List cropImageAccurate(Uint8List bytes) {
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;

    int imageW = image.width;
    int imageH = image.height;

    final previewSize = _cameraController!.value.previewSize!;
    double previewW = previewSize.width;
    double previewH = previewSize.height;

    // 将原图旋转为竖屏
    img.Image fixedImage = image;
    if (imageW > imageH) {
      fixedImage = img.copyRotate(image, angle: 90);
      imageW = fixedImage.width;
      imageH = fixedImage.height;
    }

    // 框在屏幕上的大小
    final double frameW = frameWidth;
    final double frameH = frameHeight;

    // 计算预览在框内的实际显示尺寸（保持宽高比）
    double displayW, displayH;
    if (previewW / previewH > frameW / frameH) {
      displayW = frameW;
      displayH = frameW * previewH / previewW;
    } else {
      displayH = frameH;
      displayW = frameH * previewW / previewH;
    }

    // 计算预览在框内的偏移量（居中显示）
    final double offsetX = (frameW - displayW) / 2;
    final double offsetY = (frameH - displayH) / 2;

    // 计算框内可见区域在原图中的映射
    final double visibleLeftRatio = offsetX / frameW;
    final double visibleTopRatio = offsetY / frameH;
    final double visibleWidthRatio = displayW / frameW;
    final double visibleHeightRatio = displayH / frameH;

    // 转换为原图坐标
    int cropX = (visibleLeftRatio * imageW).round();
    int cropY = (visibleTopRatio * imageH).round();
    int cropWidth = (visibleWidthRatio * imageW).round();
    int cropHeight = (visibleHeightRatio * imageH).round();

    // 修正：由于预览是横向的，但原图是竖向的，需要调整高度计算
    final double previewAspectRatio = previewW / previewH;
    final double frameAspectRatio = frameW / frameH;

    // 重新计算裁剪区域
    if (previewAspectRatio > frameAspectRatio) {
      cropWidth = imageW;
      cropHeight = (imageW / frameAspectRatio).round();
      cropX = 0;
      cropY = (imageH - cropHeight) ~/ 2;
    } else {
      cropHeight = imageH;
      cropWidth = (imageH * frameAspectRatio).round();
      cropY = 0;
      cropX = (imageW - cropWidth) ~/ 2;
    }

    // 防越界
    cropX = cropX.clamp(0, imageW - 1);
    cropY = cropY.clamp(0, imageH - 1);
    cropWidth = cropWidth.clamp(1, imageW - cropX);
    cropHeight = cropHeight.clamp(1, imageH - cropY);

    final cropped = img.copyCrop(
      fixedImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    return Uint8List.fromList(img.encodeJpg(cropped));
  }

  Widget buildCameraPreview() {
    if (_cameraController == null) return const SizedBox();
    Widget preview = CameraPreview(_cameraController!);

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _cameraController!.value.previewSize!.height,
        height: _cameraController!.value.previewSize!.width,
        child: preview,
      ),
    );
  }

  @override
  void onClose() {
    _cameraController?.dispose();
    super.onClose();
  }
}
