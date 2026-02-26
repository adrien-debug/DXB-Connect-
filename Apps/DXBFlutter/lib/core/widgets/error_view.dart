import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.base),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Retry',
                onPressed: onRetry,
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.base),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
