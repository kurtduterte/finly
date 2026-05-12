import 'package:flutter/material.dart';

class ExpenseTextFormField extends StatelessWidget {
  const ExpenseTextFormField({
    required this.label,
    this.controller,
    this.hintText,
    this.prefixText,
    this.keyboardType,
    this.validator,
    super.key,
  });

  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixText: prefixText,
      ),
    );
  }
}
