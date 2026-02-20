import SwiftUI
import DXBCore

struct DashboardView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showSupport = false
    @State private var showRewards = false
    @State private var showScanner = false
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundSecondary
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroHeader

                        VStack(spacing: 0) {
                            rewardsWidget
                            perksPreviewSection
                            esimCardsSection
                            recentActivitySection
                        }
                        .padding(.top, AppTheme.Spacing.xl)
                        .padding(.bottom, 100)
                        .background(
                            AppTheme.backgroundPrimary
                                .clipShape(RoundedCorner(radius: AppTheme.Radius.xxl, corners: [.topLeft, .topRight]))
                        )
                        .offset(y: -20)
                    }
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                await coordinator.loadAllData()
            }
            .task {
                if !coordinator.hasLoadedInitialData {
                    await coordinator.loadAllData()
                }
            }
        }
    }

    // MARK: - Hero Header

    private var firstName: String {
        let name = coordinator.user.name
        return name.components(separatedBy: " ").first ?? name
    }

    private var activeESIMCountryCodes: [String] {
        coordinator.esimOrders.compactMap { order in
            let name = order.packageName.lowercased()
            if name.contains("arab") || name.contains("uae") || name.contains("emirates") { return "AE" }
            if name.contains("turkey") || name.contains("türkiye") { return "TR" }
            if name.contains("europe") { return "FR" }
            if name.contains("usa") || name.contains("united states") { return "US" }
            if name.contains("japan") { return "JP" }
            if name.contains("singapore") { return "SG" }
            if name.contains("uk") || name.contains("kingdom") { return "GB" }
            if name.contains("australia") { return "AU" }
            return nil
        }
    }

    private var heroHeader: some View {
        VStack(spacing: 0) {
            ZStack {
                // Animated mesh gradient background
                AnimatedMeshGradient()
                    .opacity(0.6)

                // Dark overlay
                AppTheme.anthracite.opacity(0.85)

                // World map overlay
                WorldMapDarkView(
                    highlightedCodes: activeESIMCountryCodes,
                    showConnections: false,
                    showDubaiPulse: true
                )
                .opacity(0.5)

                // Signal rings centered on Dubai position
                GeometryReader { geo in
                    SignalRings(color: AppTheme.accent.opacity(0.4), size: 120)
                        .position(
                            x: 0.654 * geo.size.width,
                            y: 0.365 * geo.size.height
                        )
                }

                VStack(spacing: 0) {
                    // Top bar with avatar and notifications
                    HStack(spacing: 12) {
                        Button {
                            HapticFeedback.light()
                            coordinator.selectedTab = 4
                        } label: {
                            Circle()
                                .fill(AppTheme.accent)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(String(coordinator.user.name.prefix(1)).uppercased())
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(Color(hex: "0F172A"))
                                )
                        }
                        .accessibilityLabel("Profil")

                        VStack(alignment: .leading, spacing: 2) {
                            Text(greeting)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))

                            Text(firstName.isEmpty ? "Dashboard" : firstName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Button {
                            HapticFeedback.light()
                            coordinator.showNotifications = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.1))
                                    )

                                if !coordinator.notifications.isEmpty {
                                    Circle()
                                        .fill(AppTheme.accent)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 0, y: 2)
                                }
                            }
                        }
                        .accessibilityLabel("Notifications")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                    // Data usage with RadialGauge + stats
                    HStack(spacing: 20) {
                        RadialGauge(
                            progress: aggregateUsagePercentage,
                            size: 90,
                            trackColor: .white.opacity(0.1),
                            fillColor: AppTheme.accent,
                            lineWidth: 6,
                            valueText: totalDataGB,
                            unitText: "GB"
                        )
                        .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Data Usage")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Image(systemName: "simcard.fill")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("\(coordinator.user.activeESIMs) active plans")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.white.opacity(0.1)))

                                HStack(spacing: 6) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("\(coordinator.user.countriesVisited) countries")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color.white.opacity(0.1)))
                            }
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 28)

                    // Quick actions
                    HStack(spacing: 10) {
                        Button {
                            HapticFeedback.light()
                            coordinator.selectedTab = 1
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Buy eSIM")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "0F172A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.accent)
                            )
                        }
                        .pulse(color: AppTheme.accent, radius: 16)
                        .scaleOnPress()

                        Button {
                            HapticFeedback.light()
                            showScanner = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Scan")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .glassmorphism(cornerRadius: 16, opacity: 0.1)
                        }
                        .scaleOnPress()

                        Button {
                            HapticFeedback.light()
                            showSupport = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 54, height: 54)
                                .glassmorphism(cornerRadius: 16, opacity: 0.1)
                        }
                        .scaleOnPress()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .frame(height: 320)
            .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
            .shadow(color: AppTheme.anthracite.opacity(0.4), radius: 20, x: 0, y: 10)
            .slideIn(delay: 0)
        }
        .sheet(isPresented: $showSupport) { SupportView() }
        .sheet(isPresented: $showRewards) {
            RewardsHubView()
                .environmentObject(coordinator)
        }
        .sheet(isPresented: $showScanner) { ScannerSheet() }
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

    // MARK: - Stats Grid

    private var aggregateUsagePercentage: Double {
        let activeOrders = coordinator.esimOrders.filter {
            let s = $0.status.uppercased()
            return s == "RELEASED" || s == "IN_USE" || s == "ENABLED"
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
        return Double(totalUsed) / Double(totalVolume)
    }

    private var totalDataGB: String {
        let totalMB = coordinator.esimOrders
            .filter { $0.status.uppercased() == "RELEASED" || $0.status.uppercased() == "IN_USE" }
            .reduce(0) { sum, order in
                let volume = order.totalVolume.uppercased()
                if volume.contains("GB") {
                    let gb = Double(volume.replacingOccurrences(of: "GB", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
                    return sum + Int(gb * 1024)
                } else if volume.contains("MB") {
                    return sum + (Int(volume.replacingOccurrences(of: "MB", with: "").trimmingCharacters(in: .whitespaces)) ?? 0)
                }
                return sum
            }
        let gb = Double(totalMB) / 1024.0
        return gb > 0 ? String(format: "%.0f", gb) : "0"
    }

    // MARK: - Rewards Widget

    private var rewardsWidget: some View {
        Button {
            HapticFeedback.light()
            showRewards = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "star.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Rewards Hub")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Check in daily, complete missions, win prizes")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.backgroundPrimary)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [AppTheme.accent.opacity(0.3), AppTheme.accent.opacity(0.05)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, AppTheme.Spacing.md)
        .slideIn(delay: 0.02)
    }

    // MARK: - Perks Preview

    private var perksPreviewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Travel Perks")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Button {
                    coordinator.selectedTab = 2
                } label: {
                    Text("See all")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    perkQuickCard(icon: "ticket.fill", title: "Activities", subtitle: "Up to 15% off", color: AppTheme.accent)
                    perkQuickCard(icon: "airplane", title: "Lounges", subtitle: "From $32", color: AppTheme.primary)
                    perkQuickCard(icon: "shield.fill", title: "Insurance", subtitle: "10% off", color: AppTheme.success)
                    perkQuickCard(icon: "car.fill", title: "Transfers", subtitle: "10% off", color: AppTheme.warning)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, AppTheme.Spacing.lg)
        .slideIn(delay: 0.03)
    }

    private func perkQuickCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button {
            HapticFeedback.light()
            coordinator.selectedTab = 2
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            .padding(14)
            .frame(width: 120, height: 105)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.backgroundPrimary)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border.opacity(0.3), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - eSIM Cards (Horizontal Scroll — Pulse "Cards" style)

    private var esimCardsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Your eSIMs")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if !coordinator.esimOrders.isEmpty {
                    Button {
                        coordinator.selectedTab = 3
                    } label: {
                        Text("See all")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.md) {
                    if coordinator.esimOrders.isEmpty {
                        esimCardWidget(
                            name: "No eSIM",
                            data: "—",
                            iccid: "----",
                            isDark: true
                        )
                    } else {
                        ForEach(Array(coordinator.esimOrders.prefix(3).enumerated()), id: \.element.id) { index, order in
                            NavigationLink {
                                ESIMDetailView(order: order)
                            } label: {
                                esimCardWidget(
                                    name: order.packageName,
                                    data: order.totalVolume,
                                    iccid: "*" + String(order.iccid.suffix(4)),
                                    isDark: index == 0
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Add card button
                    Button {
                        HapticFeedback.light()
                        coordinator.selectedTab = 1
                    } label: {
                        VStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(AppTheme.textTertiary)
                            Spacer()
                        }
                        .frame(width: 80, height: 100)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                .fill(AppTheme.gray100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                        .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                                        .foregroundColor(AppTheme.gray500.opacity(0.4))
                                )
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
            }
        }
        .padding(.top, AppTheme.Spacing.xs)
        .slideIn(delay: 0.05)
    }

    private func esimCardWidget(name: String, data: String, iccid: String, isDark: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ZStack {
                    Circle()
                        .fill(isDark ? AppTheme.accent : AppTheme.accent.opacity(0.12))
                        .frame(width: 36, height: 36)

                    Image(systemName: "simcard.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isDark ? Color(hex: "0F172A") : AppTheme.accent)
                }
                .floating(duration: 2.5, distance: 3)

                Spacer()

                Text(iccid)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(isDark ? .white.opacity(0.3) : AppTheme.textMuted)
            }

            Spacer()

            Text(data)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(isDark ? .white : AppTheme.textPrimary)

            Text(name.count > 16 ? String(name.prefix(16)) + "..." : name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isDark ? .white.opacity(0.5) : AppTheme.textSecondary)
                .padding(.top, 3)
        }
        .padding(16)
        .frame(width: 175, height: 130)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        isDark
                            ? Color(hex: "0F172A")
                            : AppTheme.backgroundPrimary
                    )

                if isDark {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.accent.opacity(0.5), AppTheme.accent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border.opacity(0.4), lineWidth: 0.5)
                }
            }
            .shadow(color: isDark ? AppTheme.accent.opacity(0.25) : Color.black.opacity(0.06), radius: isDark ? 20 : 8, x: 0, y: isDark ? 8 : 3)
        )
    }

    // MARK: - Data Usage Row (Pulse "Monthly budget" style)



    // MARK: - Recent Activity (Pulse "Recent transactions" style)

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.base) {
            Text("Recent activity")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)

            if coordinator.esimOrders.isEmpty {
                VStack(spacing: AppTheme.Spacing.base) {
                    Image(systemName: "building.columns")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(AppTheme.textTertiary)

                    VStack(spacing: AppTheme.Spacing.xs) {
                        Text("No activity yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Get connected in minutes")
                            .font(AppTheme.Typography.body())
                            .foregroundColor(AppTheme.gray500)
                    }

                    Button {
                        HapticFeedback.light()
                        coordinator.selectedTab = 1
                    } label: {
                        Text("Browse Plans")
                            .font(AppTheme.Typography.button())
                            .foregroundColor(Color(hex: "0F172A"))
                            .padding(.horizontal, 28)
                            .padding(.vertical, AppTheme.Spacing.md)
                            .background(
                                Capsule()
                                    .fill(AppTheme.accent)
                            )
                    }
                }
                .padding(.vertical, AppTheme.Spacing.xxl)
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    ForEach(coordinator.esimOrders.prefix(5)) { order in
                        NavigationLink {
                            ESIMDetailView(order: order)
                        } label: {
                            ActivityRow(order: order)
                        }
                        .buttonStyle(.plain)
                    }

                    if coordinator.esimOrders.count > 5 {
                        Button {
                            coordinator.selectedTab = 3
                        } label: {
                            Text("View all")
                                .font(AppTheme.Typography.button())
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.base)
                        }
                    }
                }
            }
        }
        .slideIn(delay: 0.15)
    }
}

