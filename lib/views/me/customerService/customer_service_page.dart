import '../../../common/colors/app_colors.dart';
import '../../../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'customer_service_controller.dart';

class CustomerServicePage extends StatelessWidget {
  CustomerServicePage({super.key});

  final CustomerServiceController controller = Get.put(
    CustomerServiceController(),
  );
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasError.value) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppStrings.Service,
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(AppStrings.errorLoadingData),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refreshData(),
                  child: Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        );
      }

      final appCustomerServiceInfo = controller.appCustomerServiceInfo;

      return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            appCustomerServiceInfo?['title'] ?? "",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: appCustomerServiceInfo == null
            ? Center(child: Text(AppStrings.noDataAvailable))
            : CustomScrollView(
                slivers: [
                  // 顶部渐变背景区域
                  SliverToBoxAdapter(
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                appCustomerServiceInfo["desc"] ?? "",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  ),

                  // 联系方式卡片区域
                  SliverPadding(
                    padding: EdgeInsets.all(10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (appCustomerServiceInfo['accountList'] == null) {
                            return SizedBox.shrink();
                          }
                          var accountInfo =
                              appCustomerServiceInfo['accountList'][index];
                          return _buildModernContactCard(
                            accountInfo,
                            controller,
                          );
                        },
                        childCount:
                            appCustomerServiceInfo['accountList']?.length ?? 0,
                      ),
                    ),
                  ),

                  // 底部服务时间提示
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                Icons.schedule,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.customerServiceResponseTime,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  // 构建现代化联系方式卡片
  Widget _buildModernContactCard(
    Map<String, dynamic> accountInfo,
    CustomerServiceController controller,
  ) {
    int type = accountInfo['type'] ?? 0; // 1.电话 2.whatsapp 3.邮箱
    String account = accountInfo['account'] ?? '';

    // 根据类型设置图标、颜色和样式
    IconData icon;
    Color primaryColor;
    Color lightColor;
    String typeText;
    String actionText;
    VoidCallback onAction;

    switch (type) {
      case 1: // 电话
        icon = Icons.phone_android;
        primaryColor = AppColors.primaryColor;
        lightColor = AppColors.primaryColor.withOpacity(0.1);
        typeText = AppStrings.phoneSupport;
        actionText = AppStrings.callNow;
        onAction = () => controller.launchWhatsApp(account);
        break;
      case 2: // WhatsApp
        icon = Icons.chat_bubble_outline;
        primaryColor = Color(0xFF25D366);
        lightColor = Color(0xFF25D366).withOpacity(0.1);
        typeText = AppStrings.whatsappSupport;
        actionText = AppStrings.startChat;
        onAction = () => controller.launchWhatsApp(account);
        break;
      case 3: // 邮箱
        icon = Icons.email_outlined;
        primaryColor = Colors.blue;
        lightColor = Colors.blue.withOpacity(0.1);
        typeText = AppStrings.emailSupport;
        actionText = AppStrings.sendEmail;
        onAction = () => controller.launchEmail(account);
        break;
      default:
        icon = Icons.help_outline;
        primaryColor = AppColors.textSecondary;
        lightColor = AppColors.textSecondary.withOpacity(0.1);
        typeText = AppStrings.otherContact;
        actionText = AppStrings.contactSupport;
        onAction = () {};
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onAction,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部图标和类型
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: lightColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: primaryColor, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeText,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            account,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // 操作按钮区域
                Row(
                  children: [
                    // 复制按钮
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => controller.copyToClipboard(account),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.copy,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  AppStrings.copy,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // 主要操作按钮
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onAction,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(icon, size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  actionText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
