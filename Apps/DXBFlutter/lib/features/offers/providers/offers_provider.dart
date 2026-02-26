import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../models/offer_models.dart';

class OffersData {
  final List<PartnerOffer> offers;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const OffersData({this.offers = const [], this.isLoading = false, this.error, this.selectedCategory});

  OffersData copyWith({
    List<PartnerOffer>? offers, bool? isLoading,
    String? error, bool clearError = false,
    String? selectedCategory, bool clearCategory = false,
  }) => OffersData(
    offers: offers ?? this.offers,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
  );

  List<String> get categories {
    final cats = offers.map((o) => o.category).where((c) => c.isNotEmpty).toSet().toList();
    cats.sort();
    return cats;
  }

  List<PartnerOffer> get filteredOffers {
    if (selectedCategory == null) return offers;
    return offers.where((o) => o.category == selectedCategory).toList();
  }
}

class OffersNotifier extends StateNotifier<OffersData> {
  final ApiClient _apiClient;

  OffersNotifier(this._apiClient) : super(const OffersData());

  Future<void> loadOffers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiClient.get(ApiEndpoints.offers);
      final raw = response.data;
      List<dynamic> list = [];
      if (raw is Map) {
        list = raw['data'] as List<dynamic>? ?? raw['offers'] as List<dynamic>? ?? [];
      } else if (raw is List) {
        list = raw;
      }
      final offers = list.map((e) => PartnerOffer.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(offers: offers, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Unable to load offers');
    }
  }

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  Future<String?> trackClick(String offerId) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.offerClick(offerId));
      return response.data?['redirectUrl']?.toString();
    } catch (_) {
      return null;
    }
  }
}

final offersProvider = StateNotifierProvider<OffersNotifier, OffersData>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return OffersNotifier(apiClient);
});
