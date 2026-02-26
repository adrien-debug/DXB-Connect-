import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';

class SubscriptionPromoBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const SubscriptionPromoBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ScaleOnTap(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: GradientBorderCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          borderWidth: 1.5,
          borderColors: [
            AppColors.accent.withValues(alpha: 0.7),
            AppColors.accent.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.06),
            AppColors.accent.withValues(alpha: 0.4),
          ],
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SimPass Premium',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Save up to 50% · From \$3.33/mo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Text(
                  'JOIN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
