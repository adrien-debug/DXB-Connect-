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
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/empty_esim.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.sim_card_outlined,
                    size: 64,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'No eSIMs yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get connected anywhere in the world\nwith your first eSIM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/dashboard/plans'),
                    icon: const Icon(Icons.explore_rounded, size: 18),
                    label: const Text(
                      'Browse Plans',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
