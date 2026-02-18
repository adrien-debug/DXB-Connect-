import SwiftUI
import DXBCore

struct DashboardView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showSupport = false
    @State private var showRewards = false
    @State private var showScanner = false
    @State private var ringAppear = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroHeader
                        
                        VStack(spacing: 20) {
                            statsGrid
                            
                            promoSection

                            quickActionsGrid

                            activeEsimsSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
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

    private var heroHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "0F172A"), Color(hex: "1E293B"), Color(hex: "0C4A6E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative blobs
            Circle()
                .fill(AppTheme.accent.opacity(0.08))
                .frame(width: 200, height: 200)
                .offset(x: 120, y: -60)
                .blur(radius: 40)

            Circle()
                .fill(Color(hex: "6366F1").opacity(0.06))
                .frame(width: 150, height: 150)
                .offset(x: -100, y: 20)
                .blur(radius: 30)

            VStack(spacing: 0) {
                // Top bar
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(greeting)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "7DD3FC"))

                        Text(firstName.isEmpty ? "Dashboard" : firstName)
                            .font(.system(size: 26, weight: .bold))
                            .tracking(-0.5)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    HStack(spacing: 10) {
                        Button {
                            HapticFeedback.light()
                            coordinator.showNotifications = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(Color.white.opacity(0.12))
                                            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                    )

                                Circle()
                                    .fill(Color(hex: "38BDF8"))
                                    .frame(width: 8, height: 8)
                                    .offset(x: 1, y: 1)
                            }
                        }
                        .accessibilityLabel("Notifications")

                        Button {
                            HapticFeedback.light()
                            coordinator.selectedTab = 3
                        } label: {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "0EA5E9"), Color(hex: "6366F1")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(coordinator.user.name.prefix(1)).uppercased())
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .accessibilityLabel("Profil")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                // Data summary bar
                HStack(spacing: 0) {
                    DataMetricPill(icon: "simcard.fill", value: "\(coordinator.user.activeESIMs)", label: "Active")
                    
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1, height: 28)

                    DataMetricPill(icon: "globe", value: "\(coordinator.user.countriesVisited)", label: "Countries")
                    
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1, height: 28)

                    DataMetricPill(icon: "arrow.down.circle", value: totalDataGB + " GB", label: "Data")
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .clipShape(RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight]))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .slideIn(delay: 0)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning 👋"
        case 12..<17: return "Good afternoon ☀️"
        case 17..<21: return "Good evening 🌆"
        default: return "Good night 🌙"
        }
    }

    // MARK: - Stats Grid

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

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            StatTile(
                icon: "simcard.fill",
                value: "\(coordinator.user.activeESIMs)",
                label: "eSIMs actives",
                accentColor: Color(hex: "0EA5E9")
            )
            StatTile(
                icon: "globe",
                value: "\(coordinator.user.countriesVisited)",
                label: "Pays",
                accentColor: Color(hex: "8B5CF6")
            )
            StatTile(
                icon: "dollarsign.circle",
                value: String(format: "$%.0f", coordinator.user.totalSaved),
                label: "Économisé",
                accentColor: Color(hex: "10B981")
            )
        }
        .slideIn(delay: 0.1)
    }

    // MARK: - Quick Actions

    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIONS RAPIDES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundColor(AppTheme.textTertiary)

            HStack(spacing: 10) {
                QuickActionTech(icon: "plus", title: "Buy", color: AppTheme.accent, isPrimary: true) {
                    coordinator.selectedTab = 1
                }
                QuickActionTech(icon: "qrcode", title: "Scan", color: AppTheme.accent) {
                    showScanner = true
                }
                QuickActionTech(icon: "gift", title: "Rewards", color: Color(hex: "8B5CF6")) {
                    showRewards = true
                }
                QuickActionTech(icon: "headphones", title: "Support", color: Color(hex: "10B981")) {
                    showSupport = true
                }
            }
        }
        .slideIn(delay: 0.15)
        .sheet(isPresented: $showSupport) {
            SupportView()
        }
        .sheet(isPresented: $showRewards) {
            RewardsSheet()
        }
        .sheet(isPresented: $showScanner) {
            ScannerSheet()
        }
    }

    // MARK: - Promo Section

    private var promoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OFFRES SPÉCIALES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundColor(AppTheme.textTertiary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    PromoCard(
                        flag: "🇦🇪",
                        title: "UAE",
                        data: "10 GB • 30 days",
                        price: "$14.99",
                        oldPrice: "$24.99",
                        tag: "-40%",
                        gradientEnd: Color(hex: "0369A1")
                    ) {
                        coordinator.selectedTab = 1
                    }

                    PromoCard(
                        flag: "🇪🇺",
                        title: "Europe",
                        data: "20 GB • 30 days",
                        price: "$37.49",
                        oldPrice: "$49.99",
                        tag: "-25%",
                        gradientEnd: Color(hex: "4F46E5")
                    ) {
                        coordinator.selectedTab = 1
                    }

                    PromoCard(
                        flag: "🇯🇵",
                        title: "Asia",
                        data: "10 GB • 15 days",
                        price: "$27.99",
                        oldPrice: "$39.99",
                        tag: "-30%",
                        gradientEnd: Color(hex: "1D4ED8")
                    ) {
                        coordinator.selectedTab = 1
                    }
                }
            }
        }
        .slideIn(delay: 0.12)
    }

    // MARK: - Active eSIMs

    private var activeEsimsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ACTIVE PLANS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(AppTheme.textTertiary)

                Spacer()

                NavigationLink {
                    MyESIMsView()
                        .environmentObject(coordinator)
                } label: {
                    HStack(spacing: 3) {
                        Text("View all")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }

            if coordinator.esimOrders.isEmpty {
                EmptyStateTech {
                    coordinator.selectedTab = 1
                }
            } else {
                VStack(spacing: 8) {
                    ForEach(coordinator.esimOrders.prefix(3)) { order in
                        NavigationLink {
                            ESIMDetailView(order: order)
                        } label: {
                            EsimTechItem(order: order)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .slideIn(delay: 0.2)
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
                .foregroundColor(Color(hex: "7DD3FC"))

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    var accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)

                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
    }
}

struct MiniMetric: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = AppTheme.textPrimary

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
                .foregroundColor(AppTheme.textTertiary)
        }
    }
}

