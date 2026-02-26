import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../esim/models/esim_models.dart';
import '../../subscription/models/subscription_models.dart';
import '../../offers/models/offer_models.dart';
import '../../rewards/models/rewards_models.dart';

class DashboardData {
  final List<EsimOrder> esims;
  final SubscriptionInfo? subscription;
  final List<PartnerOffer> offers;
  final RewardsWallet? wallet;
  final Map<String, EsimUsage> usageCache;
  final bool isLoading;
  final String? error;

  const DashboardData({
    this.esims = const [],
    this.subscription,
    this.offers = const [],
    this.wallet,
    this.usageCache = const {},
    this.isLoading = false,
    this.error,
  });

  DashboardData copyWith({
    List<EsimOrder>? esims,
    SubscriptionInfo? subscription,
    bool clearSubscription = false,
    List<PartnerOffer>? offers,
    RewardsWallet? wallet,
    Map<String, EsimUsage>? usageCache,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardData(
      esims: esims ?? this.esims,
      subscription: clearSubscription ? null : (subscription ?? this.subscription),
      offers: offers ?? this.offers,
      wallet: wallet ?? this.wallet,
      usageCache: usageCache ?? this.usageCache,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<EsimOrder> get activeEsims =>
      esims.where((e) => e.isActive && !e.isExpired).toList();

  int get activeCount => activeEsims.length;

  int get countriesCount {
    final countries = <String>{};
    for (final esim in activeEsims) {
      final name = esim.packageName.split(' ').first.toLowerCase();
      countries.add(name);
    }
    return countries.length;
  }

  double get totalRemainingGB {
    if (usageCache.isEmpty) return 0;
    final totalRemaining =
        usageCache.values.fold<int>(0, (sum, u) => sum + u.remainingData);
    return totalRemaining / 1073741824;
  }

  int get usagePercent {
    if (usageCache.isEmpty) return 0;
    final totalBytes =
        usageCache.values.fold<int>(0, (sum, u) => sum + u.totalVolume);
    final usedBytes =
        usageCache.values.fold<int>(0, (sum, u) => sum + u.orderUsage);
    if (totalBytes == 0) return 0;
    return (usedBytes / totalBytes * 100).round();
  }
}

class DashboardNotifier extends StateNotifier<DashboardData> {
  final ApiClient _apiClient;

  DashboardNotifier(this._apiClient) : super(const DashboardData());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await Future.wait([
        _fetchEsims(),
        _fetchSubscription(),
        _fetchOffers(),
        _fetchRewards(),
      ]);

      state = state.copyWith(
        esims: results[0] as List<EsimOrder>,
        subscription: results[1] as SubscriptionInfo?,
        offers: results[2] as List<PartnerOffer>,
        wallet: results[3] as RewardsWallet?,
        isLoading: false,
      );

      await _loadUsageData();
    } catch (e) {
      if (kDebugMode) debugPrint('[Dashboard] loadDashboard error: $e');
      state = state.copyWith(
        isLoading: false,
        error: ApiClient.extractErrorMessage(e, 'Failed to load dashboard. Pull to retry.'),
      );
    }
  }

  Future<List<EsimOrder>> _fetchEsims() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.esimOrders);
      final list = ApiClient.extractList(
        response.data,
        ['obj.orderList', 'orders', 'data'],
      );
      return list
          .map((e) => EsimOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[Dashboard] _fetchEsims error: $e');
      return [];
    }
  }

  Future<SubscriptionInfo?> _fetchSubscription() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.subscriptionsMe);
      final sub = ApiClient.extractObject(
        response.data,
        ['subscription', 'data'],
      );
      return sub != null ? SubscriptionInfo.fromJson(sub) : null;
    } catch (e) {
      if (kDebugMode) debugPrint('[Dashboard] _fetchSubscription error: $e');
      return null;
    }
  }

  Future<List<PartnerOffer>> _fetchOffers() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.offers);
      final list = ApiClient.extractList(response.data, ['data', 'offers']);
      return list
          .map((e) => PartnerOffer.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[Dashboard] _fetchOffers error: $e');
      return [];
    }
  }

  Future<RewardsWallet?> _fetchRewards() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.rewardsSummary);
      final walletData = ApiClient.extractObject(
        response.data is Map ? (response.data['data'] ?? response.data) : response.data,
        ['wallet'],
      );
      return walletData != null ? RewardsWallet.fromJson(walletData) : null;
    } catch (e) {
      if (kDebugMode) debugPrint('[Dashboard] _fetchRewards error: $e');
      return null;
    }
  }

  Future<void> _loadUsageData() async {
    final cache = Map<String, EsimUsage>.from(state.usageCache);
    for (final esim in state.activeEsims) {
      final iccid = esim.iccid;
      if (iccid == null || iccid.isEmpty || cache.containsKey(iccid)) continue;
      try {
        final response = await _apiClient.get(
          '${ApiEndpoints.esimUsage}?iccid=$iccid',
        );
        final raw = response.data;
        if (raw != null) {
          final usageData = raw is Map ? (raw['obj'] ?? raw['data'] ?? raw) : raw;
          if (usageData is Map<String, dynamic>) {
            cache[iccid] = EsimUsage.fromJson(usageData);
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[Dashboard] Usage fetch failed for $iccid: $e');
      }
    }
    state = state.copyWith(usageCache: cache);
  }

  Future<void> refresh() async {
    state = state.copyWith(usageCache: {});
    await loadDashboard();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardData>((ref) {
  final apiClient = ref.read(apiClientProvider);
  ref.watch(authProvider);
  return DashboardNotifier(apiClient);
});
