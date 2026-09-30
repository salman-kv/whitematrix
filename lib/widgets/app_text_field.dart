import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';

/// Labelled form field matching the login design (label above, soft fill,
/// red outline + message on error, optional show/hide for passwords).
class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscure;
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final AutovalidateMode autovalidateMode;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscure = false,
    this.prefix,
    this.inputFormatters,
    this.focusNode,
    this.onSubmitted,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _hidden = widget.obscure;

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c, width: w),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _hidden,
          inputFormatters: widget.inputFormatters,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
            filled: true,
            fillColor: AppColors.surface,
            prefixIcon: widget.prefix,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary, 1.6),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.6),
            errorStyle: TextStyle(fontSize: 12, color: AppColors.error),
            suffixIcon: widget.obscure
                ? IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
