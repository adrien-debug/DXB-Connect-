import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/checkout_service.dart';

enum SubPlan {
  privilege,
  elite,
  black;

  String get displayName {
    switch (this) {
      case SubPlan.privilege: return 'Privilege';
      case SubPlan.elite: return 'Elite';
      case SubPlan.black: return 'Black';
    }
  }

  int get discount {
    switch (this) {
      case SubPlan.privilege: return 15;
      case SubPlan.elite: return 30;
      case SubPlan.black: return 50;
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubPlan.privilege: return 4.99;
      case SubPlan.elite: return 9.99;
      case SubPlan.black: return 19.99;
    }
  }

  double get annualPrice {
    switch (this) {
      case SubPlan.privilege: return 39.99;
      case SubPlan.elite: return 79.99;
      case SubPlan.black: return 159.99;
    }
  }

  List<String> get features {
    switch (this) {
      case SubPlan.privilege:
        return ['-15% on all eSIM plans', 'Priority support', 'Partner offers access', 'Privilege badge'];
      case SubPlan.elite:
        return ['-30% on all eSIM plans', 'VIP 24/7 support', 'Premium partner offers', 'Gold Elite badge', 'Early access to new destinations'];
      case SubPlan.black:
        return ['-50% on 1st eSIM/month, then -30%', 'Dedicated concierge', 'Exclusive partner offers', 'Diamond Black badge', 'VIP event invitations', '2x bonus points'];
    }
  }
}

class SubscriptionActionState {
  final bool isProcessing;
  final String? error;
  final bool? lastSuccess;

  const SubscriptionActionState({this.isProcessing = false, this.error, this.lastSuccess});

  SubscriptionActionState copyWith({bool? isProcessing, String? error, bool clearError = false, bool? lastSuccess}) {
    return SubscriptionActionState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
      lastSuccess: lastSuccess,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionActionState> {
  final ApiClient _apiClient;
  final CheckoutService _checkoutService;

  SubscriptionNotifier(this._apiClient, this._checkoutService)
      : super(const SubscriptionActionState());

  Future<bool> subscribe(SubPlan plan, bool isAnnual) async {
    state = state.copyWith(isProcessing: true, clearError: true, lastSuccess: null);
    try {
      final result = await _checkoutService.createSubscription(
        plan: plan.name,
        billingPeriod: isAnnual ? 'yearly' : 'monthly',
      );

      if (result.success) {
        state = state.copyWith(isProcessing: false, lastSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: result.error,
          lastSuccess: false,
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[Subscription] subscribe error: $e');
      state = state.copyWith(
        isProcessing: false,
        error: ApiClient.extractErrorMessage(e, 'Subscription failed. Please try again.'),
        lastSuccess: false,
      );
      return false;
    }
  }

  Future<bool> cancel() async {
    state = state.copyWith(isProcessing: true, clearError: true, lastSuccess: null);
    try {
      await _apiClient.post(ApiEndpoints.subscriptionsCancel);
      state = state.copyWith(isProcessing: false, lastSuccess: true);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[Subscription] cancel error: $e');
      state = state.copyWith(
        isProcessing: false,
        error: ApiClient.extractErrorMessage(e, 'Unable to cancel. Contact support.'),
        lastSuccess: false,
      );
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final subscriptionActionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionActionState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final checkoutService = ref.read(checkoutServiceProvider);
  return SubscriptionNotifier(apiClient, checkoutService);
});
