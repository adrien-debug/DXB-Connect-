import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/esim_cards_row.dart';
import '../widgets/subscription_promo_banner.dart';
import '../widgets/offers_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final dashboard = ref.read(dashboardProvider);
      if (dashboard.esims.isEmpty && !dashboard.isLoading) {
        ref.read(dashboardProvider.notifier).loadDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: dashboard.isLoading && dashboard.esims.isEmpty
          ? const _DashboardShimmer()
          : RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              onRefresh: () =>
                  ref.read(dashboardProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          DashboardHeader(
                            userName: userName,
                            tier: dashboard.subscription?.plan,
                            wallet: dashboard.wallet,
                            esimCount: dashboard.esims.length,
                            activeCount: dashboard.activeCount,
                          ),
                          const SizedBox(height: 12),
                          BalanceCard(
                            remainingGB: dashboard.totalRemainingGB,
                            usagePercent: dashboard.usagePercent,
                            esimCount: dashboard.esims.length,
                            activeCount: dashboard.activeCount,
                            countriesCount: dashboard.countriesCount,
                            isLoaded: dashboard.usageCache.isNotEmpty ||
                                dashboard.esims.isEmpty,
                          ),
                          const SizedBox(height: 16),
                          if (dashboard.error != null)
                            _ErrorBanner(
                              message: dashboard.error!,
                              onRetry: () => ref
                                  .read(dashboardProvider.notifier)
                                  .loadDashboard(),
                            ),
                          EsimCardsRow(
                            esims: dashboard.activeEsims,
                          ),
                          if (dashboard.subscription == null) ...[
                            const SizedBox(height: 16),
                            SubscriptionPromoBanner(
                              onTap: () => context.go('/dashboard/subscription'),
                            ),
                          ],
                          if (dashboard.offers.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            OffersSection(
                              offers: dashboard.offers,
                              onViewAll: () => context.go('/dashboard/offers'),
                            ),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const ShimmerCard(height: 120),
            const SizedBox(height: 12),
            const ShimmerCard(height: 140),
            const SizedBox(height: 16),
            ShimmerBox(width: 60, height: 10, radius: 4),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: ShimmerCard(height: 60)),
                const SizedBox(width: 10),
                Expanded(child: ShimmerCard(height: 60)),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerCard(height: 56),
            const SizedBox(height: 20),
            ShimmerBox(width: 80, height: 10, radius: 4),
            const SizedBox(height: 8),
            const ShimmerCard(height: 120),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              size: 14,
              color: AppColors.accent,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12,
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