// MARK: - Tech Components

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct DataMetricPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.primary)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(AppTheme.Typography.label())
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HeaderMetric: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "0F172A"))

            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.5)
                .foregroundColor(Color(hex: "0F172A").opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct MiniMetric: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = AppTheme.primary

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}

struct PromoCard: View {
    let flag: String
    let title: String
    let data: String
    let price: String
    let tag: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(flag)
                        .font(.system(size: 20))
                    Spacer()
                    Text(tag)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.gray500)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(price)
                        .font(AppTheme.Typography.cardAmount())
                        .foregroundColor(AppTheme.textPrimary)
                    Text(title)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.gray500)
                }
            }
            .padding(AppTheme.Spacing.base)
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                    .fill(AppTheme.gray100)
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionTech: View {
    let icon: String
    let title: String
    var isPrimary: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(isPrimary ? AppTheme.accent : Color.white)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(isPrimary ? .black : AppTheme.primary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(isPrimary ? .clear : AppTheme.border, lineWidth: 1)
                    )

                Text(title)
                    .font(AppTheme.Typography.small())
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(title)
        .buttonStyle(.plain)
    }
}

// MARK: - Activity Row (Pulse "Recent transactions" style)

struct ActivityRow: View {
    let order: ESIMOrder

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.success
        case "EXPIRED": return AppTheme.gray500
        default: return AppTheme.warning
        }
    }

    private var statusText: String {
        switch order.status.uppercased() {
        case "RELEASED": return "Active"
        case "IN_USE": return "In Use"
        case "EXPIRED": return "Expired"
        default: return order.status.capitalized
        }
    }

    private var flagEmoji: String {
        let name = order.packageName.lowercased()
        if name.contains("arab") || name.contains("uae") || name.contains("emirates") { return "🇦🇪" }
        if name.contains("turkey") || name.contains("türkiye") { return "🇹🇷" }
        if name.contains("europe") { return "🇪🇺" }
        if name.contains("usa") || name.contains("united states") { return "🇺🇸" }
        if name.contains("asia") || name.contains("japan") { return "🇯🇵" }
        if name.contains("saudi") { return "🇸🇦" }
        if name.contains("qatar") { return "🇶🇦" }
        if name.contains("uk") || name.contains("kingdom") { return "🇬🇧" }
        return "🌍"
    }

    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: order.createdAt, relativeTo: Date())
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.1))
                    .frame(width: 50, height: 50)

                Text(flagEmoji)
                    .font(.system(size: 24))

                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.backgroundPrimary, lineWidth: 2)
                    )
                    .offset(x: 17, y: 17)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(order.packageName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(order.totalVolume)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)

                    Text("·")
                        .foregroundColor(AppTheme.textMuted)

                    Text(timeAgo)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(AppTheme.textMuted)
                }
            }

            Spacer()

            Text(statusText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.1))
                )

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

