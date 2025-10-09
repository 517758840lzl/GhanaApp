import 'package:flutter/material.dart';
import '../../common/colors/app_colors.dart';

class ModernFormWidgets {
  static InputDecoration getModernInputDecoration({
    required String label,
    String? hint,
    String? errorText,
    Widget? suffixIcon,
    bool isFocused = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: isFocused ? AppColors.primaryColor : Colors.grey[600],
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      errorStyle: TextStyle(
        color: Colors.red[400],
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2.0),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  // 带阴影的输入框包装器
  static Widget buildShadowedInputField(Widget child) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
