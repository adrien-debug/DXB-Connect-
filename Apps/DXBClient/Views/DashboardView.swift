import SwiftUI
import DXBCore

struct DashboardView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var wallet: UserWallet?
    @State private var missions: [MissionItem] = []
    @State private var hasCheckedInToday = false
    @State private var isLoadingRewards = true

    @State private var heroAnimated = false
    @State private var ringProgress: CGFloat = 0
    @State private var statCounters: [CGFloat] = [0, 0, 0]

    @State private var showSupport = false
    @State private var showScanner = false

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingRadius = AppTheme.Banking.Radius
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    var body: some View {
        NavigationStack {
            ZStack {
                BankingColors.backgroundPrimary.ignoresSafeArea()

                ambientGlow

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        smartHeader
                            .padding(.top, 8)

                        heroDataCard
                            .padding(.horizontal, BankingSpacing.lg)
                            .padding(.top, BankingSpacing.xl)

                        quickActions
                            .padding(.horizontal, BankingSpacing.lg)
                            .padding(.top, BankingSpacing.lg)

                        analyticsSection
                            .padding(.horizontal, BankingSpacing.lg)
                            .padding(.top, BankingSpacing.xxl)

                        levelRewardsCard
                            .padding(.horizontal, BankingSpacing.lg)
                            .padding(.top, BankingSpacing.xl)

                        esimCardsSection
                            .padding(.horizontal, BankingSpacing.lg)
                            .padding(.top, BankingSpacing.xl)

                        Spacer(minLength: 120)
                    }
                }
            }
            .navigationBarHidden(true)
            .task {
                if !coordinator.hasLoadedInitialData {
                    await coordinator.loadAllData()
                }
                await loadRewardsSummary()
                animateOnAppear()
            }
            .refreshable {
                await coordinator.loadAllData()
                await loadRewardsSummary()
            }
        }
        .sheet(isPresented: $showSupport) { SupportView() }
        .sheet(isPresented: $showScanner) { ScannerSheet() }
    }

    // MARK: - Ambient Glow (subtle lime atmosphere)

    private var ambientGlow: some View {
        ZStack {
            RadialGradient(
                colors: [
                    BankingColors.accent.opacity(0.10),
                    BankingColors.accent.opacity(0.03),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
            .frame(height: 600)
            .offset(y: -150)

            RadialGradient(
                colors: [
                    BankingColors.accent.opacity(0.05),
                    Color.clear
                ],
                center: .center,
                startRadius: 100,
                endRadius: 300
            )
            .frame(width: 400, height: 400)
            .offset(y: 200)
            .blur(radius: 60)
        }
        .ignoresSafeArea()
    }

    // MARK: - Smart Header

    private var smartHeader: some View {
        HStack(spacing: 14) {
            // Avatar
            Button {
                HapticFeedback.light()
                coordinator.selectedTab = 4
            } label: {
                ZStack {
                    Circle()
                        .fill(BankingColors.accent)
                        .frame(width: 46, height: 46)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.25), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 46, height: 46)

                    Text(String(coordinator.user.name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(BankingColors.backgroundPrimary)
                }
                .shadow(color: BankingColors.accent.opacity(0.35), radius: 10, x: 0, y: 4)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(greeting)
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnDarkMuted)

                Text(firstName)
                    .font(BankingTypo.cardAmount())
                    .foregroundColor(BankingColors.textOnDarkPrimary)
            }

            Spacer()

            // Notification button
            Button {
                HapticFeedback.light()
                coordinator.showNotifications = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(BankingColors.backgroundSecondary)
                        .frame(width: 42, height: 42)
                        .overlay(
                            Circle()
                                .stroke(BankingColors.textOnDarkMuted.opacity(0.15), lineWidth: 1)
                        )

                    Image(systemName: "bell")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(BankingColors.textOnDarkPrimary)
                        .frame(width: 42, height: 42)

                    if !coordinator.notifications.isEmpty {
                        Circle()
                            .fill(BankingColors.accent)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(BankingColors.backgroundPrimary, lineWidth: 2))
                            .offset(x: -4, y: 4)
                    }
                }
            }
        }
        .padding(.horizontal, BankingSpacing.lg)
        .slideIn(delay: 0)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private var firstName: String {
        coordinator.user.name.components(separatedBy: " ").first ?? coordinator.user.name
    }

    // MARK: - Hero Data Card (Banking Style — Lime background)

    private var heroDataCard: some View {
        VStack(spacing: 0) {
            // Balance header
            VStack(spacing: 4) {
                Text("Total Balance")
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(remainingDataDisplay.0)
                        .font(BankingTypo.heroAmount())
                        .foregroundColor(BankingColors.textOnLightPrimary)
                        .contentTransition(.numericText())

                    Text(remainingDataDisplay.1)
                        .font(BankingTypo.sectionTitle())
                        .foregroundColor(BankingColors.textOnLightSecondary)
                }
            }
            .padding(.top, BankingSpacing.xl)

            // Quick action buttons (Send / Request style)
            HStack(spacing: BankingSpacing.md) {
                heroActionButton(icon: "arrow.up.circle.fill", label: "Send")
                heroActionButton(icon: "arrow.down.circle.fill", label: "Request")
            }
            .padding(.top, BankingSpacing.lg)
            .padding(.bottom, BankingSpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.accent)
                .shadow(color: BankingColors.accentDark.opacity(0.4), radius: 20, x: 0, y: 10)
        )
        .slideIn(delay: 0.05)
    }

    private func heroActionButton(icon: String, label: String) -> some View {
        Button {
            HapticFeedback.light()
        } label: {
            HStack(spacing: 6) {
                Text(label)
                    .font(BankingTypo.button())
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(BankingColors.textOnLightPrimary)
            .padding(.horizontal, BankingSpacing.lg)
            .padding(.vertical, BankingSpacing.md)
            .background(
                Capsule()
                    .fill(BankingColors.backgroundPrimary)
            )
        }
        .scaleOnPress()
    }


    private var remainingDataDisplay: (String, String) {
        let totalRemaining = totalRemainingGB
        if totalRemaining >= 1 {
            return (String(format: "%.1f", totalRemaining), "GB")
        } else {
            return (String(format: "%.0f", totalRemaining * 1024), "MB")
        }
    }

    private var totalRemainingGB: Double {
        var total: Int64 = 0
        for order in coordinator.esimOrders {
            if let usage = coordinator.usageCache[order.iccid] {
                total += usage.remainingBytes
            }
        }
        return Double(total) / 1_073_741_824
    }

    private var usagePercent: Int {
        let activeOrders = coordinator.esimOrders.filter {
            $0.status.uppercased() == "RELEASED" || $0.status.uppercased() == "IN_USE"
        }
        guard !activeOrders.isEmpty else { return 0 }

        var totalUsed: Int64 = 0
        var totalVolume: Int64 = 0
        for order in activeOrders {
            if let usage = coordinator.usageCache[order.iccid] {
                totalUsed += usage.usedBytes
                totalVolume += usage.totalBytes
            }
        }
        guard totalVolume > 0 else { return 0 }
        return Int(Double(totalUsed) / Double(totalVolume) * 100)
    }

    private var daysRemaining: Int {
        7
    }

    private var weeklyUsageData: [CGFloat] {
        [0.2, 0.4, 0.35, 0.6, 0.5, 0.8, 0.7]
    }

    // MARK: - Cards Section (Banking Style — horizontal mini cards)

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.md) {
            Text("Cards")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BankingSpacing.md) {
                    // Card 1 — Primary
                    miniCardView(
                        balance: "$\(String(format: "%.2f", totalRemainingGB * 10))",
                        label: "Debit",
                        lastDigits: "4315",
                        gradient: [BankingColors.backgroundPrimary, BankingColors.backgroundSecondary]
                    )

                    // Card 2 — Virtual
                    miniCardView(
                        balance: "$\(String(format: "%.2f", totalRemainingGB * 5))",
                        label: "Virtual",
                        lastDigits: "5161",
                        gradient: [BankingColors.backgroundTertiary, BankingColors.backgroundSecondary]
                    )

                    // Add card button
                    Button {
                        HapticFeedback.light()
                        coordinator.selectedTab = 1
                    } label: {
                        VStack {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(BankingColors.textOnDarkMuted)
                        }
                        .frame(width: 100, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                                .fill(BankingColors.backgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                                        .stroke(BankingColors.borderDark, lineWidth: 1)
                                )
                        )
                    }
                    .scaleOnPress()
                }
            }
        }
        .slideIn(delay: 0.1)
    }

    private func miniCardView(balance: String, label: String, lastDigits: String, gradient: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(balance)
                .font(BankingTypo.cardAmount())
                .foregroundColor(label == "Debit" ? BankingColors.accent : BankingColors.textOnDarkPrimary)

            HStack {
                Text(label)
                    .font(BankingTypo.label())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(label == "Debit" ? BankingColors.accent : BankingColors.textOnDarkMuted.opacity(0.3))
                    )
                    .foregroundColor(label == "Debit" ? BankingColors.backgroundPrimary : BankingColors.textOnDarkPrimary)

                Spacer()

                Text("*\(lastDigits)")
                    .font(BankingTypo.small())
                    .foregroundColor(BankingColors.textOnDarkMuted)
            }
        }
        .padding(BankingSpacing.md)
        .frame(width: 140, height: 70)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                .fill(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                        .stroke(BankingColors.borderDark, lineWidth: 1)
                )
        )
    }

    // MARK: - Monthly Budget (Banking Style)

    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.base) {
            // Budget card
            HStack(spacing: BankingSpacing.md) {
                // Progress pie
                ZStack {
                    Circle()
                        .stroke(BankingColors.surfaceMedium, lineWidth: 6)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: CGFloat(usagePercent) / 100)
                        .stroke(BankingColors.accentDark, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Monthly budget")
                        .font(BankingTypo.body())
                        .foregroundColor(BankingColors.textOnLightPrimary)

                    Text("$\(String(format: "%.2f", totalRemainingGB * 3)) a day")
                        .font(BankingTypo.caption())
                        .foregroundColor(BankingColors.textOnLightMuted)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(String(format: "%.2f", totalRemainingGB * 30)) left")
                        .font(BankingTypo.cardAmount())
                        .foregroundColor(BankingColors.textOnLightPrimary)

                    Text("of $\(String(format: "%.2f", totalRemainingGB * 100))")
                        .font(BankingTypo.caption())
                        .foregroundColor(BankingColors.textOnLightMuted)
                }
            }
            .padding(BankingSpacing.base)
            .background(
                RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                    .fill(BankingColors.surfaceLight)
                    .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
            )

            // Stats grid (Banking style — 2 columns)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BankingSpacing.md) {
                bankingStatCard(icon: "cart.fill", amount: "$\(Int(coordinator.user.totalSaved))", label: "Shopping", percent: "45.2%")
                bankingStatCard(icon: "airplane", amount: "$\(Int(totalRemainingGB * 20))", label: "Travel", percent: "23.0%")
                bankingStatCard(icon: "fork.knife", amount: "$48.72", label: "Food", percent: "11.4%")
                bankingStatCard(icon: "heart.fill", amount: "$34.58", label: "Health", percent: "8.1%")
            }
        }
        .slideIn(delay: 0.15)
    }

    private func bankingStatCard(icon: String, amount: String, label: String, percent: String) -> some View {
        HStack(spacing: BankingSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BankingColors.textOnLightSecondary)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(BankingColors.surfaceMedium)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(amount)
                    .font(BankingTypo.cardAmount())
                    .foregroundColor(BankingColors.textOnLightPrimary)

                Text(label)
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightMuted)
            }

            Spacer()

            Text(percent)
                .font(BankingTypo.caption())
                .foregroundColor(BankingColors.textOnLightMuted)
        }
        .padding(BankingSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                .fill(BankingColors.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                        .stroke(BankingColors.borderLight, lineWidth: 1)
                )
        )
    }

    // MARK: - Recent Transactions (Banking Style)

    private var levelRewardsCard: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.base) {
            Text("Recent transactions")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            VStack(spacing: 0) {
                transactionRow(
                    icon: "cart.fill",
                    iconBg: BankingColors.surfaceMedium,
                    title: coordinator.user.name,
                    subtitle: "Shopping",
                    amount: "-$\(String(format: "%.2f", totalRemainingGB * 4))",
                    time: "6:41 PM",
                    isNegative: true
                )

                Divider().background(BankingColors.borderLight)

                transactionRow(
                    icon: "person.fill",
                    iconBg: BankingColors.surfaceMedium,
                    title: "Bob Green",
                    subtitle: "Transaction",
                    amount: "+$750.00",
                    time: "4:17 PM",
                    isNegative: false
                )

                Divider().background(BankingColors.borderLight)

                transactionRow(
                    icon: "bus.fill",
                    iconBg: BankingColors.surfaceMedium,
                    title: "Bus tickets",
                    subtitle: "LA—SF",
                    amount: "-$47.49",
                    time: "2:32 PM",
                    isNegative: true
                )
            }
            .background(
                RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                    .fill(BankingColors.surfaceLight)
                    .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
            )
        }
        .slideIn(delay: 0.2)
    }

    private func transactionRow(icon: String, iconBg: Color, title: String, subtitle: String, amount: String, time: String, isNegative: Bool) -> some View {
        HStack(spacing: BankingSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BankingColors.textOnLightSecondary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(iconBg)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BankingTypo.body())
                    .foregroundColor(BankingColors.textOnLightPrimary)

                Text(subtitle)
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(amount)
                    .font(BankingTypo.body())
                    .foregroundColor(isNegative ? BankingColors.textOnLightPrimary : BankingColors.accentDark)

                Text(time)
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightMuted)
            }
        }
        .padding(.horizontal, BankingSpacing.base)
        .padding(.vertical, BankingSpacing.md)
    }

    private var xpProgress: CGFloat {
        guard xpForNextLevel > 0 else { return 0 }
        return CGFloat(wallet?.xp_total ?? 0) / CGFloat(xpForNextLevel)
    }

    private var xpForNextLevel: Int {
        let level = wallet?.level ?? 1
        let thresholds = [500, 1500, 3000, 5000, 8000, 12000, 18000, 25000, 35000]
        if level - 1 < thresholds.count {
            return thresholds[level - 1]
        }
        return 35000 + (level - 9) * 15000
    }

    // MARK: - eSIM Cards Section (Banking Style)

    private var esimCardsSection: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.base) {
            HStack(alignment: .bottom) {
                Text("My eSIMs")
                    .font(BankingTypo.sectionTitle())
                    .foregroundColor(BankingColors.textOnDarkPrimary)

                Spacer()

                if !coordinator.esimOrders.isEmpty {
                    Button {
                        coordinator.selectedTab = 3
                    } label: {
                        HStack(spacing: 4) {
                            Text("View all")
                                .font(BankingTypo.caption())
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(BankingColors.accent)
                    }
                }
            }

            if coordinator.esimOrders.isEmpty {
                emptyESIMCard
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(coordinator.esimOrders.prefix(3).enumerated()), id: \.element.id) { index, order in
                        NavigationLink {
                            ESIMDetailView(order: order)
                        } label: {
                            bankingESIMRow(order: order)
                        }
                        .buttonStyle(.plain)

                        if index < min(2, coordinator.esimOrders.count - 1) {
                            Divider().background(BankingColors.borderLight)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                        .fill(BankingColors.surfaceLight)
                        .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
                )
            }
        }
        .slideIn(delay: 0.25)
    }

    private var emptyESIMCard: some View {
        VStack(spacing: BankingSpacing.lg) {
            ZStack {
                Circle()
                    .fill(BankingColors.accent.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: "simcard")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(BankingColors.accent)
            }

            VStack(spacing: 6) {
                Text("No eSIMs yet")
                    .font(BankingTypo.body())
                    .foregroundColor(BankingColors.textOnLightPrimary)

                Text("Get connected worldwide in seconds")
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightMuted)
            }

            Button {
                coordinator.selectedTab = 1
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Get Started")
                        .font(BankingTypo.button())
                }
                .foregroundColor(BankingColors.backgroundPrimary)
                .padding(.horizontal, BankingSpacing.xl)
                .padding(.vertical, BankingSpacing.md)
                .background(
                    Capsule()
                        .fill(BankingColors.accent)
                        .shadow(color: BankingColors.accentDark.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .scaleOnPress()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BankingSpacing.xxxl)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.surfaceLight)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
        )
    }

    private func bankingESIMRow(order: ESIMOrder) -> some View {
        let isActive = order.status.uppercased() == "RELEASED" || order.status.uppercased() == "IN_USE"
        let usagePercent = coordinator.usagePercentage(for: order)
        let remainingPercent = max(0, 1.0 - usagePercent)

        return HStack(spacing: BankingSpacing.md) {
            // Flag
            Text(flagEmoji(for: order.packageName))
                .font(.system(size: 28))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(BankingColors.surfaceMedium)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(order.packageName)
                    .font(BankingTypo.body())
                    .foregroundColor(BankingColors.textOnLightPrimary)
                    .lineLimit(1)

                Text(isActive ? "Active" : order.status.capitalized)
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(remainingPercent * 100))%")
                    .font(BankingTypo.body())
                    .foregroundColor(isActive ? BankingColors.accentDark : BankingColors.textOnLightPrimary)

                Text("remaining")
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightMuted)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(BankingColors.textOnLightMuted)
        }
        .padding(.horizontal, BankingSpacing.base)
        .padding(.vertical, BankingSpacing.md)
    }

    private func flagEmoji(for packageName: String) -> String {
        let name = packageName.lowercased()
        if name.contains("arab") || name.contains("uae") || name.contains("emirates") { return "🇦🇪" }
        if name.contains("turkey") || name.contains("türkiye") { return "🇹🇷" }
        if name.contains("europe") { return "🇪🇺" }
        if name.contains("usa") || name.contains("united states") { return "🇺🇸" }
        if name.contains("japan") { return "🇯🇵" }
        if name.contains("uk") || name.contains("kingdom") { return "🇬🇧" }
        return "🌍"
    }

    // MARK: - Data Loading

    private func loadRewardsSummary() async {
        isLoadingRewards = true
        do {
            let summary = try await coordinator.currentAPIService.fetchRewardsSummary()

            if let w = summary.wallet {
                wallet = UserWallet(
                    xp_total: w.xp_total ?? 0,
                    level: w.level ?? 1,
                    points_balance: w.points_balance ?? 0,
                    points_earned_total: w.points_earned_total ?? 0,
                    tickets_balance: w.tickets_balance ?? 0,
                    tier: w.tier ?? "bronze",
                    streak_days: w.streak_days ?? 0
                )

                if let lastCheckin = w.last_checkin {
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let checkinDate = formatter.date(from: lastCheckin) {
                        hasCheckedInToday = Calendar.current.isDateInToday(checkinDate)
                    }
                }
            }

            if let m = summary.missions {
                missions = m.map { md in
                    MissionItem(
                        id: md.id,
                        type: md.type ?? "daily",
                        title: md.title ?? "",
                        description: md.description,
                        xp_reward: md.xp_reward ?? 0,
                        points_reward: md.points_reward ?? 0,
                        condition_value: md.condition_value ?? 1,
                        user_progress: md.user_progress,
                        user_completed: md.user_completed
                    )
                }
            }
        } catch {
            appLogError(error, message: "Failed to load rewards", category: .data)
        }
        isLoadingRewards = false
    }

    private func performCheckin() async {
        do {
            _ = try await coordinator.currentAPIService.dailyCheckin()
            HapticFeedback.success()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                hasCheckedInToday = true
            }
            await loadRewardsSummary()
        } catch {
            appLogError(error, message: "Check-in failed", category: .data)
        }
    }

    private func animateOnAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                heroAnimated = true
                ringProgress = CGFloat(usagePercent) / 100.0
            }
        }
    }
}

