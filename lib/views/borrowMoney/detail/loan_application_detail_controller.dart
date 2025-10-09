import 'package:get/get.dart';
import 'package:flutter3APP/l10n/app_strings.dart';
import 'package:flutter3APP/models/home_page_data.dart';

class LoanApplicationDetailController extends GetxController {
  final Rx<Product?> product = Rx<Product?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 从参数中获取产品数据
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      final arg = arguments['product'];
      if (arg is Product) {
        product.value = arg;
      }
    }

    if (product.value == null) Get.snackbar(AppStrings.error, '');
  }

  void refreshData() {
    // 直接使用传入数据，无需刷新
  }
}