struct EsimTechItem: View {
    let order: ESIMOrder

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.success
        case "EXPIRED": return AppTheme.gray500
        default: return AppTheme.warning
        }
    }

    private var statusText: String {
        switch order.status.uppercased() {
        case "RELEASED": return "ACTIVE"
        case "IN_USE": return "IN USE"
        case "EXPIRED": return "EXPIRED"
        default: return order.status.uppercased()
        }
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Circle()
                .fill(AppTheme.gray100)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "simcard.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.accent)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(order.packageName)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                Text(order.totalVolume)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                    Text(statusText)
                        .font(AppTheme.Typography.label())
                        .foregroundColor(statusColor)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.gray500)
        }
        .padding(.horizontal, AppTheme.Spacing.base)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.03), radius: 4, y: 1)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.lg).stroke(AppTheme.border, lineWidth: 0.5))
        )
        .contentShape(Rectangle())
    }
}

struct EmptyStateTech: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.base) {
            Image(systemName: "simcard")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("No active plans")
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.textPrimary)

                Text("Get connected in minutes")
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.textTertiary)
            }

            Button {
                HapticFeedback.light()
                action()
            } label: {
                Text("Browse Plans")
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(Color(hex: "0F172A"))
                    .padding(.horizontal, 28)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        Capsule()
                            .fill(AppTheme.accent)
                    )
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Navigation Destination

