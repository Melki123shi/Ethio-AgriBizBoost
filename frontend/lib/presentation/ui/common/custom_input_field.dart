import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String? label;
  final String hintText;

  // for text input
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;       // text‐field callback

  // for dropdown
  final List<String>? dropdownItems;            // if non-null → render dropdown
  final String? selectedValue;
  final ValueChanged<String?>? onDropdownChanged;
  final bool enabled;

  final double? contentVerticalPadding;
  final bool isRequired;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final IconButton? suffixIcon;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const CustomInputField({
    super.key,
    required this.hintText,
    this.label,
    this.controller,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.dropdownItems,
    this.selectedValue,
    this.onDropdownChanged,
    this.contentVerticalPadding,
    this.isRequired = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.borderColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      label: label != null
          ? buildRequiredLabel(label!, isRequired: isRequired)
          : null,
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: false,
      fillColor: Theme.of(context).scaffoldBackgroundColor,
      contentPadding: EdgeInsets.symmetric(
        vertical: contentVerticalPadding ?? 20,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(15),
        borderSide: BorderSide(color: borderColor ?? const Color.fromARGB(255, 148, 196, 149)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: borderColor ?? const Color.fromARGB(255, 148, 196, 149)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.4),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );

    // if dropdownItems is provided, render a DropdownButtonFormField
    if (dropdownItems != null) {
      return DropdownButtonFormField<String>(
        value: selectedValue,
        items: dropdownItems!
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: enabled ? onDropdownChanged : null,
        enableFeedback: enabled,
        decoration: decoration,
        validator: validator != null
            ? (val) => validator!(val)
            : (val) {
                if (isRequired && (val == null || val.isEmpty)) {
                  return '$hintText ${context.commonLocals.cannot_be_empty}';
                }
                return null;
              },
      );
    }

    // otherwise, render a normal TextFormField
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return '$hintText ${context.commonLocals.cannot_be_empty}';
            }
            return null;
          },
      decoration: decoration,
    );
  }
}

Widget buildRequiredLabel(String label,
    {bool isRequired = false, Color? color}) {
  return RichText(
    text: TextSpan(
      text: label,
      style: TextStyle(color: color ?? Colors.grey[600]),
      children: isRequired
          ? const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.redAccent),
              ),
            ]
          : [],
    ),
  );
}
