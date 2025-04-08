import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String? label;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final double? contentVerticalPadding;
  final bool isRequired;

  const CustomInputField({
    super.key,
    required this.hintText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.contentVerticalPadding,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        if (label != null) const SizedBox(height: 6),
        Center(
          child: SizedBox(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              onChanged: onChanged,
              validator: (value) {
                if (isRequired && (value == null || value.trim().isEmpty)) {
                  return '$hintText cannot be empty';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                contentPadding: EdgeInsets.symmetric(
                  vertical: contentVerticalPadding ?? 20,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                prefixIcon: prefixIcon != null
                    ? Icon(prefixIcon, color: Theme.of(context).iconTheme.color)
                    : null,
                suffixIcon: suffixIcon != null
                    ? Icon(suffixIcon, color: Theme.of(context).iconTheme.color)
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