enum DashboardDestination {
    case plans
    case esims
    case profile
}

// MARK: - ViewModel

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var activeEsims = 0
    @Published var dataUsed = "0 GB"
    @Published var totalData = "0"
    @Published var countriesVisited = 0
    @Published var savings = "$0"
    @Published var esimOrders: [ESIMOrder] = []
    @Published var isLoading = false

    @Published var showSupport = false
    @Published var showRewards = false
    @Published var showScanner = false
    @Published var navigateTo: DashboardDestination? = nil

    func loadData(apiService: DXBAPIServiceProtocol) async {
        isLoading = true

        do {
            esimOrders = try await apiService.fetchMyESIMs()
            activeEsims = esimOrders.count
            countriesVisited = Set(esimOrders.map { $0.packageName }).count

            let total = esimOrders.reduce(0) { $0 + (Int($1.totalVolume.replacingOccurrences(of: " GB", with: "")) ?? 0) }
            totalData = "\(total)"
            dataUsed = "0 GB"
            savings = "$0"
        } catch {
            totalData = "0"
            dataUsed = "0 GB"
            savings = "$0"
            countriesVisited = 0
        }

        isLoading = false
    }
}

// MARK: - Rewards Sheet

struct RewardsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.gray100))
                    }

                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.lg)

                Spacer()

                VStack(spacing: AppTheme.Spacing.xl) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "gift.fill")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }

                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("Rewards Coming Soon")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Earn points with every purchase\nand redeem exclusive rewards")
                            .font(AppTheme.Typography.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("GOT IT")
                            .font(AppTheme.Typography.button())
                            .tracking(1)
                            .foregroundColor(Color(hex: "0F172A"))
                            .padding(.horizontal, 40)
                            .padding(.vertical, AppTheme.Spacing.base)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .fill(AppTheme.accent)
                            )
                    }
                    .scaleOnPress()
                }

                Spacer()
            }
        }
    }
}

