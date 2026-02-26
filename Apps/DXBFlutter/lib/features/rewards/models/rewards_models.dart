class RewardsSummary {
  final RewardsWallet wallet;
  final List<Mission> missions;
  final List<Raffle> raffles;

  const RewardsSummary({
    required this.wallet,
    this.missions = const [],
    this.raffles = const [],
  });

  factory RewardsSummary.fromJson(Map<String, dynamic> json) => RewardsSummary(
        wallet: RewardsWallet.fromJson(json['wallet'] as Map<String, dynamic>),
        missions: (json['missions'] as List<dynamic>?)
                ?.map((e) => Mission.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        raffles: (json['raffles'] as List<dynamic>?)
                ?.map((e) => Raffle.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class RewardsWallet {
  final int xpTotal;
  final int level;
  final int pointsBalance;
  final int pointsEarnedTotal;
  final int pointsSpentTotal;
  final int ticketsBalance;
  final String tier;
  final int streakDays;

  const RewardsWallet({
    required this.xpTotal,
    required this.level,
    required this.pointsBalance,
    required this.pointsEarnedTotal,
    required this.pointsSpentTotal,
    required this.ticketsBalance,
    required this.tier,
    required this.streakDays,
  });

  factory RewardsWallet.fromJson(Map<String, dynamic> json) => RewardsWallet(
        xpTotal: json['xp_total'] ?? 0,
        level: json['level'] ?? 1,
        pointsBalance: json['points_balance'] ?? 0,
        pointsEarnedTotal: json['points_earned_total'] ?? 0,
        pointsSpentTotal: json['points_spent_total'] ?? 0,
        ticketsBalance: json['tickets_balance'] ?? 0,
        tier: json['tier']?.toString() ?? 'bronze',
        streakDays: json['streak_days'] ?? 0,
      );
}

class Mission {
  final String id;
  final String type;
  final String title;
  final int xpReward;
  final int pointsReward;
  final int userProgress;
  final bool userCompleted;

  const Mission({
    required this.id,
    required this.type,
    required this.title,
    required this.xpReward,
    required this.pointsReward,
    required this.userProgress,
    required this.userCompleted,
  });

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        xpReward: json['xp_reward'] ?? 0,
        pointsReward: json['points_reward'] ?? 0,
        userProgress: json['user_progress'] ?? (json['user_progress'] is Map ? (json['user_progress'] as Map)['progress'] ?? 0 : 0),
        userCompleted: json['user_completed'] ?? (json['user_progress'] is Map ? (json['user_progress'] as Map)['completed'] ?? false : false),
      );
}

class Raffle {
  final String id;
  final String title;
  final String prizeDescription;
  final String? drawDate;
  final String? imageUrl;
  final int userTicketsEntered;

  const Raffle({
    required this.id,
    required this.title,
    required this.prizeDescription,
    this.drawDate,
    this.imageUrl,
    this.userTicketsEntered = 0,
  });

  factory Raffle.fromJson(Map<String, dynamic> json) => Raffle(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        prizeDescription: json['prize_description']?.toString() ?? '',
        drawDate: json['draw_date']?.toString(),
        imageUrl: json['image_url']?.toString(),
        userTicketsEntered: json['user_tickets_entered'] ?? 0,
      );
}
