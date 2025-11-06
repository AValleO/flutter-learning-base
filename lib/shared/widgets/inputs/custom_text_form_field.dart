import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  final String label;
  final String hintText;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final String? errorText;
  final bool obscureText;

  final border = OutlineInputBorder(
    //borderSide: BorderSide(color: Colors.blue),
    borderRadius: BorderRadius.circular(40),
  );

  CustomTextFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onChanged,
    required this.validator,
    this.errorText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colors.primary),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        isDense: true,
        label: Text(label),
        hintText: hintText,
        focusColor: colors.primary,
        icon: Icon(Icons.supervised_user_circle_outlined, color: colors.primary,),
        errorText: errorText,
      ),
      obscureText: obscureText,
    );
  }
}