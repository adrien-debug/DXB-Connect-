import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../esim/models/esim_models.dart';

class EsimCardsRow extends StatelessWidget {
  final List<EsimOrder> esims;

  const EsimCardsRow({super.key, required this.esims});

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
          height: 68,
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
                        child: _SimBadge(esim: esim),
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

class _SimBadge extends StatelessWidget {
  final EsimOrder esim;

  const _SimBadge({required this.esim});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            esim.packageName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isActive ? AppColors.accent : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: _isActive ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySimPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptySimPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            Icon(Icons.add_circle_outline_rounded, size: 20, color: AppColors.accent),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
            SizedBox(height: 2),
            Text(
              'Add',
              style: TextStyle(
                fontSize: 9,
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
