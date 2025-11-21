import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter3APP/common/toast.dart';
import 'package:flutter3APP/utils/string/string_util.dart';
import 'package:flutter3APP/views/borrowMoney/borrow_controller.dart';
import 'package:flutter3APP/views/repayMoney/repayment_controller.dart';

import '../../models/home_page_data.dart';
import '../../routes/routes.dart';
import '../../utils/non_repeatable_click.dart';
import '../../common/colors/app_colors.dart';
import 'widgets/product_card_factory.dart';

/// 借款页面主组件
class BorrowPage extends StatefulWidget {
  BorrowPage({Key? key}) : super(key: key);

  @override
  State<BorrowPage> createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> with TickerProviderStateMixin {
  final BorrowController controller = Get.put(BorrowController());
  final RepaymentController repaymentController = Get.put(
    RepaymentController(),
  );

  late PageController _pageController;
  int _currentPage = 0;

  // 教程相关状态
  bool _showSwipeTutorial = false;
  late AnimationController _tutorialAnimationController;
  late Animation<double> _tutorialAnimation;
  Timer? _tutorialTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    // 初始化教程动画控制器
    _tutorialAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _tutorialAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _tutorialAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // 检查是否首次登录并显示教程
    _checkAndShowTutorial();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tutorialAnimationController.dispose();
    _tutorialTimer?.cancel();
    super.dispose();
  }

  /// 检查并显示教程
  void _checkAndShowTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenTutorial = prefs.getBool('has_seen_swipe_tutorial') ?? false;

