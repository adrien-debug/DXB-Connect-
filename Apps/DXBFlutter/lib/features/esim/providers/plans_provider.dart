import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../models/esim_models.dart';

enum SortOption { priceAsc, priceDesc, dataDesc, duration }

extension SortOptionX on SortOption {
  String get label {
    switch (this) {
      case SortOption.priceAsc:
        return 'Price ↑';
      case SortOption.priceDesc:
        return 'Price ↓';
      case SortOption.dataDesc:
        return 'Data ↓';
      case SortOption.duration:
        return 'Duration';
    }
  }
}

class CountryEntry {
  final String name;
  final String code;
  final int planCount;
  final double startingPrice;

  const CountryEntry({
    required this.name,
    required this.code,
    required this.planCount,
    required this.startingPrice,
  });
}

class PlansData {
  final List<EsimPlan> allPlans;
  final bool isLoading;
  final String? error;

  const PlansData({
    this.allPlans = const [],
    this.isLoading = false,
    this.error,
  });

  PlansData copyWith({
    List<EsimPlan>? allPlans,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PlansData(
      allPlans: allPlans ?? this.allPlans,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<CountryEntry> countries({String search = ''}) {
    final grouped = <String, List<EsimPlan>>{};
    for (final plan in allPlans) {
      grouped.putIfAbsent(plan.location, () => []).add(plan);
    }
    var result = grouped.entries.map((entry) {
      final plans = entry.value;
      return CountryEntry(
        name: entry.key,
        code: plans.first.locationCode,
        planCount: plans.length,
        startingPrice: plans.map((p) => p.priceUSD).reduce(
            (a, b) => a < b ? a : b),
      );
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (search.isNotEmpty) {
      result = result
          .where(
              (c) => c.name.toLowerCase().contains(search.toLowerCase()))
          .toList();
    }
    return result;
  }

  List<EsimPlan> plansForCountry(String countryName,
      {SortOption sort = SortOption.priceAsc}) {
    var result =
        allPlans.where((p) => p.location == countryName).toList();
    switch (sort) {
      case SortOption.priceAsc:
        result.sort((a, b) => a.priceUSD.compareTo(b.priceUSD));
      case SortOption.priceDesc:
        result.sort((a, b) => b.priceUSD.compareTo(a.priceUSD));
      case SortOption.dataDesc:
        result.sort((a, b) => b.dataGB.compareTo(a.dataGB));
      case SortOption.duration:
        result.sort((a, b) => b.durationDays.compareTo(a.durationDays));
    }
    return result;
  }

  bool isBestValue(EsimPlan plan) {
    if (plan.dataGB <= 0) return false;
    final sameDest = allPlans
        .where((p) => p.location == plan.location && p.dataGB > 0)
        .toList();
    if (sameDest.length <= 2) return false;
    final pricePerGB = plan.priceUSD / plan.dataGB;
    final cheapest = sameDest.reduce((a, b) =>
        (a.priceUSD / a.dataGB) < (b.priceUSD / b.dataGB) ? a : b);
    return cheapest.id == plan.id && pricePerGB < 5;
  }
}

class PlansNotifier extends StateNotifier<PlansData> {
  final ApiClient _apiClient;

  PlansNotifier(this._apiClient) : super(const PlansData());

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiClient.get(ApiEndpoints.esimPackages);
      final list = ApiClient.extractList(
        response.data,
        ['obj.packageList', 'packages', 'data'],
      );
      state = state.copyWith(
        allPlans: list
            .map((e) => EsimPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Plans] loadPlans error: $e');
      state = state.copyWith(
        isLoading: false,
        error: ApiClient.extractErrorMessage(e, 'Failed to load plans. Pull to retry.'),
      );
    }
  }

  Future<String?> purchasePlan(String packageCode) async {
    try {
      await _apiClient.post(
        ApiEndpoints.esimPurchase,
        data: {'packageCode': packageCode},
      );
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('[Plans] purchasePlan error: $e');
      return ApiClient.extractErrorMessage(e, 'Purchase failed. Please try again.');
    }
  }
}

final plansProvider = StateNotifierProvider<PlansNotifier, PlansData>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PlansNotifier(apiClient);
});