// MARK: - Supporting Views

struct PulsingDotModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

struct SparklineView: View {
    let data: [CGFloat]
    @State private var animationProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let maxVal = data.max() ?? 1
            let minVal = data.min() ?? 0
            let range = maxVal - minVal
            let padding: CGFloat = 4

            let points = data.enumerated().map { index, value in
                CGPoint(
                    x: geo.size.width * CGFloat(index) / CGFloat(max(data.count - 1, 1)),
                    y: padding + (geo.size.height - padding * 2) * (1 - (value - minVal) / max(range, 0.01))
                )
            }

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geo.size.height))
                    for point in points {
                        path.addLine(to: point)
                    }
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Banking.Colors.accent.opacity(0.4), AppTheme.Banking.Colors.accent.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(animationProgress)

                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: first)
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .trim(from: 0, to: animationProgress)
                .stroke(AppTheme.Banking.Colors.accent, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                if let last = points.last {
                    Circle()
                        .fill(AppTheme.Banking.Colors.accent)
                        .frame(width: 5, height: 5)
                        .position(x: last.x, y: last.y)
                        .opacity(animationProgress)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationProgress = 1
            }
        }
    }
}

struct WeeklyUsageChart: View {
    let data: [CGFloat]
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    @State private var appeared = false