      // 如果已经看过教程，则不显示
      if (hasSeenTutorial) return;

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _showSwipeTutorial = true;
        });
        _tutorialAnimationController.repeat(reverse: true);

        // 8秒后自动隐藏教程
        _tutorialTimer = Timer(const Duration(seconds: 8), () {
          _hideTutorial();
        });
      }
    } catch (e) {
      // 如果获取SharedPreferences失败，默认不显示教程
      print('Error checking tutorial status: $e');
    }
  }

  /// 隐藏教程
  void _hideTutorial() async {
    if (_showSwipeTutorial) {
      setState(() {
        _showSwipeTutorial = false;
      });
      _tutorialAnimationController.stop();
      _tutorialTimer?.cancel();

      // 标记用户已经看过教程
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_swipe_tutorial', true);
      } catch (e) {
        print('Error saving tutorial status: $e');
      }
    }
  }

  /// 将秒数转换为时分秒格式
  String _formatTimeFromSeconds(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// 获取可借产品数量
  int _getAvailableProductsCount() {
    final confirmData = controller.homePageData.value.confirmData;
    if (confirmData?.list == null) return 0;

    return confirmData!.list!
        .where((product) => product.productStatus == 0)
        .length;
  }

  /// 构建信用提示
  Widget _buildCreditTip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.trending_up, color: Colors.black54, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.cacheFlag.value==0?'maintainGoodCreditTip'.tr:'maintainingGoodCreditHistory'.tr,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshData(isloding: false);
          // 等待一小段时间确保数据刷新完成
          await Future.delayed(const Duration(milliseconds: 100));
          // 刷新后重置PageView到第一个页面
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
          setState(() {
            _currentPage = 0;
          });
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 顶部区域
            _buildMeituanStyleHeader(context),

            // 主要内容区域
            SliverToBoxAdapter(child: _buildMainContent(context)),

            // 底部间距
            const SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
      // 底部按钮
      bottomNavigationBar: _buildMeituanStyleBottomBar(),
    );
  }

  /// 顶部区域
  Widget _buildMeituanStyleHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          // color: AppColors.primaryColor
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryColor,AppColors.primaryDarkColor ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 金额展示卡片
              _buildAmountDisplayCard(),

              // 倒计时提示
              _buildCountdownBanner(),

              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }

  /// 构建金额展示卡片
  Widget _buildAmountDisplayCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
         color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Obx(() {
        final selectedProducts = controller.selectedProducts;
        final totalLoanAmount = selectedProducts.fold<num>(
          0,
          (sum, product) => sum + (product.productAccount ?? 0),
        );
        final totalRepayAmount = repaymentController.items.fold<num>(
          0,
          (sum, product) => sum + (product.repayAmount),
        );

        return Column(
          children: [
            // 顶部标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'creditLimit'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.contact),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/images/icon_service_two.webp',
                      width: 18,
                      height: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 主要金额显示
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TotalSelectloanPrincipal'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${'currencyUSD'.tr}${StringUtil.formatAmount(totalLoanAmount)}',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'instantApproval'.tr,
                        style: TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  ),
                ),

                // 还款金额（如果有）或产品统计信息
                if (totalRepayAmount > 0)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'repaymentAmount'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${'currencyUSD'.tr}${StringUtil.formatAmount(totalRepayAmount)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'availableProducts'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getAvailableProductsCount()}/${controller.homePageData.value.confirmData?.list?.length ?? 0}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'availableTotal'.tr,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        );
      }),
    );
  }

  /// 构建倒计时横幅
  Widget _buildCountdownBanner() {
    return Obx(() {
      final shouldShowCountdown = controller.showBottomCountdown.value;
      if (!shouldShowCountdown) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.timer, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'autoDisburseIn'.tr.replaceFirst(
                      '{seconds}',
                      _formatTimeFromSeconds(controller.countdownSeconds.value),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'autoDisburseDescription'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: controller.showCancelAutoDisburseDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'cancel'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 构建主要内容区域
  Widget _buildMainContent(BuildContext context) {
    return Obx(() {
      final details = controller.homePageData.value;
      if (details.confirmData == null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'noProductsAvailable'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
      }

      return _buildProductGrid(details.confirmData!);
    });
  }

  /// 构建产品网格
  Widget _buildProductGrid(ConfirmData confirmData) {
    if (confirmData.list == null || confirmData.list!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'noProductsAvailable'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              '${'products'.tr} (${confirmData.list!.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 信用提示
          _buildCreditTip(),
          const SizedBox(height: 15),

          // 产品列表 - 水平滑动
          SizedBox(
            height: 320, // 固定高度
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                    // 用户滑动时隐藏教程
                    if (_showSwipeTutorial) {
                      _hideTutorial();
                    }
                  },
                  itemCount: confirmData.list!.length,
                  itemBuilder: (context, index) {
                    final product = confirmData.list![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildMeituanStyleProductCard(product),
                    );
                  },
                ),

                // 滑动教程蒙版
                if (_showSwipeTutorial) _buildSwipeTutorialOverlay(),
              ],
            ),
          ),

          // 页面指示器
          if (confirmData.list!.length > 1) ...[
            const SizedBox(height: 16),
            Center(child: _buildPageIndicator(confirmData.list!.length)),
          ],
        ],
      ),
    );
  }

  /// 构建产品卡片
  Widget _buildMeituanStyleProductCard(Product product) {
    return ProductCardFactory.createProductCard(
      product: product,
      selectedProducts: controller.selectedProducts,
      onProductSelection: _handleProductSelection,
    );
  }

  /// 构建滑动教程蒙版
  Widget _buildSwipeTutorialOverlay() {
    return AnimatedBuilder(
      animation: _tutorialAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: _hideTutorial,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3 * _tutorialAnimation.value),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // 左侧提示区域
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(20 * _tutorialAnimation.value, 0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.swipe_left,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            'swipeRight'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 右侧提示区域
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 130,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(-20 * _tutorialAnimation.value, 0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.swipe_right,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            'browseProducts'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 中央提示文字
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'swipeToBrowseProducts'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建页面指示器
  Widget _buildPageIndicator(int itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          itemCount,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: index == _currentPage ? 32 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == _currentPage
                  ? AppColors.primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
              boxShadow: index == _currentPage
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  /// 处理产品选择
  void _handleProductSelection(Product product, bool isSelected) {
    if (isSelected) {
      if (controller.selectedProducts.length > 1) {
        controller.selectedProducts.remove(product);
      } else {
        YDToast.text('mustSelectOneProduct'.tr);
      }
    } else {
      controller.selectedProducts.add(product);
    }
  }

  /// 构建底部栏
  Widget _buildMeituanStyleBottomBar() {
    return Obx(() {
      if (controller.selectedProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.only(bottom: 10, left: 15, right: 15),
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            NonRepeatableClick.checkClick(
              debounceDuration: const Duration(seconds: 2),
              click: () async {
                controller.handleButtonTap();
              },
            );
          },
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                // 按钮文字
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'getMoney'.tr,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                          ),
                        ),
                        if (controller.selectedProducts.length > 1)
                          Text(
                            '（${controller.selectedProducts.length}）',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
