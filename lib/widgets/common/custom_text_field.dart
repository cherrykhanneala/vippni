import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final bool isRequired;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}