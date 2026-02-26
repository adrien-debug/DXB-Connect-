import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/api_endpoints.dart';
import '../../../core/providers/core_providers.dart';
import '../models/rewards_models.dart';

class RewardsData {
  final RewardsSummary? summary;
  final List<RewardsTransaction> transactions;
  final bool isLoading;
  final String? error;

  const RewardsData({this.summary, this.transactions = const [], this.isLoading = false, this.error});

  RewardsData copyWith({
    RewardsSummary? summary, bool clearSummary = false,
    List<RewardsTransaction>? transactions,
    bool? isLoading, String? error, bool clearError = false,
  }) => RewardsData(
    summary: clearSummary ? null : (summary ?? this.summary),
    transactions: transactions ?? this.transactions,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );

  RewardsWallet? get wallet => summary?.wallet;
  List<Mission> get missions => summary?.missions ?? [];
  List<Raffle> get raffles => summary?.raffles ?? [];

  double get levelProgress {
    final xp = wallet?.xpTotal ?? 0;
    final level = wallet?.level ?? 0;
    if (level <= 0) return 0;
    const xpPerLevel = 1000;
    final xpInCurrent = xp % xpPerLevel;
    return xpInCurrent / xpPerLevel;
  }
}

class RewardsTransaction {
  final String id;
  final String type;
  final String? reason;
  final String? description;
  final int delta;
  final String? createdAt;

  const RewardsTransaction({required this.id, required this.type, this.reason, this.description, required this.delta, this.createdAt});

  factory RewardsTransaction.fromJson(Map<String, dynamic> json) => RewardsTransaction(
    id: json['id']?.toString() ?? '',
    type: json['type']?.toString() ?? '',
    reason: json['reason']?.toString(),
    description: json['description']?.toString(),
    delta: json['delta'] ?? 0,
    createdAt: json['created_at']?.toString(),
  );
}

class RewardsNotifier extends StateNotifier<RewardsData> {
  final ApiClient _apiClient;

  RewardsNotifier(this._apiClient) : super(const RewardsData());

  Future<void> loadRewards() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _apiClient.get(ApiEndpoints.rewardsSummary);
      final raw = response.data as Map<String, dynamic>? ?? {};
      final data = raw['data'] as Map<String, dynamic>? ?? raw;
      final summary = RewardsSummary.fromJson(data);

      List<RewardsTransaction> txns = [];
      final txnList = data['recent_transactions'] ?? raw['recent_transactions'];
      if (txnList is List) {
        txns = txnList
            .map((e) => RewardsTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(summary: summary, transactions: txns, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load rewards.');
    }
  }

  Future<bool> dailyCheckin() async {
    try {
      await _apiClient.post(ApiEndpoints.rewardsCheckin);
      await loadRewards();
      return true;
    } catch (_) {
      state = state.copyWith(error: 'Check-in failed. Try again later.');
      return false;
    }
  }

  Future<bool> enterRaffle(String raffleId) async {
    try {
      await _apiClient.post(ApiEndpoints.rafflesEnter, data: {'raffle_id': raffleId});
      await loadRewards();
      return true;
    } catch (_) {
      state = state.copyWith(error: 'Unable to enter raffle. Try again.');
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final rewardsProvider = StateNotifierProvider<RewardsNotifier, RewardsData>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return RewardsNotifier(apiClient);
});
