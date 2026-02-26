import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final List<Color>? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? AppColors.surface) : null,
      gradient: gradient != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient!,
            )
          : null,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
    );

    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.base),
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
