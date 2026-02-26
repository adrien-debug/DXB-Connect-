import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      padding: const EdgeInsets.all(18),
      borderWidth: 1.5,
      borderColors: [
        AppColors.accent.withValues(alpha: 0.7),
        AppColors.accent.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.06),
        AppColors.accent.withValues(alpha: 0.4),
      ],
      child: Column(
        children: [
          Row(
            children: [
              CircularUsageGauge(
                percentage: isLoaded ? usagePercent.toDouble() : 0,
                size: 110,
                centerValue: isLoaded ? '$usagePercent%' : '--%',
                centerLabel: 'USED',
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _remainingValue,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1,
                            letterSpacing: -2,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            _remainingUnit,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'remaining',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 0.5, color: AppColors.surfaceBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                value: '$esimCount',
                label: 'eSIMs',
              ),
              _MiniStat(
                value: '$activeCount',
                label: 'Active',
                showDot: activeCount > 0,
              ),
              _MiniStat(
                value: '$countriesCount',
                label: 'Countries',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final bool showDot;

  const _MiniStat({
    required this.value,
    required this.label,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Column(
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
          ],
        ),
      ),
    );
  }
}
