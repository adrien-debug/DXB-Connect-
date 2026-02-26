import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../models/esim_models.dart';
import '../providers/plans_provider.dart';
import '../widgets/country_helper.dart';
import 'plan_detail_screen.dart';

class PlanListScreen extends ConsumerStatefulWidget {
  const PlanListScreen({super.key});

  @override
  ConsumerState<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends ConsumerState<PlanListScreen> {
  String _search = '';
  CountryEntry? _selectedCountry;
  SortOption _sortOption = SortOption.priceAsc;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final data = ref.read(plansProvider);
      if (data.allPlans.isEmpty && !data.isLoading) {
        ref.read(plansProvider.notifier).loadPlans();
      }
    });
  }

  void _selectCountry(CountryEntry country) {
    setState(() {
      _selectedCountry = country;
      _search = '';
    });
  }

  void _goBack() {
    setState(() {
      _selectedCountry = null;
      _search = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(plansProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _selectedCountry == null ? 'Browse Plans' : '',
        ),
      ),
      body: Column(
        children: [
          _SearchBar(
            hint: _selectedCountry == null
                ? 'Search country...'
                : 'Search plans...',
            value: _search,
            onChanged: (v) => setState(() => _search = v),
          ),
          Expanded(
            child: data.isLoading && data.allPlans.isEmpty
                ? const Center(child: LoadingIndicator())
                : data.error != null && data.allPlans.isEmpty
                    ? ErrorView(
                        message: data.error!,
                        onRetry: () =>
                            ref.read(plansProvider.notifier).loadPlans(),
                      )
                    : _selectedCountry != null
                        ? _CountryPlansView(
                            country: _selectedCountry!,
                            plans: data.plansForCountry(
                              _selectedCountry!.name,
                              sort: _sortOption,
                            ),
                            sortOption: _sortOption,
                            onSortChanged: (s) =>
                                setState(() => _sortOption = s),
                            onBack: _goBack,
                            isBestValue: data.isBestValue,
                          )
                        : _CountriesGrid(
                            countries: data.countries(search: _search),
                            onSelect: _selectCountry,
                          ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                size: 18, color: AppColors.textTertiary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      const TextStyle(color: AppColors.textTertiary, fontSize: 15),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15),
                onChanged: onChanged,
              ),
            ),
            if (value.isNotEmpty)
              GestureDetector(
                onTap: () => onChanged(''),
                child: const Icon(Icons.close_rounded,
                    size: 18, color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountriesGrid extends StatelessWidget {
  final List<CountryEntry> countries;
  final ValueChanged<CountryEntry> onSelect;

  const _CountriesGrid({required this.countries, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (countries.isEmpty) {
      return const EmptyView(
        title: 'No countries found',
        subtitle: 'Try a different search',
        icon: Icons.search_off_rounded,
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          120,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.base),
            child: Text(
              '${countries.length} destinations',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.85,
            ),
            itemCount: countries.length,
            itemBuilder: (_, index) {
              final country = countries[index];
              return _CountryCard(
                country: country,
                onTap: () => onSelect(country),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CountryCard extends StatelessWidget {
  final CountryEntry country;
  final VoidCallback onTap;

  const _CountryCard({required this.country, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final flag = country.code.isNotEmpty
        ? flagEmoji(country.code)
        : flagFromName(country.name);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              country.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              '${country.planCount} plan${country.planCount > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'From \$${country.startingPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryPlansView extends StatelessWidget {
  final CountryEntry country;
  final List<EsimPlan> plans;
  final SortOption sortOption;
  final ValueChanged<SortOption> onSortChanged;
  final VoidCallback onBack;
  final bool Function(EsimPlan) isBestValue;

  const _CountryPlansView({
    required this.country,
    required this.plans,
    required this.sortOption,
    required this.onSortChanged,
    required this.onBack,
    required this.isBestValue,
  });

  @override
  Widget build(BuildContext context) {
    final flag = country.code.isNotEmpty
        ? flagEmoji(country.code)
        : flagFromName(country.name);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        120,
      ),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: const Row(
                children: [
                  Icon(Icons.chevron_left_rounded,
                      size: 18, color: AppColors.accent),
                  Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PopupMenuButton<SortOption>(
              onSelected: onSortChanged,
              color: AppColors.surface,
              itemBuilder: (_) => SortOption.values
                  .map((s) => PopupMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Text(s.label),
                            const Spacer(),
                            if (s == sortOption)
                              const Icon(Icons.check_rounded,
                                  size: 16, color: AppColors.accent),
                          ],
                        ),
                      ))
                  .toList(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort_rounded,
                        size: 14, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      sortOption.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${country.planCount} plan${country.planCount > 1 ? 's' : ''} available',
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
                  const Text(
                    'From',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '\$${country.startingPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (plans.isEmpty)
          const EmptyView(
            title: 'No plans available',
            subtitle: 'Check back later for plans in this region',
            icon: Icons.sim_card_outlined,
          )
        else
          ...plans.map((plan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PlanCard(
                plan: plan,
                isBest: isBestValue(plan),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlanDetailScreen(plan: plan),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final EsimPlan plan;
  final bool isBest;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isBest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isBest
                ? AppColors.accent.withValues(alpha: 0.2)
                : AppColors.surfaceBorder,
            width: isBest ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isBest) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text(
                            'BEST',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      if (plan.speed != null &&
                          plan.speed!.toLowerCase().contains('5g')) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text(
                            '5G',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _specChip(Icons.download_rounded,
                          '${plan.dataGB.toStringAsFixed(plan.dataGB == plan.dataGB.roundToDouble() ? 0 : 1)} GB'),
                      const SizedBox(width: 12),
                      _specChip(
                          Icons.schedule_rounded, '${plan.durationDays} days'),
                      if (plan.speed != null &&
                          !plan.speed!.toLowerCase().contains('5g')) ...[
                        const SizedBox(width: 12),
                        _specChip(Icons.cell_tower_rounded, plan.speed!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${plan.priceUSD.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${(plan.priceUSD / plan.dataGB.clamp(1, double.infinity)).toStringAsFixed(2)}/GB',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _specChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
