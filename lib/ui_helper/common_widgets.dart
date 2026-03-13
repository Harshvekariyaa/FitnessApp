import 'package:fitnessai/Themes_and_color/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

TextStyle? textStyle(Color? color, double? fSize, FontWeight? fWeight, {bool space = false}){
  return TextStyle(
      color: color,
      fontSize: fSize,
      fontWeight: fWeight,
      height: space ? 1.6 : 1.42
  );
}

Widget buildTextFormField({
  required TextEditingController controller,
  String? lText,
  String? hText,
  required String? Function(String?) validator,
  TextInputType inputType = TextInputType.text,
  bool obscureText = false,
  Icon? suffixIcon,
  Icon? prefixIcon,
  int? maxLength,
  VoidCallback? onSuffixIconPressed,
  bool forReadOnly = false,
  FocusNode? focusNode,
  int? maxLines = 1,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: inputType,
    obscureText: obscureText,
    cursorColor: AppColors.primaryDark,
    maxLength: maxLength,
    focusNode: focusNode,
    readOnly: forReadOnly,
    cursorHeight: 20,
    maxLines: maxLines,
    onChanged: onChanged,
    buildCounter: (context, {required currentLength, required maxLength, required isFocused}) {
      return SizedBox.shrink();
    },
    decoration: InputDecoration(
      hintText: hText,
      hintStyle: textStyle(AppColors.textHint, 14, AppColors.normal),
      labelText: lText,
      labelStyle: textStyle(AppColors.grey.shade600, 15, AppColors.normal),
      floatingLabelStyle: textStyle(AppColors.primaryDark, null, null), // Label color when floating (focused or has value)
      iconColor: AppColors.primaryDark,
      prefixIcon: prefixIcon,
      prefixIconColor: AppColors.primaryDark,
      suffixIcon: suffixIcon != null
          ? IconButton(icon: suffixIcon, onPressed: onSuffixIconPressed,
      )
          : null,
      filled: true,
      fillColor: AppColors.white,
      // kblue.shade800.withValues(alpha: 0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
            color: AppColors.primaryDark
        ),
      ),
    ),
    validator: validator,
  );
}

Widget customDropdown({
  required String? value,
  required List<String> items,
  required String hintText,
  required IconData icon,
  required Function(String?) onChanged,
  FocusNode? focusNode,
  FormFieldValidator<String>? validator,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    focusNode: focusNode,
    hint: Text(hintText, style: textStyle(AppColors.grey.shade600, 14, AppColors.normal)),
    decoration: InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      prefixIcon: Icon(icon, color: AppColors.primaryDark),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryDark),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade800),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red),
      ),
    ),
    isExpanded: true,
    items: items.map((String item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item, style: textStyle(AppColors.black, null, AppColors.normal), overflow: TextOverflow.ellipsis),
      );
    }).toList(),
    dropdownColor: AppColors.cardBackground,
    onChanged: onChanged,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please select an option";
      }
      return validator?.call(value);
    },
  );
}


Widget elevetedbtn(String text, VoidCallback onPressed, {bool? isLoading}) {
  return ElevatedButton(
    onPressed: (isLoading ?? false) ? null : onPressed, // Disable button when loading
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: (isLoading ?? false)
        ? SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        color: AppColors.white,
        strokeWidth: 2,
      ),
    )
        : Text(
      text,
      style: textStyle(AppColors.white, 16, AppColors.w500),
    ),
  );
}

PreferredSizeWidget commonAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title, style: textStyle(AppColors.white, 20, AppColors.w500)),
    backgroundColor: AppColors.appBarColor,
    foregroundColor: Colors.white,
    actions: actions ?? [],
  );
}


Widget header(String title,String subTitle) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.primary.withOpacity(0.85),
        ],
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "$subTitle",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );
}


Widget numberCard({
  required String title,
  required String unit,
  required int value,
  required int min,
  required int max,
  required ValueChanged<int> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.grey.shade300)
      // boxShadow: [
      //   BoxShadow(
      //     color: Colors.black.withOpacity(0.06),
      //     blurRadius: 12,
      //     offset: const Offset(0, 6),
      //   ),
      // ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title ($unit)",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: NumberPicker(
            value: value,
            minValue: min,
            maxValue: max,
            onChanged: onChanged,
            itemHeight: 40,
            selectedTextStyle: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}
// void showCustomToast(String message, {bool isWrong = false}) {
//   Fluttertoast.showToast(
//     msg: message,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     backgroundColor: isWrong ? kred : kblue.shade700,
//     textColor: kwhite,
//     fontSize: 16.0,
//   );
// }
