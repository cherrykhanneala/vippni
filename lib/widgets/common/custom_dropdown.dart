import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final bool isRequired;
  final String Function(T)? displayTextFn;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.isRequired = false,
    this.displayTextFn,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(displayTextFn != null ? displayTextFn!(item) : item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator ?? (value) {
        if (isRequired && value == null) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }
}