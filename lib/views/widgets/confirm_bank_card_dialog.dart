import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/colors/app_colors.dart';

class ConfirmBankCardDialog extends StatelessWidget {
  final String? contents;
  final String? cardNo;
  final int? type;
  const ConfirmBankCardDialog({Key? key, this.cardNo, this.type, this.contents})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confirmationText = contents != null
        ? contents
        : type == 1
        ? '${'confirmRun'.tr}\n$cardNo'
        : '${'confirmBankAccount'.tr}\n$cardNo';
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        // margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Image.asset("assets/images/icon_warm.webp", width: 50, height: 50),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                confirmationText ?? "",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFF3939),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      child:  Text(
                        'cancel'.tr,
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child:  Text(
                        'confirm'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
