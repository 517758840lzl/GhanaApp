import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/colors/app_colors.dart';

class IOSPickerWidget {
  // iOS风格的底部弹出选择器
  static Future<void> showIOSPicker(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> options,
    Function(String) onSelected,
    String currentValue,
  ) async {
    final List<String> displayValues =
        options.map((item) => item['value'].toString()).toList();
    final List<String> keys =
        options.map((item) => item['key'].toString()).toList();

    // 找到当前选中项的索引
    int currentIndex = keys.indexOf(currentValue);
    if (currentIndex == -1) currentIndex = 0;

    // 判断是否需要显示搜索框
    bool showSearch = options.length > 30;

    // 搜索相关的状态变量
    String searchText = '';
    List<int> filteredIndices = List.generate(
      displayValues.length,
      (index) => index,
    );
    TextEditingController searchController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // 获取键盘高度
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

            var containerHeight =Get.height*0.6;
            if (keyboardHeight > 0&&showSearch) {
              containerHeight = Get.height * 0.8;

            }

            // 过滤选项
            if (showSearch && searchText.isNotEmpty) {
              filteredIndices = [];
              for (int i = 0; i < displayValues.length; i++) {
                if (displayValues[i].toLowerCase().contains(
                  searchText.toLowerCase(),
                )) {
                  filteredIndices.add(i);
                }
              }
            } else {
              filteredIndices = List.generate(
                displayValues.length,
                (index) => index,
              );
            }

            return GestureDetector(
              onTap: () {
                // Close keyboard when tapping outside the search field
                FocusScope.of(context).unfocus();
              },
              child: Container(
                height: containerHeight,
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
                    // 搜索框（当选项超过30个时显示）
                    if (showSearch)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'search'.tr,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                            suffixIcon:
                                searchText.isNotEmpty
                                    ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          searchText = '';
                                        });
                                        searchController.clear();
                                        // Close keyboard when clearing search
                                        FocusScope.of(context).unfocus();
                                      },
                                    )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    // 选择器内容
                    Expanded(
                      child:
                          filteredIndices.isEmpty
                              ? Center(
                                child: Text(
                                  'noMatchingOptions'.tr,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                itemCount: filteredIndices.length,
                                itemBuilder: (context, index) {
                                  int originalIndex = filteredIndices[index];
                                  bool isSelected =
                                      originalIndex == currentIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      onSelected(keys[originalIndex]);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
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
                                              displayValues[originalIndex],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    isSelected
                                                        ? AppColors.primaryColor
                                                        : Colors.black,
                                                fontWeight:
                                                    isSelected
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
            );
          },
        );
      },
    );
  }
}
