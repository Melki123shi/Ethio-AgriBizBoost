import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String? label;
  final String hintText;
  final IconData? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final double? contentVerticalPadding;
  final bool isRequired;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const CustomInputField(
      {super.key,
      required this.hintText,
      this.label,
      this.suffixIcon,
      this.controller,
      this.obscureText = false,
      this.keyboardType = TextInputType.text,
      this.onChanged,
      this.contentVerticalPadding,
      this.isRequired = false,
      this.validator,
      this.prefixIcon,
      this.borderColor,
      this.borderRadius
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              onChanged: onChanged,
              validator: validator ??
                  (value) {
                    if (isRequired && (value == null || value.trim().isEmpty)) {
                      return '$hintText ${context.commonLocals.cannot_be_empty}';
                    }
                    return null;
                  },
              decoration: InputDecoration(
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
                  borderSide: const BorderSide(color:  Color.fromARGB(255, 148, 196, 149)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color:  Color.fromARGB(255, 148, 196, 149)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1.4),
                ),
                prefixIcon: prefixIcon,
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
