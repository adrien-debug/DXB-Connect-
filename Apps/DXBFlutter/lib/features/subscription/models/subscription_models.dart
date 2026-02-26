class SubscriptionInfo {
  final String id;
  final String plan;
  final String status;
  final String billingPeriod;
  final int discountPercent;
  final double? monthlyDiscountCapUsd;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final int? discountsRemaining;

  const SubscriptionInfo({
    required this.id,
    required this.plan,
    required this.status,
    required this.billingPeriod,
    required this.discountPercent,
    this.monthlyDiscountCapUsd,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.discountsRemaining,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) => SubscriptionInfo(
        id: json['id']?.toString() ?? '',
        plan: json['plan']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        billingPeriod: json['billing_period']?.toString() ?? 'monthly',
        discountPercent: json['discount_percent'] ?? 0,
        monthlyDiscountCapUsd: json['monthly_discount_cap_usd']?.toDouble(),
        currentPeriodStart: json['current_period_start']?.toString(),
        currentPeriodEnd: json['current_period_end']?.toString(),
        discountsRemaining: json['discounts_remaining'] as int?,
      );

  bool get isActive => status == 'active';
}

enum SubscriptionPlan { privilege, elite, black }

extension SubscriptionPlanX on SubscriptionPlan {
  String get displayName {
    switch (this) {
      case SubscriptionPlan.privilege:
        return 'Privilege';
      case SubscriptionPlan.elite:
        return 'Elite';
      case SubscriptionPlan.black:
        return 'Black';
    }
  }

  int get discountPercent {
    switch (this) {
      case SubscriptionPlan.privilege:
        return 15;
      case SubscriptionPlan.elite:
        return 30;
      case SubscriptionPlan.black:
        return 50;
    }
  }
}
