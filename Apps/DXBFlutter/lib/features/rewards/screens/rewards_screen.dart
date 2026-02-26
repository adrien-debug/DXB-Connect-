import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/rewards_models.dart';
import '../providers/rewards_provider.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int _selectedTab = 0;
  bool _checkinDone = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(rewardsProvider.notifier).loadRewards());
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(rewardsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Rewards')),
      body: data.isLoading && data.summary == null
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              onRefresh: () => ref.read(rewardsProvider.notifier).loadRewards(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  const SizedBox(height: AppSpacing.base),
                  if (data.error != null)
                    _ErrorBanner(message: data.error!, onDismiss: () => ref.read(rewardsProvider.notifier).clearError()),
                  _WalletHero(data: data),
                  const SizedBox(height: AppSpacing.lg),
                  _CheckinCard(
                    streakDays: data.wallet?.streakDays ?? 0,
                    isDone: _checkinDone,
                    onCheckin: _performCheckin,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _TabSelector(
                    selectedIndex: _selectedTab,
                    onChanged: (i) => setState(() => _selectedTab = i),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_selectedTab == 0) _MissionsContent(missions: data.missions),
                  if (_selectedTab == 1) _RafflesContent(raffles: data.raffles, ticketBalance: data.wallet?.ticketsBalance ?? 0, onEnter: _enterRaffle),
                  if (_selectedTab == 2) _HistoryContent(transactions: data.transactions),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  Future<void> _performCheckin() async {
    HapticFeedback.mediumImpact();
    final success = await ref.read(rewardsProvider.notifier).dailyCheckin();
    if (success && mounted) {
      HapticFeedback.heavyImpact();
      setState(() => _checkinDone = true);
    }
  }

  Future<void> _enterRaffle(Raffle raffle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Enter Raffle'),
        content: Text('Use 1 ticket to enter "${raffle.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Use 1 ticket')),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await ref.read(rewardsProvider.notifier).enterRaffle(raffle.id);
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, size: 14, color: AppColors.error),
          const SizedBox(width: 6),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
          GestureDetector(onTap: onDismiss, child: const Icon(Icons.close, size: 14, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _WalletHero extends StatelessWidget {
  final RewardsData data;
  const _WalletHero({required this.data});

  @override
  Widget build(BuildContext context) {
    final wallet = data.wallet;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F14),
            Color(0xFF141414),
            Color(0xFF121216),
          ],
        ),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      _walletStat(Icons.star_rounded, wallet?.xpTotal ?? 0, 'XP', AppColors.warning),
                      _StatDivider(),
                      _walletStat(Icons.monetization_on_rounded, wallet?.pointsBalance ?? 0, 'POINTS', AppColors.accent),
                      _StatDivider(),
                      _walletStat(Icons.confirmation_num_rounded, wallet?.ticketsBalance ?? 0, 'TICKETS', AppColors.info),
                    ],
                  ),
                  if (wallet != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      height: 0.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Row(
                      children: [
                        _TierBadge(tier: wallet.tier),
                        const SizedBox(width: 10),
                        Text(
                          'Level ${wallet.level}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 70,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: data.levelProgress),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (_, value, __) => LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white.withValues(alpha: 0.06),
                                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                                minHeight: 5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(data.levelProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletStat(IconData icon, int value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: 14, color: color.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) => Text(
              '${val.toInt()}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  const _TierBadge({required this.tier});

  Color get _color {
    switch (tier.toLowerCase()) {
      case 'silver': return const Color(0xFFC0C0C0);
      case 'gold': return const Color(0xFFFFD700);
      case 'platinum': return const Color(0xFFE5E4E2);
      default: return const Color(0xFFCD7F32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Text(tier.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: _color)),
    );
  }
}

class _CheckinCard extends StatelessWidget {
  final int streakDays;
  final bool isDone;
  final VoidCallback onCheckin;
  const _CheckinCard({required this.streakDays, required this.isDone, required this.onCheckin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDone
              ? AppColors.accent.withValues(alpha: 0.2)
              : AppColors.surfaceBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.warning.withValues(alpha: 0.2),
                  AppColors.warning.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 22,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streakDays day${streakDays != 1 ? 's' : ''} streak',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isDone ? 'See you tomorrow!' : 'Tap to check in',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 38,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton.icon(
                onPressed: isDone ? null : onCheckin,
                icon: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                  size: 16,
                ),
                label: Text(
                  isDone ? 'Done!' : 'Check-in',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _TabSelector({required this.selectedIndex, required this.onChanged});

  static const _tabs = [
    (Icons.gps_fixed_rounded, 'Missions'),
    (Icons.confirmation_num_rounded, 'Raffles'),
    (Icons.access_time_rounded, 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == selectedIndex;
          final (icon, label) = _tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 10, color: selected ? Colors.black : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.w500, color: selected ? Colors.black : AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MissionsContent extends StatelessWidget {
  final List<Mission> missions;
  const _MissionsContent({required this.missions});

  @override
  Widget build(BuildContext context) {
    if (missions.isEmpty) {
      return _emptyState(Icons.gps_fixed_rounded, 'No missions', 'New missions will be available soon');
    }
    return Column(children: missions.map((m) => _MissionCard(mission: m)).toList());
  }
}

class _MissionCard extends StatelessWidget {
  final Mission mission;
  const _MissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final progress = mission.userProgress / 1.clamp(1, 999999);
    return Opacity(
      opacity: mission.userCompleted ? 0.65 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(mission.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ]),
            ),
            if (mission.userCompleted) const Icon(Icons.verified_rounded, size: 22, color: AppColors.success),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1).toDouble(),
                  backgroundColor: AppColors.surfaceBorder,
                  valueColor: AlwaysStoppedAnimation(mission.userCompleted ? AppColors.success : AppColors.accent),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${mission.userProgress}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            if (mission.xpReward > 0) ...[
              Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
              const SizedBox(width: 3),
              Text('+${mission.xpReward} XP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
              const SizedBox(width: 14),
            ],
            if (mission.pointsReward > 0) ...[
              Icon(Icons.monetization_on_rounded, size: 12, color: AppColors.accent),
              const SizedBox(width: 3),
              Text('+${mission.pointsReward} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
            ],
          ]),
        ]),
      ),
    );
  }
}

class _RafflesContent extends StatelessWidget {
  final List<Raffle> raffles;
  final int ticketBalance;
  final Future<void> Function(Raffle) onEnter;
  const _RafflesContent({required this.raffles, required this.ticketBalance, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    if (raffles.isEmpty) {
      return _emptyState(Icons.confirmation_num_rounded, 'No active raffles', 'Come back soon for exclusive giveaways', assetImage: 'assets/images/empty_rewards.png');
    }
    return Column(children: raffles.map((r) => _RaffleCard(raffle: r, canEnter: ticketBalance >= 1, onEnter: () => onEnter(r))).toList());
  }
}

class _RaffleCard extends StatelessWidget {
  final Raffle raffle;
  final bool canEnter;
  final VoidCallback onEnter;
  const _RaffleCard({required this.raffle, required this.canEnter, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (raffle.imageUrl != null)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            child: Image.network(raffle.imageUrl!, height: 110, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 110, color: AppColors.surfaceLight)),
          ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(raffle.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(raffle.prizeDescription, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            if (raffle.drawDate != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.accent),
                const SizedBox(width: 4),
                Text('Draw: ${raffle.drawDate!.substring(0, 10)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.accent)),
              ]),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity, height: 40,
              child: ElevatedButton.icon(
                onPressed: canEnter ? onEnter : null,
                icon: const Icon(Icons.confirmation_num_rounded, size: 14),
                label: const Text('Enter (1 ticket)'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  final List<RewardsTransaction> transactions;
  const _HistoryContent({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _emptyState(Icons.access_time_rounded, 'No transactions', 'Your reward activity will appear here');
    }
    return Column(children: transactions.map((t) => _TransactionRow(tx: t)).toList());
  }
}

class _TransactionRow extends StatelessWidget {
  final RewardsTransaction tx;
  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final positive = tx.delta > 0;
    final color = positive ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.08)),
          child: Icon(positive ? Icons.arrow_downward : Icons.arrow_upward, size: 13, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.reason ?? tx.type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            if (tx.description != null) Text(tx.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ]),
        ),
        Text('${positive ? "+" : ""}${tx.delta}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}

Widget _emptyState(IconData icon, String title, String subtitle, {String? assetImage}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(children: [
        if (assetImage != null)
          Image.asset(
            assetImage,
            width: 140,
            height: 140,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(icon, size: 40, color: AppColors.textTertiary),
          )
        else
          Icon(icon, size: 40, color: AppColors.textTertiary),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
      ]),
    ),
  );
}
