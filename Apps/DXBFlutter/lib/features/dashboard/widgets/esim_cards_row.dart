import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../esim/models/esim_models.dart';
import '../../esim/widgets/country_helper.dart';

class EsimCardsRow extends StatelessWidget {
  final List<EsimOrder> esims;
  final Map<String, EsimUsage> usageCache;

  const EsimCardsRow({
    super.key,
    required this.esims,
    this.usageCache = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              const Text(
                'MY SIMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              if (esims.isNotEmpty)
                GestureDetector(
                  onTap: () => context.go('/esims'),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              if (esims.isEmpty)
                _EmptySimPrompt(
                  onTap: () => context.go('/dashboard/plans'),
                )
              else ...[
                ...esims.take(5).map(
                      (esim) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _SimCard(
                          esim: esim,
                          usage: usageCache[esim.iccid],
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.go('/esims/${esim.orderNo}');
                          },
                        ),
                      ),
                    ),
                _AddSimBadge(
                  onTap: () => context.go('/dashboard/plans'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SimCard extends StatelessWidget {
  final EsimOrder esim;
  final EsimUsage? usage;
  final VoidCallback? onTap;

  const _SimCard({required this.esim, this.usage, this.onTap});

  bool get _isActive => esim.isActive;

  String get _statusLabel {
    final status = esim.smdpStatus ?? esim.status ?? '';
    switch (status.toUpperCase()) {
      case 'RELEASED':
      case 'IN_USE':
      case 'ENABLED':
      case 'ACTIVE':
        return 'ACTIVE';
      case 'SUSPENDED':
        return 'PAUSED';
      default:
        return status.toUpperCase();
    }
  }

  String get _countryName {
    final name = esim.packageName;
    final parts = name.split(' ');
    return parts.isNotEmpty ? parts.first : 'eSIM';
  }

  String get _flag => flagFromName(esim.packageName);

  String get _remainingLabel {
    if (usage == null) return '';
    return formatVolume(usage!.remainingData);
  }

  double get _usageFraction {
    if (usage == null) return 0;
    if (usage!.totalVolume == 0) return 0;
    return (usage!.orderUsage / usage!.totalVolume).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _isActive
                ? AppColors.accent.withValues(alpha: 0.25)
                : AppColors.surfaceBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _countryName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _isActive ? AppColors.accent : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color:
                        _isActive ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (_remainingLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                _remainingLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
            const SizedBox(height: 6),
            _MiniProgressBar(fraction: _usageFraction),
          ],
        ),
      ),
    );
  }
}

class _MiniProgressBar extends StatelessWidget {
  final double fraction;
  const _MiniProgressBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final fillWidth = (width * fraction).clamp(0.0, width);
        return Container(
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.5),
            color: AppColors.surfaceBorder,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: fillWidth,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
                color: AppColors.accent,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptySimPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptySimPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                size: 20, color: AppColors.accent),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get your first eSIM',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Browse plans →',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _AddSimBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _AddSimBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 22, color: AppColors.accent),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
