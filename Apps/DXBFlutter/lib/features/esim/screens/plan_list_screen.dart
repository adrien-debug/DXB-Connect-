import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/premium_widgets.dart';
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
    HapticFeedback.lightImpact();
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
        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md,
      ),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
                  hintStyle: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 15),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
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

  static const _popularNames = [
    'United Arab Emirates',
    'United States',
    'United Kingdom',
    'France',
    'Japan',
    'Thailand',
    'Turkey',
    'Saudi Arabia',
  ];

  static const _regionMap = <String, List<String>>{
    'Middle East': ['United Arab Emirates', 'Saudi Arabia', 'Qatar', 'Bahrain', 'Oman', 'Kuwait', 'Jordan', 'Lebanon', 'Iraq', 'Iran', 'Israel', 'Palestine', 'Yemen', 'Syria'],
    'Europe': ['France', 'Germany', 'United Kingdom', 'Spain', 'Italy', 'Netherlands', 'Belgium', 'Switzerland', 'Austria', 'Portugal', 'Greece', 'Sweden', 'Norway', 'Denmark', 'Finland', 'Ireland', 'Poland', 'Czech Republic', 'Romania', 'Hungary', 'Croatia', 'Turkey', 'Iceland', 'Luxembourg', 'Bulgaria', 'Slovakia', 'Slovenia', 'Estonia', 'Latvia', 'Lithuania', 'Malta', 'Cyprus', 'Serbia', 'Albania', 'Montenegro', 'North Macedonia', 'Bosnia and Herzegovina', 'Moldova', 'Ukraine', 'Georgia'],
    'Asia': ['Japan', 'South Korea', 'China', 'Thailand', 'Vietnam', 'Malaysia', 'Singapore', 'Indonesia', 'Philippines', 'India', 'Taiwan', 'Hong Kong', 'Macau', 'Cambodia', 'Laos', 'Myanmar', 'Sri Lanka', 'Bangladesh', 'Nepal', 'Pakistan', 'Mongolia', 'Kazakhstan', 'Uzbekistan', 'Brunei'],
    'Americas': ['United States', 'Canada', 'Mexico', 'Brazil', 'Argentina', 'Colombia', 'Chile', 'Peru', 'Costa Rica', 'Panama', 'Ecuador', 'Uruguay', 'Dominican Republic', 'Puerto Rico', 'Guatemala', 'Honduras', 'El Salvador', 'Nicaragua', 'Bolivia', 'Paraguay', 'Venezuela', 'Cuba', 'Jamaica', 'Trinidad and Tobago'],
    'Africa': ['South Africa', 'Egypt', 'Morocco', 'Tunisia', 'Kenya', 'Nigeria', 'Ghana', 'Tanzania', 'Ethiopia', 'Algeria', 'Senegal', 'Ivory Coast', 'Uganda', 'Rwanda', 'Cameroon', 'Mozambique', 'Madagascar', 'Mauritius'],
    'Oceania': ['Australia', 'New Zealand', 'Fiji', 'Papua New Guinea'],
  };

  static const _regionIcons = <String, IconData>{
    'Middle East': Icons.mosque_rounded,
    'Europe': Icons.account_balance_rounded,
    'Asia': Icons.temple_buddhist_rounded,
    'Americas': Icons.location_city_rounded,
    'Africa': Icons.public_rounded,
    'Oceania': Icons.beach_access_rounded,
  };

  static const _regionOrder = ['Middle East', 'Europe', 'Asia', 'Americas', 'Africa', 'Oceania'];

  String _regionFor(String name) {
    for (final entry in _regionMap.entries) {
      if (entry.value.contains(name)) return entry.key;
    }
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    if (countries.isEmpty) {
      return const EmptyView(
        title: 'No countries found',
        subtitle: 'Try a different search',
        icon: Icons.search_off_rounded,
      );
    }

    final popular =
        countries.where((c) => _popularNames.contains(c.name)).toList();

    final grouped = <String, List<CountryEntry>>{};
    for (final country in countries) {
      final region = _regionFor(country.name);
      grouped.putIfAbsent(region, () => []).add(country);
    }
    final regionSections = <MapEntry<String, List<CountryEntry>>>[];
    for (final r in [..._regionOrder, 'Other']) {
      if (grouped.containsKey(r) && grouped[r]!.isNotEmpty) {
        regionSections.add(MapEntry(r, grouped[r]!));
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            '${countries.length} destinations',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (popular.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionHeader(icon: Icons.local_fire_department_rounded, title: 'Popular', count: popular.length),
          const SizedBox(height: 8),
          _CountryGridBlock(countries: popular, onSelect: onSelect),
        ],
        ...regionSections.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                _SectionHeader(
                  icon: _regionIcons[entry.key] ?? Icons.language_rounded,
                  title: entry.key,
                  count: entry.value.length,
                ),
                const SizedBox(height: 8),
                _CountryGridBlock(
                    countries: entry.value, onSelect: onSelect),
              ],
            )),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryGridBlock extends StatelessWidget {
  final List<CountryEntry> countries;
  final ValueChanged<CountryEntry> onSelect;

  const _CountryGridBlock({required this.countries, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.92,
        ),
        itemCount: countries.length,
        itemBuilder: (_, index) {
          final country = countries[index];
          return _CountryTile(
            country: country,
            onTap: () => onSelect(country),
          );
        },
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final CountryEntry country;
  final VoidCallback onTap;

  const _CountryTile({required this.country, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final flag = country.code.isNotEmpty
        ? flagEmoji(country.code)
        : flagFromName(country.name);

    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              country.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                '\$${country.startingPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
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
        AppSpacing.lg, 0, AppSpacing.lg, 120,
      ),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                      color: AppColors.surfaceBorder, width: 0.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left_rounded,
                        size: 16, color: AppColors.accent),
                    SizedBox(width: 2),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                      color: AppColors.surfaceBorder, width: 0.5),
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
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
              Text(flag, style: const TextStyle(fontSize: 38)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (plans.isEmpty)
          const EmptyView(
            title: 'No plans available',
            subtitle: 'Check back later for plans in this region',
            icon: Icons.sim_card_outlined,
          )
        else
          ...plans.map((plan) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PlanCard(
                plan: plan,
                isBest: isBestValue(plan),
                onTap: () {
                  HapticFeedback.lightImpact();
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
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isBest
                ? AppColors.accent.withValues(alpha: 0.25)
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
                      Flexible(
                        child: Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBest) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text(
                            'BEST',
                            style: TextStyle(
                              fontSize: 8,
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
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Text(
                            '5G',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SpecChip(
                        icon: Icons.download_rounded,
                        text: '${plan.dataGB.toStringAsFixed(plan.dataGB == plan.dataGB.roundToDouble() ? 0 : 1)} GB',
                      ),
                      const SizedBox(width: 14),
                      _SpecChip(
                        icon: Icons.schedule_rounded,
                        text: '${plan.durationDays}d',
                      ),
                      if (plan.speed != null &&
                          !plan.speed!.toLowerCase().contains('5g')) ...[
                        const SizedBox(width: 14),
                        _SpecChip(
                          icon: Icons.cell_tower_rounded,
                          text: plan.speed!,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${plan.priceUSD.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${(plan.priceUSD / plan.dataGB.clamp(1, double.infinity)).toStringAsFixed(2)}/GB',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SpecChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
