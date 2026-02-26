import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool isSecure;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.isSecure = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: _isFocused
                ? AppColors.accent.withValues(alpha: 0.8)
                : AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md + 2),
          ),
          child: Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.isSecure && _obscured,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autocorrect: false,
              enableSuggestions: !widget.isSecure,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: _isFocused
                    ? AppColors.surfaceLight
                    : AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.base,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(
                    color: _isFocused ? AppColors.accent : AppColors.surfaceBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.surfaceBorder,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                suffixIcon: widget.isSecure
                    ? IconButton(
                        icon: Icon(
                          _obscured
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: _isFocused
                              ? AppColors.accent.withValues(alpha: 0.6)
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscured = !_obscured),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