struct PromoCard: View {
    let flag: String
    let title: String
    let data: String
    let price: String
    let oldPrice: String
    let tag: String
    var gradientEnd: Color = Color(hex: "0C4A6E")
    var action: () -> Void = {}

    var body: some View {
        Button {
            HapticFeedback.medium()
            action()
        } label: {
            VStack(spacing: 0) {
                // Flag header
                HStack {
                    Text(flag)
                        .font(.system(size: 22))

                    Spacer()

                    Text(tag)
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                }

                Spacer(minLength: 6)

                // Title + data
                VStack(spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    Text(data)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)

                Spacer(minLength: 6)

                // Price
                VStack(spacing: 1) {
                    Text(oldPrice)
                        .font(.system(size: 10, weight: .medium))
                        .strikethrough()
                        .foregroundColor(.white.opacity(0.5))

                    Text(price)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.accent, gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Glass shine
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.03),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )

                    // Decorative circle
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 90, height: 90)
                        .offset(x: 30, y: -50)

                    // Border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
            )
            .shadow(color: AppTheme.accent.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .scaleOnPress()
    }
}

struct QuickActionTech: View {
    let icon: String
    let title: String
    var color: Color = AppTheme.textPrimary
    var isPrimary: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button {
            HapticFeedback.light()
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    if isPrimary {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.accent, Color(hex: "0284C7")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                            .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(color.opacity(0.08))
                            .frame(width: 48, height: 48)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(color.opacity(0.12), lineWidth: 1)
                            )
                    }

                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isPrimary ? .white : color)
                }

                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(title)
        .buttonStyle(.plain)
        .scaleOnPress()
    }
}

struct EsimTechItem: View {
    let order: ESIMOrder

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.success
        case "EXPIRED": return AppTheme.gray400
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

    private var isActive: Bool {
        let s = order.status.uppercased()
        return s == "RELEASED" || s == "IN_USE"
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [statusColor.opacity(0.12), statusColor.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: "simcard.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(statusColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(order.packageName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(order.totalVolume)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)

                    if isActive {
                        Circle()
                            .fill(AppTheme.textMuted)
                            .frame(width: 2.5, height: 2.5)

                        HStack(spacing: 3) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 5, height: 5)
                            Text(statusText)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(statusColor)
                        }
                    }
                }
            }

            Spacer()

            if !isActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 5, height: 5)

                    Text(statusText)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(statusColor)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
        .contentShape(Rectangle())
    }
}

struct EmptyStateTech: View {
    var action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentSoft)
                    .frame(width: 56, height: 56)

                Image(systemName: "simcard")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
            }

            VStack(spacing: 4) {
                Text("No active plans")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Get connected in minutes")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }

            Button {
                HapticFeedback.light()
                action()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Browse Plans")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.accent, AppTheme.accentGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .scaleOnPress()
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        colors: [AppTheme.accent.opacity(0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
        )
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
            AppTheme.backgroundPrimary
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
                            .background(Circle().fill(AppTheme.surfaceHeavy))
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentSoft)
                            .frame(width: 100, height: 100)

                        Image(systemName: "gift.fill")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }

                    VStack(spacing: 10) {
                        Text("Rewards Coming Soon")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Earn points with every purchase\nand redeem exclusive rewards")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("GOT IT")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
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
            AppTheme.backgroundPrimary
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
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.surfaceHeavy))
                    }
                    .accessibilityLabel(showManualInput ? "Retour" : "Fermer")

                    Spacer()

                    Text(showManualInput ? "ENTER LPA" : "SCAN QR")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    if !showManualInput {
                        Button {
                            isTorchOn.toggle()
                        } label: {
                            Image(systemName: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isTorchOn ? .yellow : AppTheme.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(AppTheme.surfaceHeavy))
                        }
                        .accessibilityLabel("Lampe torche")
                    } else {
                        Color.clear.frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                if showManualInput {
                    Spacer()

                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Enter your LPA code")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Paste the activation code from your eSIM provider")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 12) {
                            TextField("LPA:1$...", text: $lpaCode)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppTheme.surfaceLight)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
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
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(AppTheme.error)
                            }
                        }
                        .padding(.horizontal, 24)

                        Button {
                            processLPACode()
                        } label: {
                            HStack(spacing: 8) {
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("ACTIVATE eSIM")
                                        .font(.system(size: 13, weight: .bold))
                                        .tracking(1.2)
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(lpaCode.isEmpty ? AppTheme.gray300 : AppTheme.accent)
                            )
                        }
                        .disabled(lpaCode.isEmpty || isProcessing)
                        .padding(.horizontal, 24)
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
                        HStack(spacing: 8) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Enter LPA code manually")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                    }
                    .padding(.bottom, 48)
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
