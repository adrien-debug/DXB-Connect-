import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/premium_widgets.dart';
import '../../../core/widgets/world_map_painter.dart';
import '../../rewards/models/rewards_models.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String? tier;
  final RewardsWallet? wallet;
  final int esimCount;
  final int activeCount;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.tier,
    this.wallet,
    this.esimCount = 0,
    this.activeCount = 0,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  String get _firstName => userName.split(' ').first;

  String get _initial =>
      _firstName.isNotEmpty ? _firstName[0].toUpperCase() : 'U';

  String get _tierLabel => (tier ?? wallet?.tier ?? 'explorer').toUpperCase();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final points = wallet?.pointsBalance ?? 0;
    final xp = wallet?.xpTotal ?? 0;
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
                dotColor: AppColors.accent.withValues(alpha: 0.28),
                dotRadius: 1.8,
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
                            '$_greeting, $_firstName',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
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
                                  color:
                                      AppColors.accent.withValues(alpha: 0.12),
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
                                'LVL ${wallet?.level ?? 1}',
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
                    _NotificationBell(
                      count: notificationCount,
                      onTap: onNotificationTap,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 0.5, color: AppColors.surfaceBorder),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _AnimatedStatCell(value: points, label: 'POINTS'),
                    _divider(),
                    _AnimatedStatCell(value: xp, label: 'XP'),
                    _divider(),
                    _AnimatedStatCell(value: streak, label: 'STREAK'),
                    _divider(),
                    _AnimatedStatCell(value: tickets, label: 'TICKETS'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 0.5,
      height: 28,
      color: AppColors.surfaceBorder,
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationBell({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 42,
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
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
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatCell extends StatelessWidget {
  final int value;
  final String label;

  const _AnimatedStatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AnimatedCounter(
            value: value,
            suffix: '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: -0.5,
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