    var body: some View {
        GeometryReader { geo in
            let maxVal = data.max() ?? 1
            let spacing: CGFloat = 6
            let barWidth: CGFloat = (geo.size.width - CGFloat(data.count - 1) * spacing) / CGFloat(data.count)
            let chartHeight = geo.size.height - 24

            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        let isLast = index == data.count - 1
                        let barHeight = max(chartHeight * (value / maxVal), 4)

                        RoundedRectangle(cornerRadius: CGFloat(AppTheme.Banking.Radius.chartBar))
                            .fill(isLast ? AppTheme.Banking.Colors.accent : AppTheme.Banking.Colors.textOnDarkMuted.opacity(0.3))
                            .frame(width: barWidth, height: appeared ? barHeight : 4)
                            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06), value: appeared)
                            .shadow(color: isLast ? AppTheme.Banking.Colors.accent.opacity(0.4) : .clear, radius: 6, x: 0, y: 2)
                    }
                }
                .frame(height: chartHeight)

                HStack(spacing: spacing) {
                    ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                        Text(day)
                            .font(AppTheme.Banking.Typography.label())
                            .foregroundColor(index == days.count - 1 ? AppTheme.Banking.Colors.textOnDarkPrimary : AppTheme.Banking.Colors.textOnDarkMuted)
                            .frame(width: barWidth)
                    }
                }
            }
            .onAppear { appeared = true }
        }
    }
}

