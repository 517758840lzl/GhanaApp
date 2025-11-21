import 'package:flutter3APP/views/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/colors/app_colors.dart';
import 'history_controller.dart';
import 'dialog/history_dialogs.dart';
import 'cell/order_history_item_widget.dart';
import 'cell/checkout_order_item_card.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({Key? key}) : super(key: key);
  final HistoryController controller = Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            'history'.tr,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            controller.refreshData();
          },
          child:
              controller.historyData.isEmpty &&
                  controller.checkoutOrders.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: const NoDataPage(),
                  ),
                )
              : SingleChildScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 使用主题色的分组标题
                      if (controller.historyData.isNotEmpty) ...[
                        // _buildSectionHeader(
                        //   'activeOrders'.tr,
                        //   controller.historyData.length,
                        //   AppColors.primaryColor,
                        // ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.historyData.length,
                          itemBuilder: (context, index) {
                            final item = controller.historyData[index];
                            return GestureDetector(
                              onTap: () =>
                                  HistoryDialogs.showHistoryOrderDetailDialog(
                                    context,
                                    item,
                                  ),
                              child: OrderHistoryItemWidget(
                                item: item,
                                onCancel: controller.cancelCountdown,
                                cacheFlag: controller.cacheFlag,
                                controller: controller,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (controller.checkoutOrders.isNotEmpty) ...[
                        _buildSectionHeader(
                          'completedOrders'.tr,
                          controller.checkoutOrders.length,
                          AppColors.primaryDarkColor,
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.checkoutOrders.length,
                          itemBuilder: (context, index) {
                            final item = controller.checkoutOrders[index];
                            return GestureDetector(
                              onTap: () =>
                                  HistoryDialogs.showCheckoutOrderDetailDialog(
                                    context,
                                    item,
                                    controller.cacheFlag,
                                  ),
                              child: CheckoutOrderItemCard(
                                item: item,
                                onCancel: controller.cancelCountdown,
                                cacheFlag: controller.cacheFlag,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoDataPage extends StatelessWidget {
  const NoDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Image.asset(
                'assets/images/state_empty.webp',
                width: 120,
                height: 120,
              ),
            ),

            const SizedBox(height: 15),
            Text(
              'noOrdersYet'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'noApprovedOrders'.tr,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 32),
              child: ElevatedButton(
                onPressed: () {
                  Get.find<HomeController>().onTabTapped(0);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'getMoney'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
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
  }
}
