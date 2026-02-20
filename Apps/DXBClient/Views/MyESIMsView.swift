import SwiftUI
import DXBCore

struct MyESIMsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedFilter = "All"
    @State private var pollingTask: Task<Void, Never>?

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingRadius = AppTheme.Banking.Radius
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    let filters = ["Active", "All", "Expired"]

    var filteredOrders: [ESIMOrder] {
        guard selectedFilter != "All" else { return coordinator.esimOrders }
        return coordinator.esimOrders.filter { order in
            switch selectedFilter {
            case "Active": return order.status.uppercased() == "RELEASED" || order.status.uppercased() == "IN_USE"
            case "Expired": return order.status.uppercased() == "EXPIRED"
            default: return true
            }
        }
    }

    private var hasPendingOrders: Bool {
        coordinator.esimOrders.contains { order in
            let status = order.status.uppercased()
            return status == "PENDING" || status == "PENDING_PAYMENT" || status == "PROCESSING"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BankingColors.backgroundPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerSection
                    filterSection
                    contentSection
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: ESIMOrder.self) { order in
                ESIMDetailView(order: order)
            }
            .refreshable {
                await coordinator.loadESIMs()
            }
            .task {
                if !coordinator.hasLoadedInitialData {
                    await coordinator.loadESIMs()
                }
            }
            .onChange(of: hasPendingOrders) { _, hasPending in
                if hasPending {
                    startPollingForPendingOrders()
                } else {
                    stopPolling()
                }
            }
            .onAppear {
                if hasPendingOrders {
                    startPollingForPendingOrders()
                }
            }
            .onDisappear {
                stopPolling()
            }
        }
    }

    private func startPollingForPendingOrders() {
        stopPolling()

        pollingTask = Task {
            var attempts = 0
            let maxAttempts = 10

            while !Task.isCancelled && attempts < maxAttempts {
                let delay = min(5 + attempts * 5, 30)
                try? await Task.sleep(nanoseconds: UInt64(delay) * 1_000_000_000)
                guard !Task.isCancelled else { break }
                await coordinator.loadESIMs()
                attempts += 1
                if !hasPendingOrders { break }
            }
        }
    }

    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("My eSIMs")
                    .font(BankingTypo.heroAmount())
                    .foregroundColor(BankingColors.textOnDarkPrimary)

                if !coordinator.esimOrders.isEmpty {
                    Text("\(coordinator.esimOrders.count) plan\(coordinator.esimOrders.count > 1 ? "s" : "")")
                        .font(BankingTypo.caption())
                        .foregroundColor(BankingColors.textOnDarkMuted)
                }
            }

            Spacer()

            Button {
                coordinator.selectedTab = 1
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(BankingTypo.label())
                    Text("New")
                        .font(BankingTypo.button())
                }
                .foregroundColor(BankingColors.backgroundPrimary)
                .padding(.horizontal, BankingSpacing.lg)
                .padding(.vertical, BankingSpacing.md)
                .background(
                    Capsule()
                        .fill(BankingColors.accent)
                )
            }
            .scaleOnPress()
            .accessibilityLabel("Acheter un nouveau plan")
        }
        .padding(.horizontal, BankingSpacing.lg)
        .padding(.top, 56)
        .padding(.bottom, BankingSpacing.base)
    }

    // MARK: - Filter

    private var filterSection: some View {
        HStack(spacing: 6) {
            ForEach(filters, id: \.self) { filter in
                TechChip(
                    title: filter,
                    isSelected: selectedFilter == filter
                ) {
                    HapticFeedback.selection()
                    withAnimation(.spring(response: 0.3)) {
                        selectedFilter = filter
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        if coordinator.isLoadingESIMs {
            loadingView
        } else if coordinator.esimOrders.isEmpty {
            emptyView
        } else {
            esimsList
        }
    }

    private var esimsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                ForEach(Array(filteredOrders.enumerated()), id: \.element.id) { index, order in
                    NavigationLink(value: order) {
                        EsimCardTech(order: order)
                    }
                    .buttonStyle(.plain)
                    .slideIn(delay: 0.03 * Double(index))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }

    private var loadingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.md) {
                ForEach(0..<3, id: \.self) { index in
                    ShimmerPlaceholder(cornerRadius: 20)
                        .frame(height: 140)
                        .padding(.horizontal, 16)
                        .bounceIn(delay: Double(index) * 0.1)
                }
            }
            .padding(.top, AppTheme.Spacing.md)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: BankingSpacing.xxl) {
                ZStack {
                    Circle()
                        .fill(BankingColors.accent.opacity(0.08))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(BankingColors.accent.opacity(0.15))
                        .frame(width: 88, height: 88)

                    Image(systemName: "simcard")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(BankingColors.accent)
                }

                VStack(spacing: BankingSpacing.md) {
                    Text("No eSIMs yet")
                        .font(BankingTypo.detailAmount())
                        .foregroundColor(BankingColors.textOnDarkPrimary)

                    Text("Get your first eSIM and stay\nconnected in 190+ countries")
                        .font(BankingTypo.body())
                        .foregroundColor(BankingColors.textOnDarkMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }

                Button {
                    coordinator.selectedTab = 1
                } label: {
                    HStack(spacing: 8) {
                        Text("Browse plans")
                            .font(BankingTypo.button())
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(BankingColors.backgroundPrimary)
                    .padding(.horizontal, BankingSpacing.xxl)
                    .padding(.vertical, BankingSpacing.base)
                    .background(
                        Capsule()
                            .fill(BankingColors.accent)
                            .shadow(color: BankingColors.accentDark.opacity(0.4), radius: 12, x: 0, y: 4)
                    )
                }
                .accessibilityLabel("Voir les plans disponibles")
                .scaleOnPress()
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - eSIM Card (Banking Style)

struct EsimCardTech: View {
    let order: ESIMOrder
    @EnvironmentObject private var coordinator: AppCoordinator

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingRadius = AppTheme.Banking.Radius
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return BankingColors.accentDark
        case "EXPIRED": return BankingColors.textOnLightMuted
        case "PENDING", "PENDING_PAYMENT", "PROCESSING": return AppTheme.warning
        default: return BankingColors.textOnLightMuted
        }
    }

    private var statusText: String {
        switch order.status.uppercased() {
        case "RELEASED": return "ACTIVE"
        case "IN_USE": return "IN USE"
        case "EXPIRED": return "EXPIRED"
        case "PENDING", "PENDING_PAYMENT": return "PENDING"
        case "PROCESSING": return "PROCESSING"
        default: return order.status.uppercased()
        }
    }

    private var isActive: Bool {
        let s = order.status.uppercased()
        return s == "RELEASED" || s == "IN_USE"
    }

    private var daysRemaining: Int {
        guard !order.expiredTime.isEmpty else { return 0 }
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let expiryDate = dateFormatter.date(from: order.expiredTime) {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            return max(0, days)
        }

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd"
        if let expiryDate = fallbackFormatter.date(from: String(order.expiredTime.prefix(10))) {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            return max(0, days)
        }
        return 0
    }

    private var daysRemainingText: String {
        let days = daysRemaining
        if days == 0 { return "Expired" }
        if days == 1 { return "1 day left" }
        return "\(days) days left"
    }

    private var usagePercentage: Double {
        coordinator.usagePercentage(for: order)
    }

    var body: some View {
        HStack(spacing: BankingSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(BankingColors.surfaceMedium)
                    .frame(width: 44, height: 44)

                Image(systemName: "simcard.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isActive ? BankingColors.accentDark : BankingColors.textOnLightMuted)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(order.packageName)
                    .font(BankingTypo.body())
                    .foregroundColor(BankingColors.textOnLightPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(order.totalVolume)
                        .font(BankingTypo.caption())
                        .foregroundColor(BankingColors.textOnLightMuted)

                    Text("·")
                        .foregroundColor(BankingColors.textOnLightMuted)

                    Text(daysRemainingText)
                        .font(BankingTypo.caption())
                        .foregroundColor(BankingColors.textOnLightMuted)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(statusText)
                    .font(BankingTypo.label())
                    .foregroundColor(isActive ? BankingColors.backgroundPrimary : statusColor)
                    .padding(.horizontal, BankingSpacing.sm)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(isActive ? BankingColors.accent : statusColor.opacity(0.15))
                    )

                Text("\(Int(usagePercentage * 100))% used")
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnLightMuted)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(BankingColors.textOnLightMuted)
        }
        .padding(.horizontal, BankingSpacing.base)
        .padding(.vertical, BankingSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.surfaceLight)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(order.packageName), \(statusText), \(order.totalVolume)")
        .accessibilityHint("Double-tap pour voir les détails")
        .contentShape(Rectangle())
    }
}

// Compatibility
struct EsimCard: View {
    let order: ESIMOrder
    var body: some View { EsimCardTech(order: order) }
}
struct ESIMCard: View {
    let order: ESIMOrder
    var body: some View { EsimCardTech(order: order) }
}
struct UltraEsimCard: View {
    let order: ESIMOrder
    var body: some View { EsimCardTech(order: order) }
}
struct MiniStat: View {
    let icon: String
    let label: String
    var body: some View {
        Label(label, systemImage: icon)
            .font(AppTheme.Banking.Typography.caption())
            .foregroundColor(AppTheme.Banking.Colors.textOnLightMuted)
    }
}

// MARK: - ViewModel

@MainActor
final class MyESIMsViewModel: ObservableObject {
    @Published var orders: [ESIMOrder] = []
    @Published var isLoading = false
    @Published var error: String?

    func loadOrders(apiService: DXBAPIServiceProtocol) async {
        isLoading = true
        error = nil
        do {
            orders = try await apiService.fetchMyESIMs()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    MyESIMsView()
        .environmentObject(AppCoordinator())
}
