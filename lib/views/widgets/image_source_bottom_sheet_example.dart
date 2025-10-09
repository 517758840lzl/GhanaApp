import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'image_source_bottom_sheet.dart';

/// 图片选择底部弹窗使用示例
class ImageSourceBottomSheetExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('图片选择底部弹窗示例')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _showImageSourceDialog(context),
              child: Text('显示图片选择弹窗'),
            ),
            SizedBox(height: 20),
            Text(
              '点击按钮体验新的底部弹窗样式',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    ImageSourceBottomSheet.show(
      type: 'FRONT',
      code: '40007',
      step: 1,
      onGallerySelected: () {
        print('用户选择了相册');
        Get.snackbar(
          '选择相册',
          '用户选择了从相册上传图片',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      onCameraSelected: () {
        print('用户选择了相机');
        Get.snackbar(
          '选择相机',
          '用户选择了使用相机拍照',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