// MARK: - Scanner Sheet

struct ScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showManualInput = false
    @State private var lpaCode = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var scannedCode: String?
    @State private var isTorchOn = false

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        if showManualInput {
                            showManualInput = false
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: showManualInput ? "arrow.left" : "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.anthracite))
                    }
                    .accessibilityLabel(showManualInput ? "Retour" : "Fermer")

                    Spacer()

                    Text(showManualInput ? "ENTER LPA" : "SCAN QR")
                        .font(AppTheme.Typography.navTitle())
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textSecondary)

                    Spacer()

                    if !showManualInput {
                        Button {
                            isTorchOn.toggle()
                        } label: {
                            Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isTorchOn ? AppTheme.accent : .white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(AppTheme.anthracite))
                        }
                        .accessibilityLabel("Lampe torche")
                    } else {
                        Color.clear.frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.lg)

                if showManualInput {
                    Spacer()

                    VStack(spacing: AppTheme.Spacing.xl) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Text("Enter your LPA code")
                                .font(AppTheme.Typography.sectionTitle())
                                .foregroundColor(.white)

                            Text("Paste the activation code from your eSIM provider")
                                .font(AppTheme.Typography.body())
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: AppTheme.Spacing.md) {
                            TextField("LPA:1$...", text: $lpaCode)
                                .font(AppTheme.Typography.body())
                                .foregroundColor(.white)
                                .padding(AppTheme.Spacing.base)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .fill(AppTheme.backgroundTertiary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                                .stroke(lpaCode.isEmpty ? AppTheme.border : AppTheme.accent, lineWidth: lpaCode.isEmpty ? 1 : 2)
                                        )
                                )
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)

                            if showError {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text(errorMessage)
                                        .font(AppTheme.Typography.caption())
                                }
                                .foregroundColor(AppTheme.error)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        Button {
                            processLPACode()
                        } label: {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("ACTIVATE eSIM")
                                        .font(AppTheme.Typography.caption())
                                        .tracking(1.2)
                                }
                            }
                            .foregroundColor(Color(hex: "0F172A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .fill(lpaCode.isEmpty ? AppTheme.border : AppTheme.accent)
                            )
                        }
                        .disabled(lpaCode.isEmpty || isProcessing)
                        .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    Spacer()
                } else {
                    ZStack {
                        QRScannerView(
                            scannedCode: $scannedCode,
                            isTorchOn: $isTorchOn
                        )
                        .ignoresSafeArea()

                        VStack {
                            Spacer()

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 250, height: 250)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.black.opacity(0.001))
                                    )

                                ScannerCorners()
                            }

                            Spacer()

                            VStack(spacing: 8) {
                                Text("Position QR code in frame")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("Scanning automatically")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.bottom, 40)
                        }
                    }
                }

                if showManualInput {
                    Spacer()
                }

                if !showManualInput {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showManualInput = true
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Enter LPA code manually")
                                .font(AppTheme.Typography.button())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(
                            Capsule()
                                .fill(AppTheme.anthracite.opacity(0.85))
                        )
                    }
                    .padding(.bottom, AppTheme.Spacing.xxxl)
                }
            }
        }
        .onChange(of: scannedCode) { _, newValue in
            if let code = newValue {
                lpaCode = code
                processLPACode()
            }
        }
    }

    private func processLPACode() {
        guard !lpaCode.isEmpty else { return }

        isProcessing = true
        showError = false

        if !lpaCode.hasPrefix("LPA:1$") && !lpaCode.hasPrefix("lpa:1$") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isProcessing = false
                showError = true
                errorMessage = "Invalid LPA format. Code should start with LPA:1$"
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isProcessing = false
            dismiss()
        }
    }
}

