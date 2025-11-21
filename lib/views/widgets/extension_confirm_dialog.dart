import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/colors/app_colors.dart';

class ExtensionConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ExtensionConfirmDialog({
    Key? key,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: AppColors.primaryColor.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: const Icon(
            //     Icons.extension,
            //     color: AppColors.primaryColor,
            //     size: 32,
            //   ),
            // ),
            const SizedBox(height: 16),
            Image.asset(
              "assets/images/bg_extension_dialog.webp",
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              'extensionDialogTip'.tr,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: onConfirm,
                child:  Text(
                  'confirm'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onCancel,
              child:  Text(
                'cancel'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF96A0B2),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
