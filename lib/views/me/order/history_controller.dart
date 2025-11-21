import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter3APP/common/colors/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../provider/userDataHelper.dart';
import '../../../models/order_history.dart';
import '../../../models/settled_contract.dart';
import '../../../http/api_urls.dart';
import '../../../common/toast.dart';
import '../../../routes/routes.dart';
import '../../../common/logger/app_logger.dart';
import '../../../utils/string/string_util.dart';

class HistoryController extends GetxController {
  //活跃订单
  final RxList<OrderHistoryItem> historyData = <OrderHistoryItem>[].obs;
  //历史订单
  final RxList<CheckoutOrderItem> checkoutOrders = <CheckoutOrderItem>[].obs;
  final ScrollController scrollController = ScrollController();
  final pageIndex = 1.obs;
  int cacheFlag = 0;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(_onScroll);
    refreshData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {}

  refreshData() async {
    pageIndex.value = 1;

    fetchOrders();
    fetchCheckoutOrders(pageIndex.value);
  }

  Future<List<OrderHistoryItem>> fetchOrderHistory(
    BuildContext context, {
    List<int>? statusList,
  }) async {
    final result = await ApiUrls.fetchOrderHistory(statusList: statusList);
    if (result.isSucceed && result.rawData != null) {
      final List<Map<String, dynamic>> rawList =
          List<Map<String, dynamic>>.from(result.rawData);
      final mapped =
          rawList.map((e) => OrderHistoryItemMapper.fromMap(e)).toList() ?? [];
      return mapped;
    } else {
      YDToast.text(
        result.msg != "" ? result.msg : "Error getting order history",
      );
      return [];
    }
  }

  Future<void> fetchOrders() async {
    cacheFlag = await UserDataHelper.getCacheData() ?? 0;

    final orders = await fetchOrderHistory(Get.context!, statusList: []);
    historyData.value = [];
    if (orders.length > 0) {
      historyData.assignAll(orders);
    }
  }

  //获取历史订单
  Future<SettledContractData?> checkoutOderRequest(
    int pageIndex, {
    bool loading = true,
  }) async {
    try {
      if (loading) {
        YDToast.loading();
      }

      final result = await ApiUrls.checkoutOrderRequest(pageIndex: pageIndex);
      if (loading) {
        YDToast.cleanAll();
      }
      checkoutOrders.value = [];
      if (result.isSucceed && result.data != null) {
        final mapped = SettledContractDataMapper.fromMap(result.data ?? {});
        return mapped;
      } else {
        YDToast.text(
          result.msg != "" ? result.msg : "Error getting order history",
        );
        LogUtil.d("CheckoutOrderRequest error: ${result.msg}");
        return null;
      }
    } catch (e) {
      LogUtil.d("CheckoutOrderRequest exception: $e");
      return null;
    }
  }

  Future<void> fetchCheckoutOrders(int pageIndex) async {
    final settledData = await checkoutOderRequest(pageIndex);
    final list = settledData?.list ?? [];
    if (list.isNotEmpty) {
      checkoutOrders.addAll(list);
    }
  }

  Future<bool> removeLoanCountDown(
    BuildContext context,
    String appOrderId,
  ) async {
    try {
      final result = await ApiUrls.removeLoanCountDown(appOrderId: appOrderId);
      if (result.isSucceed) {
        YDToast.text('cancelSuccess'.tr);
        fetchOrders();
        return true;
      } else {
        YDToast.text(result.msg != "" ? result.msg : 'Cancel failed');
      }
    } catch (e) {
      LogUtil.d('catch-Error:$e');
    }
    return false;
  }

  Future<void> cancelCountdown(String appOrderId) async {
    Get.dialog(
      AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 30),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'autoDisburseTip'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('autoDisburseCancel'.tr),
        actions: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                  ),
                  child: Text(
                    'cancel'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    final success = await removeLoanCountDown(
                      Get.context!,
                      appOrderId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                  ),
                  child: Text(
                    'confirm'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //打开合同
  toContracrClick(
    BuildContext context,
    num loanAmount,
    num singleRepaymentAmount,
    num amountCredited,
    String dueDate,
    String bankCardNo,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final customerName = prefs.getString("cached_customerName") ?? "";
    final idCardNumber = prefs.getString("cached_idCardNumber") ?? "";
    final phone = prefs.getString("cached_phone") ?? "";
    //合同
    Get.toNamed(
      Routes.loanContract,
      arguments: {
        'loanAmount':
            '${'currencyUSD'.tr}${StringUtil.formatAmount(loanAmount)}',
        'singleRepaymentAmount':
            '${'currencyUSD'.tr}${StringUtil.formatAmount(singleRepaymentAmount)}',
        'amountCredited':
            '${'currencyUSD'.tr}${StringUtil.formatAmount(amountCredited)}',
        'interest':
            '${'currencyUSD'.tr}${StringUtil.formatAmount(singleRepaymentAmount - loanAmount)}',
        'dueDate': dueDate,
        'name': customerName,
        'idCardNumber': idCardNumber,
        'receivingBankCardNumber': bankCardNo,
        'loanMobilePhoneNumber': phone,
      },
    );
  }
}
