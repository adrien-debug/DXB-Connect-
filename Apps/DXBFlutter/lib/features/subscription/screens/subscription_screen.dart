import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  SubPlan _selectedPlan = SubPlan.elite;
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(subscriptionActionProvider);
    final dashboard = ref.watch(dashboardProvider);
    final hasSub = dashboard.subscription != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SUBSCRIPTION',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                letterSpacing: 2, color: AppColors.textSecondary)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                _HeroSection(),
                if (!hasSub) ...[
                  const SizedBox(height: 10),
                  _BillingToggle(
                    isAnnual: _isAnnual,
                    onChanged: (v) => setState(() => _isAnnual = v),
                  ),
                  const SizedBox(height: 10),
                  _PlanSelector(
                    selected: _selectedPlan,
                    isAnnual: _isAnnual,
                    onChanged: (p) => setState(() => _selectedPlan = p),
                  ),
                  const SizedBox(height: 10),
                  _PlanDetails(plan: _selectedPlan),
                  const SizedBox(height: 14),
                  if (actionState.error != null)
                    _ErrorBanner(message: actionState.error!),
                  _SubscribeButton(
                    plan: _selectedPlan,
                    isAnnual: _isAnnual,
                    onSubscribe: _subscribe,
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  _CurrentPlanCard(subscription: dashboard.subscription!),
                  const SizedBox(height: 14),
                  _ManagementButtons(onCancel: _cancel),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (actionState.isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.6),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingIndicator(),
                    SizedBox(height: 16),
                    Text('Processing...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _subscribe() async {
    final success = await ref.read(subscriptionActionProvider.notifier).subscribe(_selectedPlan, _isAnnual);
    if (success && mounted) {
      ref.read(dashboardProvider.notifier).loadDashboard();
      Navigator.pop(context);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel Subscription'),
        content: const Text('Your subscription will remain active until the end of the current billing period. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final success = await ref.read(subscriptionActionProvider.notifier).cancel();
      if (success && mounted) ref.read(dashboardProvider.notifier).loadDashboard();
    }
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.08)),
              ),
              Icon(Icons.workspace_premium_rounded, size: 24, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 8),
          const Text('SimPass Premium', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          const Text('Travel connected at reduced prices', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  final bool isAnnual;
  final ValueChanged<bool> onChanged;
  const _BillingToggle({required this.isAnnual, required this.onChanged});

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
        children: [
          _toggleItem('Monthly', !isAnnual, null, () => onChanged(false)),
          _toggleItem('Annual', isAnnual, 'Save 33%', () => onChanged(true)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool selected, String? badge, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 14, fontWeight: selected ? FontWeight.bold : FontWeight.w500, color: selected ? Colors.black : AppColors.textSecondary)),
              if (badge != null)
                Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: selected ? Colors.black.withValues(alpha: 0.7) : AppColors.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  final SubPlan selected;
  final bool isAnnual;
  final ValueChanged<SubPlan> onChanged;
  const _PlanSelector({required this.selected, required this.isAnnual, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SubPlan.values.map((plan) {
        final isSelected = plan == selected;
        final perMonth = isAnnual ? plan.annualPrice / 12 : plan.monthlyPrice;
        final color = plan == SubPlan.elite ? AppColors.accent : (plan == SubPlan.black ? Colors.white : const Color(0xFF888888));
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(plan),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: plan == SubPlan.privilege ? 0 : AppSpacing.md),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceLight : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isSelected ? color.withValues(alpha: 0.5) : AppColors.surfaceBorder,
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.06)),
                    child: Icon(_planIcon(plan), size: 14, color: color),
                  ),
                  const SizedBox(height: 6),
                  Text(plan.displayName.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, color: isSelected ? color : AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('\$${perMonth.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Text('/mo', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w500, color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: plan == SubPlan.elite ? AppColors.accent : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text('-${plan.discount}%', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: plan == SubPlan.elite ? Colors.black : color)),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _planIcon(SubPlan plan) {
    switch (plan) {
      case SubPlan.privilege: return Icons.shield_rounded;
      case SubPlan.elite: return Icons.workspace_premium_rounded;
      case SubPlan.black: return Icons.diamond_rounded;
    }
  }
}

class _PlanDetails extends StatelessWidget {
  final SubPlan plan;
  const _PlanDetails({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(plan.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              const Text('BENEFITS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.1)),
                  child: const Icon(Icons.check_rounded, size: 9, color: AppColors.accent),
                ),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _SubscribeButton extends StatelessWidget {
  final SubPlan plan;
  final bool isAnnual;
  final VoidCallback onSubscribe;
  const _SubscribeButton({required this.plan, required this.isAnnual, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    final price = isAnnual ? plan.annualPrice : plan.monthlyPrice;
    return Column(
      children: [
        SizedBox(
          width: double.infinity, height: 52,
          child: ElevatedButton(
            onPressed: onSubscribe,
            child: Text('Subscribe for \$${price.toStringAsFixed(2)}${isAnnual ? '/year' : '/mo'}'),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, size: 8, color: AppColors.textTertiary),
            SizedBox(width: 3),
            Text('Cancel anytime. Secure payment.', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          ],
        ),
      ],
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final SubscriptionInfo subscription;
  const _CurrentPlanCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Current Plan', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  subscription.plan.toUpperCase(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: subscription.isActive ? AppColors.success : AppColors.warning,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(subscription.status.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black)),
              ),
            ],
          ),
          const Divider(color: AppColors.surfaceBorder),
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Discount', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text('-${subscription.discountPercent}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success)),
              ]),
              const SizedBox(width: 20),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Billing', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(
                  subscription.billingPeriod.isNotEmpty ? subscription.billingPeriod[0].toUpperCase() + subscription.billingPeriod.substring(1) : '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ]),
            ],
          ),
          if (subscription.currentPeriodEnd != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Next renewal: ${subscription.currentPeriodEnd!.substring(0, 10)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ManagementButtons extends StatelessWidget {
  final VoidCallback onCancel;
  const _ManagementButtons({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onCancel,
          child: const Text('Cancel Subscription', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.error)),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
        ],
      ),
    );
  }
}
