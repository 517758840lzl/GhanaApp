import 'package:flutter/material.dart';
import 'package:flutter3APP/l10n/app_strings.dart';
import 'package:flutter3APP/routes/routes.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/views/borrowMoney/success/loan_result_controller.dart';
import 'package:get/get.dart';

//贷款成功页
class LoanResultPage extends StatefulWidget {
  LoanResultPage({Key? key}) : super(key: key);

  @override
  State<LoanResultPage> createState() => _LoanResultPageState();
}

class _LoanResultPageState extends State<LoanResultPage>
    with TickerProviderStateMixin {
  // late AnimationController _animationController;
  // late Animation<double> _fadeAnimation;
  // late Animation<Offset> _slideAnimation;

  final LoanResultController controller = Get.put(LoanResultController());
  @override
  void initState() {
    super.initState();
    // _animationController = AnimationController(
    //   duration: const Duration(milliseconds: 1200),
    //   vsync: this,
    // );

    // _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );
    //
    // _slideAnimation =
    //     Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
    //       CurvedAnimation(
    //         parent: _animationController,
    //         curve: Curves.easeOutCubic,
    //       ),
    //     );
    //
    // _animationController.forward();
  }

  @override
  void dispose() {
    // _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.9),
              AppColors.primaryColor.withOpacity(0.3),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 炫丽AppBar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () => Get.offAllNamed(Routes.home),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          AppStrings.loanResultTitle,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Container(
                        child: const Text(
                          AppStrings.applicationSuccessfulTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 成功描述
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text(
                          AppStrings.applicationSuccessfulDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 炫丽成功图片区域
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/images/banner_loan_success.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          AppStrings.reviewInformationContent,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 炫丽按钮组
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            // 返回首页按钮
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor.withOpacity(
                                      0.4,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                onPressed: () {
                                  Get.offAllNamed(Routes.home);
                                },
                                child: const Text(
                                  AppStrings.returnToHomeButton,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
