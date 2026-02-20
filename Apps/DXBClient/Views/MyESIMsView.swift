import SwiftUI
import DXBCore

struct MyESIMsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedFilter = "All"
    @State private var pollingTask: Task<Void, Never>?

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
                AppTheme.backgroundSecondary
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
                    .font(.system(size: 30, weight: .bold))
                    .tracking(-0.5)
                    .foregroundColor(AppTheme.textPrimary)

                if !coordinator.esimOrders.isEmpty {
                    Text("\(coordinator.esimOrders.count) plan\(coordinator.esimOrders.count > 1 ? "s" : "")")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }

            Spacer()

            Button {
                coordinator.selectedTab = 1
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("New")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Color(hex: "0F172A"))
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(
                    Capsule()
                        .fill(AppTheme.accent)
                )
            }
            .scaleOnPress()
            .accessibilityLabel("Acheter un nouveau plan")
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, AppTheme.Spacing.base)
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

            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent.opacity(0.06))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 88, height: 88)

                    Image(systemName: "simcard")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(AppTheme.accent)
                }

                VStack(spacing: 12) {
                    Text("No eSIMs yet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Get your first eSIM and stay\nconnected in 190+ countries")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }

                Button {
                    coordinator.selectedTab = 1
                } label: {
                    HStack(spacing: 8) {
                        Text("Browse plans")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "0F172A"))
                    .padding(.horizontal, 36)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(AppTheme.accent)
                            .shadow(color: AppTheme.accent.opacity(0.3), radius: 12, x: 0, y: 4)
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

// MARK: - eSIM Card

struct EsimCardTech: View {
    let order: ESIMOrder
    @EnvironmentObject private var coordinator: AppCoordinator

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.success
        case "EXPIRED": return AppTheme.textSecondary
        case "PENDING", "PENDING_PAYMENT", "PROCESSING": return AppTheme.warning
        default: return AppTheme.textSecondary
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
        HStack(spacing: 0) {
            // Left status bar
            RoundedRectangle(cornerRadius: 3)
                .fill(statusColor)
                .frame(width: 4)
                .padding(.vertical, 12)

            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isActive ? AppTheme.accent.opacity(0.1) : AppTheme.backgroundTertiary)
                            .frame(width: 50, height: 50)

                        Image(systemName: "simcard.fill")
                            .font(.system(size: 19, weight: .semibold))
                            .foregroundColor(isActive ? AppTheme.accent : AppTheme.textTertiary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.packageName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text(order.totalVolume)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)

                            Text("·")
                                .foregroundColor(AppTheme.textMuted)

                            Text(daysRemainingText)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(isActive ? AppTheme.textSecondary : AppTheme.textTertiary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text(statusText)
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(statusColor.opacity(0.1))
                            )

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.backgroundTertiary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.accent, AppTheme.accent.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * usagePercentage)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("\(Int(usagePercentage * 100))% used")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()
                }
            }
            .padding(.leading, 14)
            .padding(.trailing, 18)
            .padding(.vertical, 18)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
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
            .font(.caption)
            .foregroundColor(AppTheme.textSecondary)
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
