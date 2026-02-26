import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/world_map_painter.dart';
import '../../rewards/models/rewards_models.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String? tier;
  final RewardsWallet? wallet;
  final int esimCount;
  final int activeCount;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.tier,
    this.wallet,
    this.esimCount = 0,
    this.activeCount = 0,
    this.onNotificationTap,
  });

  String get _firstName => userName.split(' ').first;

  String get _initial =>
      _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U';

  String get _tierLabel => (tier ?? wallet?.tier ?? 'explorer').toUpperCase();

  @override
  Widget build(BuildContext context) {
    final points = wallet?.pointsBalance ?? 0;
    final xp = wallet?.xpTotal ?? 0;
    final level = wallet?.level ?? 1;
    final streak = wallet?.streakDays ?? 0;
    final tickets = wallet?.ticketsBalance ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WorldMapPainter(
                dotColor: AppColors.accent.withValues(alpha: 0.18),
                dotRadius: 1.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent,
                      ),
                      child: Center(
                        child: Text(
                          _initial,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _firstName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                  color: AppColors.accent.withValues(alpha: 0.12),
                                ),
                                child: Text(
                                  _tierLabel,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'LVL $level',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onNotificationTap,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceLight,
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 0.5, color: AppColors.surfaceBorder),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatCell(
                      value: _formatNumber(points),
                      label: 'POINTS',
                    ),
                    _divider(),
                    _StatCell(
                      value: _formatNumber(xp),
                      label: 'XP',
                    ),
                    _divider(),
                    _StatCell(
                      value: '$streak',
                      label: 'STREAK',
                    ),
                    _divider(),
                    _StatCell(
                      value: '$tickets',
                      label: 'TICKETS',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(1)}k';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  Widget _divider() {
    return Container(
      width: 0.5,
      height: 28,
      color: AppColors.surfaceBorder,
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;

  const _StatCell({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
