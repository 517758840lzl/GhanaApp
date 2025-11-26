import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../basa/analytics/app_event_tracker.dart';
import '../../../../common/colors/app_colors.dart';
import '../../kyc_step_controller.dart';

class ContactSelectionField extends StatefulWidget {
  final String code;
  final String label;
  final String currentValue;
  final int type;
  final KycStepController controller;
  final BuildContext context;
  final List<FocusNode> focusNodes;
  final Function(FocusNode) addFocusNode;
  final VoidCallback hideKeyboard;

  const ContactSelectionField({
    Key? key,
    required this.code,
    required this.label,
    required this.currentValue,
    required this.type,
    required this.controller,
    required this.context,
    required this.focusNodes,
    required this.addFocusNode,
    required this.hideKeyboard,
  }) : super(key: key);

  @override
  State<ContactSelectionField> createState() => _ContactSelectionFieldState();
}

class _ContactSelectionFieldState extends State<ContactSelectionField> {
  late FocusNode _focusNode;
  bool _isDisposed = false;
  bool _isProcessing = false;
  DateTime? _lastTapTime;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    // 确保控制器存在
    if (!widget.controller.controllers.containsKey(widget.code)) {
      widget.controller.controllers[widget.code] = TextEditingController(
        text: widget.currentValue,
      );
    }

    // 创建FocusNode并添加到列表
    _focusNode = FocusNode();
    widget.addFocusNode(_focusNode);

    // 监听焦点变化
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_isDisposed) return;

    if (_focusNode.hasFocus) {
      AppEventTracker.instance.startInteraction(
        widget.controller.currentStep.value,
        widget.code,
        widget.label,
      );
    } else {
      AppEventTracker.instance.endInteraction(
        widget.controller.currentStep.value,
        widget.code,
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleContactTap() async {
    // 如果正在处理或已销毁，直接返回
    if (_isProcessing || _isDisposed) return;

    // 防抖处理：防止快速连续点击
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < _debounceDuration) {
      return;
    }
    _lastTapTime = now;

    // 设置处理标志
    _isProcessing = true;

    try {
      // 先取消焦点，避免系统上下文菜单冲突
      _focusNode.unfocus();

      // 隐藏键盘
      widget.hideKeyboard();

      // 等待一小段时间确保焦点状态更新
      await Future.delayed(const Duration(milliseconds: 150));

      if (_isDisposed) {
        _isProcessing = false;
        return;
      }

      AppEventTracker.instance.startInteraction(
        widget.controller.currentStep.value,
        widget.code,
        widget.label,
      );
      await widget.controller.requestContactPermission(widget.code);
      AppEventTracker.instance.endInteraction(
        widget.controller.currentStep.value,
        widget.code,
      );
    } catch (e) {
      // 忽略错误，避免崩溃
      debugPrint('Error in contact selection: $e');
    } finally {
      // 确保重置处理标志
      if (!_isDisposed) {
        _isProcessing = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 判断是否可编辑
    bool isEditable = widget.type == 10; // 10可选可输入，9只能选
    // 判断是否隐藏右侧 icon（code 为 30052 或 30062）
    bool shouldText = widget.code == '30052' || widget.code == '30062';

    Widget textField = TextFormField(
          readOnly: !isEditable,
          controller: widget.controller.controllers[widget.code],
          focusNode: _focusNode,
          keyboardType: shouldText ? TextInputType.text : TextInputType.phone,
          enableInteractiveSelection: isEditable,
          contextMenuBuilder: (context, editableTextState) {
            // 返回空菜单，防止系统上下文菜单错误
            // 这样可以避免快速点击时的文本输入连接错误
            return const SizedBox.shrink();
          },
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            hintText: isEditable
                ? 'enterPhoneNumberOrSelectFromContacts'.tr
                : 'selectFromContacts'.tr,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon:  Container(
                    margin: EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: _handleContactTap,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.contacts,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
            errorText:
                widget.controller.isSubmitted.value &&
                    (widget.controller.controllers[widget.code]?.text
                            .trim()
                            .isEmpty ??
                        true)
                ? 'pleaseFillAllFields'.tr
                : null,
          ),
          onChanged: isEditable
              ? (val) {
                  widget.controller.stepData[widget.code] = val;
                  if (val.trim().isNotEmpty) {
                    widget.controller.isSubmitted.value = false;
                  }
                }
              : null,
          validator: (val) {
            if (widget.controller.isSubmitted.value &&
                (val == null || val.trim().isEmpty)) {
              return 'pleaseFillAllFields'.tr;
            }
            return null;
          },
        );

    return GestureDetector(
      onTap: !isEditable
          ? () {
              // 对于只读字段（type == 9），整个框都可以点击
              _handleContactTap();
            }
          : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: !isEditable
            ? IgnorePointer(
                // 不可编辑时，让 TextFormField 不拦截点击事件，整个框都可以点击
                child: textField,
              )
            : textField,
      ),
    );
  }
}