// MARK: - Dashboard Models

typealias DashboardWallet = UserWallet
typealias DashboardMission = MissionItem

// MARK: - Scanner Sheet

import AVFoundation

struct ScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scannedCode: String?
    @State private var torchOn = false

    var body: some View {
        ZStack {
            AppTheme.Banking.Colors.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Banking.Colors.textOnDarkPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(AppTheme.Banking.Colors.backgroundTertiary)
                                    .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                            )
                    }

                    Spacer()

                    Text("SCAN QR CODE")
                        .font(AppTheme.Banking.Typography.label())
                        .tracking(1.5)
                        .foregroundColor(AppTheme.Banking.Colors.textOnDarkMuted)

                    Spacer()

                    Button {
                        torchOn.toggle()
                    } label: {
                        Image(systemName: torchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(torchOn ? AppTheme.Banking.Colors.accent : AppTheme.Banking.Colors.textOnDarkPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(AppTheme.Banking.Colors.backgroundTertiary)
                                    .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                            )
                    }
                }
                .padding(.horizontal, AppTheme.Banking.Spacing.lg)
                .padding(.top, AppTheme.Banking.Spacing.lg)

                Spacer()

                ZStack {
                    QRScannerView(scannedCode: $scannedCode, torchOn: $torchOn)
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: CGFloat(AppTheme.Banking.Radius.card)))

                    RoundedRectangle(cornerRadius: CGFloat(AppTheme.Banking.Radius.card))
                        .stroke(AppTheme.Banking.Colors.accent, lineWidth: 3)
                        .frame(width: 280, height: 280)
                        .shadow(color: AppTheme.Banking.Colors.accent.opacity(0.5), radius: 20, x: 0, y: 0)

                    ScannerCorners()
                        .frame(width: 280, height: 280)
                }

                VStack(spacing: 12) {
                    Text("Position QR code in frame")
                        .font(AppTheme.Banking.Typography.body())
                        .foregroundColor(AppTheme.Banking.Colors.textOnDarkPrimary)

                    Text("Align the eSIM QR code within the scanner area")
                        .font(AppTheme.Banking.Typography.caption())
                        .foregroundColor(AppTheme.Banking.Colors.textOnDarkMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                Spacer()
            }
        }
    }
}

