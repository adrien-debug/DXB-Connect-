import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double remainingGB;
  final int usagePercent;
  final int esimCount;
  final int activeCount;
  final int countriesCount;
  final bool isLoaded;

  const BalanceCard({
    super.key,
    required this.remainingGB,
    required this.usagePercent,
    required this.esimCount,
    required this.activeCount,
    required this.countriesCount,
    this.isLoaded = true,
  });

  String get _remainingValue {
    if (!isLoaded) return '--';
    if (remainingGB >= 1) return remainingGB.toStringAsFixed(1);
    return (remainingGB * 1024).toStringAsFixed(0);
  }

  String get _remainingUnit {
    if (!isLoaded) return '';
    return remainingGB >= 1 ? 'GB' : 'MB';
  }

  String get _usageDisplay => isLoaded ? '$usagePercent%' : '--%';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _remainingValue,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1,
                  letterSpacing: -2,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  _remainingUnit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  color: AppColors.accent.withValues(alpha: 0.1),
                ),
                child: Text(
                  '$_usageDisplay used',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UsageBar(percent: isLoaded ? usagePercent : 0),
          const SizedBox(height: 14),
          Container(height: 0.5, color: AppColors.surfaceBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(value: '$esimCount', label: 'eSIMs'),
              _MiniStat(value: '$activeCount', label: 'Active'),
              _MiniStat(value: '$countriesCount', label: 'Countries'),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  final int percent;
  const _UsageBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fillWidth = (width * percent / 100).clamp(0.0, width);
        return Container(
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.surfaceBorder,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              width: fillWidth,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: AppColors.accent,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
