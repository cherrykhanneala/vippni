import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool isRequired;
  final bool obscureText;
  final Widget? suffix;

  const AppTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.isRequired = false,
    this.obscureText = false,
    this.suffix, required Null Function(dynamic value) onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: suffix,
          ),
          validator: validator ?? (isRequired ? (value) => value?.isEmpty ?? true ? 'This field is required' : null : null),
          keyboardType: keyboardType,
          obscureText: obscureText,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}