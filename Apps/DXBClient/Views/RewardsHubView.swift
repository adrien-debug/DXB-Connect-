import SwiftUI
import DXBCore

struct RewardsHubView: View {
    @Environment(AppState.self) private var appState

    @State private var isCheckinLoading = false
    @State private var checkinSuccess = false
    @State private var selectedTab: RewardsTab = .missions
    @State private var enteringRaffle: String?
    @State private var raffleEntrySuccess = false
    @State private var rewardsError: String?

    enum RewardsTab: String, CaseIterable {
        case missions = "Missions"
        case raffles = "Raffles"
        case history = "History"

        var icon: String {
            switch self {
            case .missions: return "target"
            case .raffles:  return "ticket.fill"
            case .history:  return "clock.fill"
            }
        }
    }

    private var wallet: WalletData? { appState.rewardsSummary?.wallet }

    private var levelProgress: Double {
        guard let xp = wallet?.xp_total, let level = wallet?.level, level > 0 else { return 0 }
        let xpPerLevel = 1000
        let xpInCurrentLevel = xp % xpPerLevel
        return min(1.0, Double(xpInCurrentLevel) / Double(xpPerLevel))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    walletHero.slideIn(delay: 0)
                    checkinCard.slideIn(delay: 0.05)
                    tabSelector.slideIn(delay: 0.08)
                    tabContent.slideIn(delay: 0.1)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.base)
                .padding(.bottom, 120)
            }
            .refreshable { await appState.loadDashboard() }
        }
        .navigationTitle("Rewards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Error", isPresented: Binding(
            get: { rewardsError != nil },
            set: { if !$0 { rewardsError = nil } }
        )) {
            Button("OK") { rewardsError = nil }
        } message: {
            Text(rewardsError ?? "")
        }
    }

    // MARK: - Wallet Hero

    private var walletHero: some View {
        VStack(spacing: AppSpacing.lg) {
            HStack(spacing: 0) {
                walletStat(icon: "star.fill", value: "\(wallet?.xp_total ?? 0)", label: "XP", color: AppColors.warning)
                Rectangle().fill(AppColors.border).frame(width: 1, height: 44)
                walletStat(icon: "dollarsign.circle.fill", value: "\(wallet?.points_balance ?? 0)", label: "POINTS", color: AppColors.accent)
                Rectangle().fill(AppColors.border).frame(width: 1, height: 44)
                walletStat(icon: "ticket.fill", value: "\(wallet?.tickets_balance ?? 0)", label: "TICKETS", color: AppColors.info)
            }

            if let tier = wallet?.tier, let level = wallet?.level {
                HStack(spacing: 10) {
                    tierBadge(tier)

                    Text("Level \(level)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    HStack(spacing: 6) {
                        ProgressView(value: levelProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
                            .frame(width: 60)
                        Text("\(Int(levelProgress * 100))%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.accent)
                    }
                }
            }
        }
        .chromeCard(accentGlow: true)
    }

    private func walletStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private func tierBadge(_ tier: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: AppTheme.tierIcon(tier)).font(.system(size: 11))
            Text(tier.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
        }
        .foregroundStyle(AppTheme.tierColor(tier))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(AppTheme.tierColor(tier).opacity(0.12))
                .overlay(Capsule().stroke(AppTheme.tierColor(tier).opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Check-in

    private var checkinCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.warning)
                    Text("\(wallet?.streak_days ?? 0) days")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                }
                Text("Current streak")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Button {
                Task { await performCheckin() }
            } label: {
                HStack(spacing: 6) {
                    if isCheckinLoading {
                        ProgressView().tint(.black).scaleEffect(0.8)
                    } else if checkinSuccess {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "hand.tap.fill")
                    }
                    Text(checkinSuccess ? "Done!" : "Check-in")
                }
                .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(PrimaryButtonStyle(isSmall: true))
            .disabled(isCheckinLoading || checkinSuccess)
        }
        .bentoCard()
    }

    // MARK: - Tabs

    private var tabSelector: some View {
        HStack(spacing: 6) {
            ForEach(RewardsTab.allCases, id: \.self) { tab in
                let isSelected = selectedTab == tab
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedTab = tab }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.icon).font(.system(size: 11))
                        Text(tab.rawValue).font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(isSelected ? .black : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                            .fill(isSelected ? AppColors.accent : AppColors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                    .stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .missions: missionsContent
        case .raffles:  rafflesContent
        case .history:  historyContent
        }
    }

    // MARK: - Missions

    private var missionsContent: some View {
        VStack(spacing: 10) {
            if let missions = appState.rewardsSummary?.missions, !missions.isEmpty {
                ForEach(missions) { mission in missionCard(mission) }
            } else {
                EmptyStateView(icon: "target", title: "No missions", subtitle: "New missions will be available soon")
            }
        }
    }

    private func missionCard(_ mission: MissionData) -> some View {
        let isCompleted = mission.user_completed ?? false
        let progress = Double(mission.user_progress ?? 0) / Double(max(mission.condition_value ?? 1, 1))

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(mission.title ?? "Mission")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(mission.description ?? "")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColors.success)
                }
            }

            HStack(spacing: 10) {
                ProgressView(value: min(progress, 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: isCompleted ? AppColors.success : AppColors.accent))
                Text("\(mission.user_progress ?? 0)/\(mission.condition_value ?? 0)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }

            HStack(spacing: 14) {
                if let xp = mission.xp_reward, xp > 0 {
                    Label("+\(xp) XP", systemImage: "star.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.warning)
                }
                if let pts = mission.points_reward, pts > 0 {
                    Label("+\(pts) pts", systemImage: "dollarsign.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .bentoCard()
        .opacity(isCompleted ? 0.65 : 1)
    }

    // MARK: - Raffles

    private var rafflesContent: some View {
        VStack(spacing: 10) {
            if let raffles = appState.rewardsSummary?.raffles, !raffles.isEmpty {
                ForEach(raffles) { raffle in raffleCard(raffle) }
            } else {
                EmptyStateView(icon: "ticket.fill", title: "No active raffles", subtitle: "Come back soon for exclusive giveaways")
            }
        }
    }

    private func raffleCard(_ raffle: RaffleData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageUrl = raffle.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill().frame(height: 110).clipped()
                    default:
                        Rectangle().fill(AppColors.surfaceSecondary).frame(height: 110)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(raffle.title ?? "Raffle")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Text(raffle.prize_description ?? "")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)

                if let drawDate = raffle.draw_date {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar").font(.system(size: 10))
                        Text("Draw: \(formatDate(drawDate))")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(AppColors.accent)
                }
            }

            Button {
                enteringRaffle = raffle.id
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "ticket.fill")
                    Text("Enter (1 ticket)")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled((wallet?.tickets_balance ?? 0) < 1)
            .confirmationDialog("Enter Raffle", isPresented: Binding(
                get: { enteringRaffle == raffle.id },
                set: { if !$0 { enteringRaffle = nil } }
            )) {
                Button("Use 1 ticket to enter") {
                    enteringRaffle = nil
                    Task { await enterRaffle(raffleId: raffle.id) }
                }
                Button("Cancel", role: .cancel) { enteringRaffle = nil }
            } message: {
                Text("Use 1 ticket to enter \"\(raffle.title ?? "this raffle")\"?")
            }
        }
        .bentoCard()
    }

    // MARK: - History

    private var historyContent: some View {
        VStack(spacing: 8) {
            if let txns = appState.rewardsSummary?.recent_transactions, !txns.isEmpty {
                ForEach(txns) { tx in transactionRow(tx) }
            } else {
                EmptyStateView(icon: "clock.fill", title: "No transactions", subtitle: "Your reward activity will appear here")
            }
        }
    }

    private func transactionRow(_ tx: TransactionData) -> some View {
        let positive = (tx.delta ?? 0) > 0

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill((positive ? AppColors.success : AppColors.error).opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: positive ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(positive ? AppColors.success : AppColors.error)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(tx.reason ?? tx.type ?? "Transaction")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                Text(tx.description ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textTertiary)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(positive ? "+" : "")\(tx.delta ?? 0)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(positive ? AppColors.success : AppColors.error)
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.surface)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous).stroke(AppColors.border, lineWidth: 1))
        )
    }

    // MARK: - Actions

    private func performCheckin() async {
        isCheckinLoading = true
        do {
            _ = try await appState.apiService.dailyCheckin()
            await appState.loadDashboard()
            HapticFeedback.success()
            isCheckinLoading = false
            checkinSuccess = true
        } catch {
            HapticFeedback.error()
            rewardsError = "Check-in failed. Try again later."
            isCheckinLoading = false
            appLog("Daily checkin failed: \(error.localizedDescription)", level: .error, category: .data)
        }
    }

    private func enterRaffle(raffleId: String) async {
        do {
            try await appState.apiService.enterRaffle(raffleId: raffleId)
            await appState.loadDashboard()
            HapticFeedback.success()
            raffleEntrySuccess = true
        } catch {
            HapticFeedback.error()
            rewardsError = "Unable to enter raffle. Try again."
            appLog("Raffle entry failed: \(error.localizedDescription)", level: .error, category: .data)
        }
    }

    private func formatDate(_ raw: String) -> String {
        DateFormatHelper.formatISO(raw)
    }
}

#Preview {
    NavigationStack { RewardsHubView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
