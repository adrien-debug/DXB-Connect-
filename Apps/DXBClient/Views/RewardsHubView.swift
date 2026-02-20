import SwiftUI
import DXBCore

struct RewardsHubView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var wallet: UserWallet?
    @State private var missions: [MissionItem] = []
    @State private var raffles: [RaffleItem] = []
    @State private var transactions: [WalletTransaction] = []
    @State private var isLoading = true
    @State private var hasCheckedIn = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundSecondary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        xpLevelSection
                        dailyCheckinCard
                        missionsSection
                        rafflesSection
                        recentTransactionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Rewards Hub")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
            .task { await loadRewardsSummary() }
        }
    }

    // MARK: - XP & Level

    private var xpLevelSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Level \(wallet?.level ?? 1)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(wallet?.tier.uppercased() ?? "BRONZE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(tierColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(tierColor.opacity(0.15)))
                }

                Spacer()

                HStack(spacing: 20) {
                    WalletStat(icon: "star.fill", value: "\(wallet?.xp_total ?? 0)", label: "XP", color: AppTheme.accent)
                    WalletStat(icon: "circle.fill", value: "\(wallet?.points_balance ?? 0)", label: "Points", color: AppTheme.success)
                    WalletStat(icon: "ticket.fill", value: "\(wallet?.tickets_balance ?? 0)", label: "Tickets", color: AppTheme.warning)
                }
            }

            // XP Progress bar
            let xpForNext = xpForNextLevel
            let progress = xpForNext > 0 ? Double(wallet?.xp_total ?? 0) / Double(xpForNext) : 0

            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.gray100)
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.accent)
                            .frame(width: geo.size.width * min(progress, 1), height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(wallet?.xp_total ?? 0) / \(xpForNext) XP to Level \((wallet?.level ?? 1) + 1)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Daily Check-in

    private var dailyCheckinCard: some View {
        Button {
            Task { await performCheckin() }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(hasCheckedIn ? AppTheme.success.opacity(0.12) : AppTheme.accent.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: hasCheckedIn ? "checkmark.circle.fill" : "sun.max.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(hasCheckedIn ? AppTheme.success : AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(hasCheckedIn ? "Checked in!" : "Daily Check-in")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(hasCheckedIn ? "+25 XP, +10 Points" : "Tap to claim +25 XP")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                if !hasCheckedIn {
                    Text("Claim")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "0F172A"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(AppTheme.accent))
                }

                if let streak = wallet?.streak_days, streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.error)
                        Text("\(streak)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.error)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.backgroundPrimary)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(hasCheckedIn)
    }

    // MARK: - Missions

    private var missionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Missions")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            if missions.isEmpty {
                Text("No active missions")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(missions, id: \.id) { mission in
                    MissionRow(mission: mission)
                }
            }
        }
    }

    // MARK: - Raffles

    private var rafflesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Raffles")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            if raffles.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.textTertiary)
                    Text("No active raffles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(raffles, id: \.id) { raffle in
                    RaffleCard(raffle: raffle, ticketsBalance: wallet?.tickets_balance ?? 0)
                }
            }
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            if transactions.isEmpty {
                Text("No activity yet")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(transactions, id: \.id) { tx in
                    HStack(spacing: 12) {
                        Image(systemName: tx.delta > 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(tx.delta > 0 ? AppTheme.success : AppTheme.error)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(tx.description ?? tx.reason)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(1)
                        }

                        Spacer()

                        Text(tx.delta > 0 ? "+\(tx.delta)" : "\(tx.delta)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(tx.delta > 0 ? AppTheme.success : AppTheme.error)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    // MARK: - Helpers

    private var tierColor: Color {
        switch wallet?.tier ?? "bronze" {
        case "silver": return Color.gray
        case "gold": return AppTheme.warning
        case "platinum": return AppTheme.accent
        default: return Color.brown
        }
    }

    private var xpForNextLevel: Int {
        let level = wallet?.level ?? 1
        let thresholds = [500, 1500, 3000, 5000, 8000, 12000, 18000, 25000, 35000]
        if level - 1 < thresholds.count {
            return thresholds[level - 1]
        }
        return 35000 + (level - 9) * 15000
    }

    // MARK: - Network

    private func loadRewardsSummary() async {
        isLoading = true
        // TODO: Appeler Railway /api/rewards/summary via DXBAPIService
        isLoading = false
    }

    private func performCheckin() async {
        HapticFeedback.success()
        hasCheckedIn = true
        // TODO: Appeler Railway /api/rewards/checkin via DXBAPIService
    }
}

// MARK: - Sub Models

struct MissionItem: Identifiable, Codable {
    let id: String
    let type: String
    let title: String
    let description: String?
    let xp_reward: Int
    let points_reward: Int
    let condition_value: Int
    var user_progress: Int?
    var user_completed: Bool?
}

struct RaffleItem: Identifiable, Codable {
    let id: String
    let title: String
    let prize_description: String
    let draw_date: String
    let image_url: String?
}

struct WalletTransaction: Identifiable, Codable {
    let id: String
    let type: String
    let delta: Int
    let reason: String
    let description: String?
}

// MARK: - Mission Row

struct MissionRow: View {
    let mission: MissionItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(mission.user_completed == true ? AppTheme.success.opacity(0.12) : AppTheme.accent.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: mission.user_completed == true ? "checkmark" : missionIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(mission.user_completed == true ? AppTheme.success : AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(mission.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("\(mission.user_progress ?? 0)/\(mission.condition_value)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(mission.xp_reward) XP")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accent)
                if mission.points_reward > 0 {
                    Text("+\(mission.points_reward) pts")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.success)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
        )
    }

    private var missionIcon: String {
        switch mission.type {
        case "daily": return "sun.max"
        case "weekly": return "calendar"
        default: return "target"
        }
    }
}

// MARK: - Raffle Card

struct RaffleCard: View {
    let raffle: RaffleItem
    let ticketsBalance: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(raffle.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(raffle.prize_description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "gift.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.accent)
            }

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text("Draw: \(raffle.draw_date)")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(AppTheme.textTertiary)

                Spacer()

                if ticketsBalance > 0 {
                    Button {
                        HapticFeedback.light()
                        // TODO: Enter raffle via API
                    } label: {
                        Text("Enter (1 ticket)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(hex: "0F172A"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(AppTheme.accent))
                    }
                } else {
                    Text("No tickets")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }
}

#Preview {
    RewardsHubView()
        .environmentObject(AppCoordinator())
}
