import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../providers/esim_provider.dart';
import '../models/esim_models.dart';
import '../widgets/esim_status_badge.dart';
import '../widgets/country_helper.dart';

enum _EsimFilter { all, active, expired }

class EsimListScreen extends ConsumerStatefulWidget {
  const EsimListScreen({super.key});

  @override
  ConsumerState<EsimListScreen> createState() => _EsimListScreenState();
}

class _EsimListScreenState extends ConsumerState<EsimListScreen> {
  _EsimFilter _filter = _EsimFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final data = ref.read(esimListProvider);
      if (data.esims.isEmpty && !data.isLoading) {
        ref.read(esimListProvider.notifier).loadEsims();
      }
    });
  }

  List<EsimOrder> _filtered(EsimListData data) {
    switch (_filter) {
      case _EsimFilter.all:
        return data.esims;
      case _EsimFilter.active:
        return data.activeEsims;
      case _EsimFilter.expired:
        return data.expiredEsims;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(esimListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My eSIMs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.accent, size: 26),
            onPressed: () => context.go('/dashboard/plans'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(esimListProvider.notifier).loadEsims(),
        child: data.isLoading && data.esims.isEmpty
            ? const Center(child: LoadingIndicator())
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _StatsRow(data: data),
                          const SizedBox(height: AppSpacing.lg),
                          _FilterPills(
                            selected: _filter,
                            onChanged: (f) => setState(() => _filter = f),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildList(data),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildList(EsimListData data) {
    final esims = _filtered(data);

    if (data.error != null && esims.isEmpty) {
      return SliverFillRemaining(
        child: ErrorView(
          message: data.error!,
          onRetry: () => ref.read(esimListProvider.notifier).loadEsims(),
        ),
      );
    }

    if (esims.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyStateWithPromos(
          onBrowsePlans: () => context.go('/dashboard/plans'),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList.separated(
        itemCount: esims.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final esim = esims[index];
          return _EsimCard(
            esim: esim,
            usage: data.usageCache[esim.iccid],
            onTap: () => context.push('/esims/${esim.orderNo}', extra: esim),
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final EsimListData data;

  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(
          icon: Icons.sim_card_rounded,
          value: '${data.esims.length}',
          label: 'Total',
        ),
        const SizedBox(width: AppSpacing.md),
        _StatBox(
          icon: Icons.check_circle_rounded,
          value: '${data.activeEsims.length}',
          label: 'Active',
        ),
        const SizedBox(width: AppSpacing.md),
        _StatBox(
          icon: Icons.public_rounded,
          value: '${data.esims.map((e) => e.packageName).toSet().length}',
          label: 'Countries',
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: AppColors.accent.withValues(alpha: 0.7)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
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

class _FilterPills extends StatelessWidget {
  final _EsimFilter selected;
  final ValueChanged<_EsimFilter> onChanged;

  const _FilterPills({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _EsimFilter.values.map((filter) {
        final isSelected = filter == selected;
        final label = filter.name[0].toUpperCase() + filter.name.substring(1);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(filter);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.surfaceBorder,
                  width: 0.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyStateWithPromos extends StatelessWidget {
  final VoidCallback onBrowsePlans;

  const _EmptyStateWithPromos({required this.onBrowsePlans});

  static const _promos = [
    _PromoDestination(flag: '🇫🇷', name: 'France', price: 6, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇯🇵', name: 'Japan', price: 6, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇺🇸', name: 'USA', price: 5, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇦🇪', name: 'UAE', price: 7, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇹🇭', name: 'Thailand', price: 5, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇬🇧', name: 'UK', price: 5, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇪🇸', name: 'Spain', price: 5, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇩🇪', name: 'Germany', price: 5, data: '1 GB', days: 7),
    _PromoDestination(flag: '🇮🇹', name: 'Italy', price: 5, data: '1 GB', days: 7),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.sim_card_outlined,
                  size: 40,
                  color: AppColors.accent.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No eSIMs yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Get connected anywhere in the world',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'POPULAR DESTINATIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.88,
            ),
            itemCount: _promos.length,
            itemBuilder: (context, index) {
              final promo = _promos[index];
              return GestureDetector(
                onTap: onBrowsePlans,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                        color: AppColors.surfaceBorder, width: 0.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        promo.flag,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        promo.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'From \$${promo.price}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onBrowsePlans,
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text(
                'Browse All Plans',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _PromoDestination {
  final String flag;
  final String name;
  final int price;
  final String data;
  final int days;

  const _PromoDestination({
    required this.flag,
    required this.name,
    required this.price,
    required this.data,
    required this.days,
  });
}

class _EsimCard extends StatelessWidget {
  final EsimOrder esim;
  final EsimUsage? usage;
  final VoidCallback onTap;

  const _EsimCard({
    required this.esim,
    this.usage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = esim.smdpStatus ?? esim.status ?? '';
    final color = EsimStatusBadge.statusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.sim_card_rounded, size: 17, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esim.packageName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatVolume(esim.totalVolume),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                EsimStatusBadge(status: status),
                if (usage != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${usage!.usagePercent.round()}% used',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
