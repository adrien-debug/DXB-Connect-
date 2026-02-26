import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';

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

  const SubscriptionActionState({this.isProcessing = false, this.error});

  SubscriptionActionState copyWith({bool? isProcessing, String? error, bool clearError = false}) {
    return SubscriptionActionState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionActionState> {
  final ApiClient _apiClient;

  SubscriptionNotifier(this._apiClient) : super(const SubscriptionActionState());

  Future<bool> subscribe(SubPlan plan, bool isAnnual) async {
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      await _apiClient.post(
        ApiEndpoints.subscriptionsCreate,
        data: {
          'plan': plan.name,
          'billingPeriod': isAnnual ? 'yearly' : 'monthly',
        },
      );
      state = state.copyWith(isProcessing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: 'Subscription failed. Please try again.');
      return false;
    }
  }

  Future<bool> cancel() async {
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      await _apiClient.post(ApiEndpoints.subscriptionsCancel);
      state = state.copyWith(isProcessing: false);
      return true;
    } catch (_) {
      state = state.copyWith(isProcessing: false, error: 'Unable to cancel. Contact support.');
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final subscriptionActionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionActionState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SubscriptionNotifier(apiClient);
});