struct ScannerCorners: View {
    var body: some View {
        ZStack {
            ForEach([0, 1, 2, 3], id: \.self) { index in
                CornerShape()
                    .stroke(AppTheme.Banking.Colors.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(
                        x: index == 0 || index == 3 ? -115 : 115,
                        y: index == 0 || index == 1 ? -115 : 115
                    )
            }
        }
    }
}

struct CornerShape: Shape {
    var corner: Int = 0
    var length: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))
        return path
    }
}

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var torchOn: Bool

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        uiViewController.setTorch(on: torchOn)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode)
    }

    class Coordinator: NSObject, QRScannerDelegate {
        @Binding var scannedCode: String?

        init(scannedCode: Binding<String?>) {
            _scannedCode = scannedCode
        }

        func didScan(code: String) {
            HapticFeedback.success()
            scannedCode = code
        }
    }
}

protocol QRScannerDelegate: AnyObject {
    func didScan(code: String)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerDelegate?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            let output = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: .main)
                output.metadataObjectTypes = [.qr]
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            if let layer = previewLayer {
                view.layer.addSublayer(layer)
            }

            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        } catch {
            appLogError(error, message: "Camera setup failed", category: .general)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            appLogError(error, message: "Torch toggle failed", category: .general)
        }
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }

        captureSession.stopRunning()
        delegate?.didScan(code: code)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppCoordinator())
}
