import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../basa/main_constant.dart';
import '../../../common/colors/app_colors.dart';
import 'person_information_controller.dart';

//关于我们的页面
class PersonInformationPage extends StatelessWidget {
  const PersonInformationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PersonInformationController controller = Get.put(
      PersonInformationController(),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('about'.tr),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 头部应用信息区域
            _buildAppInfoSection(controller),
            const SizedBox(height: 12),

            // 应用管理区域
            _buildAppManagementSection(controller),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 应用信息区域
  Widget _buildAppInfoSection(PersonInformationController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // 应用图标
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/logo_app.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 应用名称
          Text(
            Constant.APP_NAME,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          // 版本号
          Obx(
            () => Text(
              '${'version'.tr} ${controller.version.value} (${controller.build_number.value})',
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // 应用管理区域
  Widget _buildAppManagementSection(PersonInformationController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(kDebugMode)
          _buildInfoItem(
            icon: Icons.language,
            title: 'language'.tr,
            subtitle: 'languageDescription'.tr,
            onTap: () => _showLanguageDialog(controller),
          ),
          _buildInfoItem(
            icon: Icons.storage,
            title: 'clearCache'.tr,
            subtitle: 'clearCacheDescription'.tr,
            onTap: controller.clearData,
          ),
          _buildInfoItem(
            icon: Icons.delete_forever,
            title: 'deleteAccount'.tr,
            subtitle: 'deleteAccountDescription'.tr,
            onTap: () => controller.showDeleteAccountDialog(Get.context!),
            showDivider: false,
            textColor: const Color(0xFFFF4757),
          ),
        ],
      ),
    );
  }

  // 信息项组件
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
    Color? textColor,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 18, color: AppColors.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor ?? const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFFCCCCCC),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.only(left: 60),
            height: 0.5,
            color: const Color(0xFFF0F0F0),
          ),
      ],
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(PersonInformationController controller) {
    final currentLanguage = Get.locale?.languageCode ?? 'en';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Text(
                  'language'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              // 语言选项列表
              Column(
                children: [
                  _buildLanguageOption(
                    title: 'english'.tr,
                    isSelected: currentLanguage == 'en',
                    onTap: () async {
                      await controller.switchToEnglish();
                      Get.back();
                    },
                  ),
                  Container(
                    height: 0.5,
                    color: const Color(0xFFF0F0F0),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  _buildLanguageOption(
                    title: 'spanish'.tr,
                    isSelected: currentLanguage == 'es',
                    onTap: () async {
                      await controller.switchToSpanish();
                      Get.back();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// 构建语言选项
  Widget _buildLanguageOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, color: Color(0xFF007AFF), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
