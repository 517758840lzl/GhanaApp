import 'package:get/get.dart';
import '../../models/repayment.dart';
import '../../provider/userDataHelper.dart';
import '../../http/api_urls.dart';
import '../../common/toast.dart';
import '../../provider/app_state.dart';
import '../../routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../common/logger/app_logger.dart';

class RepaymentController extends GetxController {
  final items = <RepaymentItem>[].obs;
  final RxMap<String, bool> selectedMap = <String, bool>{}.obs;
  final RxInt cacheFlag = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getCacheData();
    loadRepaymentData();
  }

  getCacheData() async {
    cacheFlag.value = await UserDataHelper.getCacheData() ?? 0;
  }

  Future<List<RepaymentItem>?> fetchRepaymentData({
    bool loading = false,
  }) async {
    try {
      final result = await ApiUrls.fetchRepaymentData();
      if (loading) {
        YDToast.cleanAll();
      }
      if (result.isSucceed && result.rawData != null) {
        final List<Map<String, dynamic>> rawList =
            List<Map<String, dynamic>>.from(result.rawData);
        final repaymentResponse =
            rawList.map((e) => RepaymentItemMapper.fromMap(e)).toList() ?? [];
        return repaymentResponse;
      } else {
        YDToast.text(result.msg != "" ? result.msg : 'error'.tr);
        return null;
      }
    } catch (e) {
      LogUtil.d('catch-Error:$e');
      return null;
    }
  }

  loadRepaymentData({bool loading = false}) async {
    if (loading) {
      YDToast.loading();
    }

    try {
      final response = await fetchRepaymentData(loading: loading);

      if (response != null) {
        items.value = [];
        items.assignAll(response);
        selectedMap.clear();
        for (var item in items) {
          selectedMap[item.appOrderId] = true;
        }
      }
    } catch (e) {}
  }

  refreshData() async {
    await loadRepaymentData();
  }

  num get getTotalAmount {
    num total = 0;
    for (var item in items) {
        total += item.repayAmount;
    }
    return total;
  }
  num get totalSelectedAmount {
    num total = 0;
    for (var item in items) {
      if (selectedMap[item.appOrderId] == true) {
        total += item.repayAmount;
      }
    }
    return total;
  }

  List<String> get selectedOrderIds {
    return items
        .where((item) => selectedMap[item.appOrderId] == true)
        .map((item) => item.appOrderId)
        .toList();
  }

  List<String> get selectedProductCodes {
    return items
        .where((item) => selectedMap[item.appOrderId] == true)
        .map((item) => item.productSetCode)
        .toList();
  }

  void toggleSelect(int index) {
    final id = items[index].appOrderId;
    if (selectedMap.values.where((value) => value).length == 1 &&
        selectedMap[id] == true) {
      return;
    }
    selectedMap[id] = !(selectedMap[id] ?? true);
  }

  void goToRepaymentSubmitPage({required List<String> orderIds}) {
    Get.toNamed(
      Routes.repaymentSubmit,
      arguments: {'orderIds': orderIds},
    )?.then((_) => refreshData());
  }

  void goToAllRepaymentSubmitPage({
    required List<String> orderIds,
    required List<String> productCodes,
  }) {
    if (orderIds.length == 1) {
      Get.toNamed(
        Routes.repaymentSubmit,
        arguments: {'orderIds': orderIds},
      )?.then((_) => refreshData());
    } else {
      Get.toNamed(
        Routes.repaymentAllSubmit,
        arguments: {'orderIds': orderIds, 'productCodes': productCodes},
      )?.then((_) => refreshData());
    }
  }

  refreshDataWithSelection() async {
    var oldSelectedMap = Map<String, bool>.from(selectedMap);
    await loadRepaymentData();
    selectedMap.clear();
    for (var item in items) {
      selectedMap[item.appOrderId] = oldSelectedMap[item.appOrderId] ?? true;
    }
  }
}
