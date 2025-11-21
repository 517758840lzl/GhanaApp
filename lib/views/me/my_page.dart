import 'dart:io';

import '../../basa/country_config_helper.dart';
import '../../basa/main_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import '../../common/colors/app_colors.dart';
import '../../controllers/language_controller.dart';
import '../../provider/userDataHelper.dart';
import 'my_controller.dart';

//我的界面
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MyController controller = Get.put(MyController());
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: RefreshIndicator(
          onRefresh: () => controller.loadCachedData(),
          color: AppColors.primaryColor,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 用户信息区域
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryDarkColor,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
                      child: Column(
                        children: [
                          // 顶部操作栏
                          const SizedBox(height: 20),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.end,
                          //   children: [
                          //     Container(
                          //       height: 44,
                          //       width: 44,
                          //       decoration: BoxDecoration(
                          //         color: Colors.white.withOpacity(0.4),
                          //         borderRadius: BorderRadius.circular(22),),
                          //       child: IconButton(
                          //         icon: Image.asset(
                          //           'assets/images/icon_service_two.png',
                          //           width: 20,
                          //           height: 20,
                          //         ),
                          //         onPressed: () => Get.toNamed(Routes.contact),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // 用户信息卡片
                          Row(
                            children: [
                              // 用户头像
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Obx(
                                    () => Image.asset(
                                      controller.avatarAsset.value,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF0F0F0),
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                              child: Icon(
                                                controller.sex.value == 0
                                                    ? Icons.person
                                                    : Icons.person_outline,
                                                size: 40,
                                                color: const Color(0xFF999999),
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 用户基本信息
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 用户名称
                                    Text(
                                      controller.customerName.isNotEmpty
                                          ? controller.customerName.value
                                          : '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // 手机号
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            controller.phone.isNotEmpty
                                                ? controller.phone.value
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 0)),
              // 设置项区域
              SliverToBoxAdapter(
                child: Container(
                  // margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildMeituanSettingsItem(
                        icon: Icons.history,
                        iconColor: AppColors.primaryColor,
                        title: 'historyLabel'.tr,
                        onTap: () {
                          Get.toNamed(Routes.history);
                        },
                      ),
                      Obx(
                        () => controller.appBlackCard.value
                            ? Container(
                                child: Column(
                                  children: [
                                    _buildDivider(),
                                    _buildMeituanSettingsItem(
                                      icon: Icons.credit_card,
                                      iconColor: AppColors.accentColor,
                                      title: 'myBankCards'.tr,
                                      onTap: () {
                                        Get.toNamed(Routes.bankCardList);
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      _buildDivider(),
                      _buildMeituanSettingsItem(
                        icon: Icons.local_offer,
                        iconColor: AppColors.warning,
                        title: 'couponList'.tr,
                        onTap: () {
                          Get.toNamed(Routes.couponList);
                        },
                      ),
                      _buildDivider(),
                      _buildMeituanSettingsItem(
                        icon: Icons.chat_bubble_outline,
                        iconColor: AppColors.textSecondary,
                        title: 'Service'.tr,
                        onTap: () {
                          Get.toNamed(Routes.contact);
                        },
                      ),
                      _buildDivider(),
                      _buildMeituanSettingsItem(
                        icon: Icons.description_outlined,
                        iconColor: AppColors.textSecondary,
                        title: 'privacyPolicy'.tr,
                        onTap: () async {
                          final countryCode = await UserDataHelper.getCountry();
                          Get.toNamed(
                            Routes.privacyPolicy,
                            arguments: {
                              'url': Platform.isIOS
                                  ? CountryConfigHelper.getPrivacyPolicyUrl(
                                      countryCode,
                                    )
                                  : Constant.URL_PRIVACY_POLICY_ANDROIF,
                            },
                          );
                        },
                      ),
                      if (Platform.isIOS)
                        Container(
                          child: Column(
                            children: [
                              _buildDivider(),
                              _buildMeituanSettingsItem(
                                icon: Icons.description_outlined,
                                iconColor: AppColors.textSecondary,
                                title: 'termsOfService'.tr,
                                onTap: () async {
                                  final countryCode =
                                      await UserDataHelper.getCountry();
                                  Get.toNamed(
                                    Routes.privacyPolicy,
                                    arguments: {
                                      'url':
                                          CountryConfigHelper.getTermServiceUrl(
                                            countryCode,
                                          ),
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      _buildDivider(),
                      _buildMeituanSettingsItem(
                        icon: Icons.info_outline,
                        iconColor: AppColors.textSecondary,
                        title: 'about'.tr,
                        onTap: () {
                          Get.toNamed(Routes.personInfo);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              // 独立的退出登录按钮
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildLogoutButton(controller, context),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  // 构建设置项
  Widget _buildMeituanSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 70,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // 构建分割线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 0.5,
      color: AppColors.dividerColor,
    );
  }

  // 构建退出登录按钮
  Widget _buildLogoutButton(MyController controller, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          controller.showLogoutDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              'logOut'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
