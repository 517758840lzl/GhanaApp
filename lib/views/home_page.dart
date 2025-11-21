import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:flutter3APP/views/borrowMoney/borrow_page.dart';
import 'borrowMoney/borrow_controller.dart';
import 'me/my_controller.dart';
import 'me/my_page.dart';
import 'repayMoney/repayment_page.dart';
import 'home_controller.dart';
import 'repayMoney/repayment_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      BorrowPage(),
      RepaymentPage(),
      MyPage(),
    ];
    controller.setPages(pages);
    return Obx(
      () => Scaffold(
        body: IndexedStack(index: controller.selectedIndex.value, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: AppColors.primaryColor,
          onTap: (index) {
            controller.onTabTapped(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.payments,
                  size: 25,
                  color: controller.selectedIndex.value == 0 ? AppColors.primaryColor : Colors.grey),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.payment_sharp,
                size: 25,
                color: controller.selectedIndex.value == 1 ? AppColors.primaryColor : Colors.grey,
              ),
              label: 'repayment'.tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 25,
                color: controller.selectedIndex.value == 2 ? AppColors.primaryColor : Colors.grey,
              ),
              label: 'me'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
