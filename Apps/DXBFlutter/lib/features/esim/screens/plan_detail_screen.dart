import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/esim_models.dart';
import '../widgets/country_helper.dart';

class PlanDetailScreen extends ConsumerStatefulWidget {
  final EsimPlan plan;

  const PlanDetailScreen({super.key, required this.plan});

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  bool _isPurchasing = false;

  EsimPlan get plan => widget.plan;

  Future<void> _purchase() async {
    setState(() => _isPurchasing = true);

    final authState = ref.read(authProvider);
    final checkoutService = ref.read(checkoutServiceProvider);

    final result = await checkoutService.purchaseEsim(
      packageCode: plan.id,
      packageName: plan.name,
      price: plan.priceUSD,
      customerEmail: authState.user?.email ?? '',
      customerName: authState.user?.name ?? 'Customer',
    );

    setState(() => _isPurchasing = false);
    if (!mounted) return;

    if (result.success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('eSIM Purchased!'),
          content: Text(
            'Your eSIM ${plan.name} is ready. Scan the QR code to install it.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('View my eSIM'),
            ),
          ],
        ),
      );
    } else {
      if (result.error == 'Payment cancelled') return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Purchase failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final flag = plan.locationCode.isNotEmpty
        ? flagEmoji(plan.locationCode)
        : flagFromName(plan.location);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'PLAN DETAILS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _HeroSection(plan: plan, flag: flag),
                const SizedBox(height: 16),
                _SpecsSection(plan: plan),
                const SizedBox(height: 16),
                _FeaturesSection(),
                const SizedBox(height: 16),
                _PurchaseSection(
                  plan: plan,
                  isPurchasing: _isPurchasing,
                  onPurchase: _purchase,
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          if (_isPurchasing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Preparing your eSIM...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final EsimPlan plan;
  final String flag;

  const _HeroSection({required this.plan, required this.flag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.08),
                ),
              ),
              Text(flag, style: const TextStyle(fontSize: 64)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            plan.location,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.name,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              Text(
                plan.priceUSD.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecsSection extends StatelessWidget {
  final EsimPlan plan;

  const _SpecsSection({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _SpecItem(
            icon: Icons.download_rounded,
            value: plan.dataGB.toStringAsFixed(plan.dataGB == plan.dataGB.roundToDouble() ? 0 : 1),
            unit: 'GB',
            label: 'DATA',
          ),
          Container(width: 1, height: 60, color: AppColors.surfaceBorder),
          _SpecItem(
            icon: Icons.calendar_today_rounded,
            value: '${plan.durationDays}',
            unit: 'days',
            label: 'VALIDITY',
          ),
          Container(width: 1, height: 60, color: AppColors.surfaceBorder),
          _SpecItem(
            icon: Icons.bolt_rounded,
            value: plan.speed ?? '4G',
            unit: '',
            label: 'NETWORK',
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;

  const _SpecItem({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  static const _features = [
    'Instant QR code installation',
    'Hotspot / Tethering supported',
    '24/7 customer support',
    'Compatible with iPhone XS and newer',
    'Top-up anytime',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INCLUDED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text(
                      f,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PurchaseSection extends StatelessWidget {
  final EsimPlan plan;
  final bool isPurchasing;
  final VoidCallback onPurchase;

  const _PurchaseSection({
    required this.plan,
    required this.isPurchasing,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: isPurchasing ? null : onPurchase,
            icon: const Icon(Icons.credit_card_rounded),
            label: const Text('Buy Now'),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, size: 10, color: AppColors.textTertiary),
            SizedBox(width: 6),
            Text(
              'Secure payment via Stripe',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }
}
