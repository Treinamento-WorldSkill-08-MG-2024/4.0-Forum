import 'package:flutter/material.dart';

class ArchFormField extends StatelessWidget {
  final String? hintText;
  final String? Function(String?)? validator;
  final BorderSide? borderSide;
  final TextEditingController controller;

  const ArchFormField({
    super.key,
    this.hintText,
    required this.controller,
    this.validator, this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: borderSide ?? const BorderSide()
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      controller: controller,
    );
  }
}
