import 'package:flutter/material.dart';
import 'package:flutter3APP/common/toast.dart';
import 'package:get/get.dart';
import '../../common/colors/app_colors.dart';

class AddressPickerWidget {
  // 多级地址选择器 - 支持省市联动选择
  static Future<Map<String, dynamic>?> showAddressPicker(
    BuildContext context,
    String title,
    List<dynamic> provinces,
    List<dynamic> cities,
    String currentProvinceId,
    String currentCityId,
  ) async {
    // 过滤有效的省份（有对应城市的省份）
    final cityParentIds = cities.map((city) => city['parentId'] as int).toSet();
    final validProvinces = provinces.where((province) {
      final provinceId = province['id'] as int;
      return cityParentIds.contains(provinceId);
    }).toList();

    if (validProvinces.isEmpty) {
      return null;
    }

    // 获取当前选中的省份和城市信息
    String selectedProvinceId = currentProvinceId;
    String selectedCityId = currentCityId;

    // 如果当前省份无效，选择第一个有效省份
    if (selectedProvinceId.isEmpty ||
        !validProvinces.any((p) => p['id'].toString() == selectedProvinceId)) {
      selectedProvinceId = validProvinces.first['id'].toString();
      selectedCityId = '';
    }

    // 获取当前省份对应的城市列表
    List<dynamic> currentCities = cities.where((city) {
      return city['parentId'] == int.parse(selectedProvinceId);
    }).toList();

    // 如果当前城市不在当前省份下，清空城市选择
    if (selectedCityId.isNotEmpty &&
        !currentCities.any((c) => c['id'].toString() == selectedCityId)) {
      selectedCityId = '';
    }

    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Container(
                height: Get.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // 顶部拖拽指示器
                    Container(
                      margin: EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // 标题栏
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 80),
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'cancel'.tr,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 选择器内容
                    Expanded(
                      child: Row(
                        children: [
                          // 省份选择
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppColors.primaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Region'.tr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: validProvinces.length,
                                    itemBuilder: (context, index) {
                                      final province = validProvinces[index];
                                      final provinceId = province['id']
                                          .toString();
                                      final provinceName = province['name'];
                                      final isSelected =
                                          provinceId == selectedProvinceId;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedProvinceId = provinceId;
                                            selectedCityId = '';
                                            // 更新城市列表
                                            currentCities = cities.where((
                                              city,
                                            ) {
                                              return city['parentId'] ==
                                                  int.parse(selectedProvinceId);
                                            }).toList();
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryColor
                                                      .withOpacity(0.1)
                                                : Colors.transparent,
                                            border: Border(
                                              bottom: BorderSide(
                                                color: Colors.grey[100]!,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  provinceName,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: isSelected
                                                        ? AppColors.primaryColor
                                                        : Colors.black,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check,
                                                  color: AppColors.primaryColor,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 分隔线
                          Container(width: 1, color: Colors.grey[200]),
                          // 城市选择
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[200]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_city,
                                        color: AppColors.primaryColor,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'city'.tr,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: currentCities.isEmpty
                                      ? Center(
                                          child: Text(
                                            'pleaseSelectProvinceFirst'.tr,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: currentCities.length,
                                          itemBuilder: (context, index) {
                                            final city = currentCities[index];
                                            final cityId = city['id']
                                                .toString();
                                            final cityName = city['name'];
                                            final isSelected =
                                                cityId == selectedCityId;

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedCityId = cityId;
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? AppColors.primaryColor
                                                            .withOpacity(0.1)
                                                      : Colors.transparent,
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.grey[100]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        cityName,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: isSelected
                                                              ? AppColors
                                                                    .primaryColor
                                                              : Colors.black,
                                                          fontWeight: isSelected
                                                              ? FontWeight.w600
                                                              : FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                    if (isSelected)
                                                      Icon(
                                                        Icons.check,
                                                        color: AppColors
                                                            .primaryColor,
                                                        size: 20,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 底部确认按钮
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedProvinceId.isNotEmpty &&
                                    selectedCityId.isNotEmpty) {
                                  final result = {
                                    'provinceId': selectedProvinceId,
                                    'cityId': selectedCityId,
                                    'provinceName': validProvinces.firstWhere(
                                      (p) =>
                                          p['id'].toString() ==
                                          selectedProvinceId,
                                    )['name'],
                                    'cityName': currentCities.firstWhere(
                                      (c) =>
                                          c['id'].toString() == selectedCityId,
                                    )['name'],
                                  };
                                  Navigator.pop(context, result);
                                } else {
                                  YDToast.text('pleaseSelectBothProvinceAndCity'.tr);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'confirm'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