// MARK: - QR Scanner View (AVFoundation)

import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isTorchOn: Bool

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        uiViewController.setTorch(on: isTorchOn)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let parent: QRScannerView

        init(parent: QRScannerView) {
            self.parent = parent
        }

        func didScanCode(_ code: String) {
            DispatchQueue.main.async {
                self.parent.scannedCode = code
            }
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func didScanCode(_ code: String)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showNoCameraAlert()
            return
        }

        let captureSession = AVCaptureSession()

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                showNoCameraAlert()
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                showNoCameraAlert()
                return
            }
        } catch {
            showNoCameraAlert()
            return
        }

        self.captureSession = captureSession

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    private func startScanning() {
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }

    private func stopScanning() {
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else { return }

        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {}
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }

        hasScanned = true
        HapticFeedback.success()
        delegate?.didScanCode(stringValue)
    }

    private func showNoCameraAlert() {
        let label = UILabel()
        label.text = "Camera not available"
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - Scanner Corners

struct ScannerCorners: View {
    let cornerLength: CGFloat = 30
    let lineWidth: CGFloat = 4

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { corner in
                CornerShape(corner: corner, length: cornerLength)
                    .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: 250, height: 250)
            }
        }
    }
}

struct CornerShape: Shape {
    let corner: Int
    let length: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch corner {
        case 0: // Top left
            path.move(to: CGPoint(x: 0, y: length))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: length, y: 0))
        case 1: // Top right
            path.move(to: CGPoint(x: rect.width - length, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: length))
        case 2: // Bottom left
            path.move(to: CGPoint(x: 0, y: rect.height - length))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: length, y: rect.height))
        case 3: // Bottom right
            path.move(to: CGPoint(x: rect.width - length, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - length))
        default:
            break
        }
        return path
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppCoordinator())
}
