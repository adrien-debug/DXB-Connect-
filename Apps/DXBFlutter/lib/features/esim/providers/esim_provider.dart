import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../models/esim_models.dart';

class EsimListData {
  final List<EsimOrder> esims;
  final Map<String, EsimUsage> usageCache;
  final bool isLoading;
  final String? error;

  const EsimListData({
    this.esims = const [],
    this.usageCache = const {},
    this.isLoading = false,
    this.error,
  });

  EsimListData copyWith({
    List<EsimOrder>? esims,
    Map<String, EsimUsage>? usageCache,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return EsimListData(
      esims: esims ?? this.esims,
      usageCache: usageCache ?? this.usageCache,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<EsimOrder> get activeEsims =>
      esims.where((e) => e.isActive && !e.isExpired).toList();

  List<EsimOrder> get expiredEsims =>
      esims.where((e) => !e.isActive || e.isExpired).toList();
}

class EsimDetailData {
  final EsimUsage? usage;
  final List<TopUpPackage> topUpPackages;
  final bool isLoadingUsage;
  final bool isLoadingTopUp;
  final bool isActionInProgress;
  final String? actionMessage;
  final String? error;

  const EsimDetailData({
    this.usage,
    this.topUpPackages = const [],
    this.isLoadingUsage = true,
    this.isLoadingTopUp = false,
    this.isActionInProgress = false,
    this.actionMessage,
    this.error,
  });

  EsimDetailData copyWith({
    EsimUsage? usage,
    bool clearUsage = false,
    List<TopUpPackage>? topUpPackages,
    bool? isLoadingUsage,
    bool? isLoadingTopUp,
    bool? isActionInProgress,
    String? actionMessage,
    bool clearAction = false,
    String? error,
    bool clearError = false,
  }) {
    return EsimDetailData(
      usage: clearUsage ? null : (usage ?? this.usage),
      topUpPackages: topUpPackages ?? this.topUpPackages,
      isLoadingUsage: isLoadingUsage ?? this.isLoadingUsage,
      isLoadingTopUp: isLoadingTopUp ?? this.isLoadingTopUp,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      actionMessage: clearAction ? null : (actionMessage ?? this.actionMessage),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class EsimListNotifier extends StateNotifier<EsimListData> {
  final ApiClient _apiClient;

  EsimListNotifier(this._apiClient) : super(const EsimListData());

  Future<void> loadEsims() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiClient.get(ApiEndpoints.esimOrders);
      final raw = response.data;
      List<dynamic> list = [];
      if (raw is Map) {
        list = raw['obj']?['orderList'] as List<dynamic>? ??
            raw['orders'] as List<dynamic>? ??
            raw['data'] as List<dynamic>? ??
            [];
      } else if (raw is List) {
        list = raw;
      }
      final esims = list
          .map((e) => EsimOrder.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(esims: esims, isLoading: false);
      await _loadUsageForAll();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load eSIMs',
      );
    }
  }

  Future<void> _loadUsageForAll() async {
    final cache = Map<String, EsimUsage>.from(state.usageCache);
    for (final esim in state.esims) {
      final iccid = esim.iccid;
      if (iccid == null || iccid.isEmpty || cache.containsKey(iccid)) continue;
      try {
        final response = await _apiClient.get(
          '${ApiEndpoints.esimUsage}?iccid=$iccid',
        );
        if (response.data != null) {
          cache[iccid] = EsimUsage.fromJson(
              response.data as Map<String, dynamic>);
        }
      } catch (_) {}
    }
    state = state.copyWith(usageCache: cache);
  }
}

class EsimDetailNotifier extends StateNotifier<EsimDetailData> {
  final ApiClient _apiClient;

  EsimDetailNotifier(this._apiClient) : super(const EsimDetailData());

  Future<void> loadDetail(String iccid) async {
    if (iccid.isEmpty) {
      state = state.copyWith(isLoadingUsage: false);
      return;
    }
    state = state.copyWith(isLoadingUsage: true, isLoadingTopUp: true);
    await Future.wait([
      _loadUsage(iccid),
      _loadTopUp(iccid),
    ]);
  }

  Future<void> _loadUsage(String iccid) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.esimUsage}?iccid=$iccid',
      );
      final raw = response.data;
      if (raw == null) {
        state = state.copyWith(isLoadingUsage: false);
        return;
      }
      final usageData = raw is Map ? (raw['obj'] ?? raw['data'] ?? raw) : raw;
      if (usageData is Map<String, dynamic>) {
        state = state.copyWith(
          usage: EsimUsage.fromJson(usageData),
          isLoadingUsage: false,
        );
      } else {
        state = state.copyWith(isLoadingUsage: false);
      }
    } catch (_) {
      state = state.copyWith(isLoadingUsage: false);
    }
  }

  Future<void> _loadTopUp(String iccid) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.esimTopup}?iccid=$iccid',
      );
      final raw = response.data;
      List<dynamic> list = [];
      if (raw is Map) {
        list = raw['obj']?['packageList'] as List<dynamic>? ??
            raw['packages'] as List<dynamic>? ??
            raw['data'] as List<dynamic>? ??
            [];
      } else if (raw is List) {
        list = raw;
      }
      state = state.copyWith(
        topUpPackages: list
            .map((e) => TopUpPackage.fromJson(e as Map<String, dynamic>))
            .toList(),
        isLoadingTopUp: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingTopUp: false);
    }
  }

  Future<bool> suspendEsim(String orderNo) async {
    state = state.copyWith(isActionInProgress: true, actionMessage: 'Suspending...');
    try {
      await _apiClient.post(ApiEndpoints.esimSuspend, data: {'orderNo': orderNo});
      state = state.copyWith(isActionInProgress: false, clearAction: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isActionInProgress: false,
        clearAction: true,
        error: 'Failed to suspend eSIM',
      );
      return false;
    }
  }

  Future<bool> topUpEsim(String iccid, String packageCode) async {
    state = state.copyWith(isActionInProgress: true, actionMessage: 'Purchasing top-up...');
    try {
      await _apiClient.post(
        ApiEndpoints.esimTopup,
        data: {'iccid': iccid, 'packageCode': packageCode},
      );
      state = state.copyWith(isActionInProgress: false, clearAction: true);
      return true;
    } catch (_) {
      state = state.copyWith(
        isActionInProgress: false,
        clearAction: true,
        error: 'Top-up failed. Please try again.',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final esimListProvider =
    StateNotifierProvider<EsimListNotifier, EsimListData>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return EsimListNotifier(apiClient);
});

final esimDetailProvider =
    StateNotifierProvider<EsimDetailNotifier, EsimDetailData>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return EsimDetailNotifier(apiClient);
});
