import SwiftUI
import DXBCore

struct MyESIMsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedFilter = "All"
    @State private var pollingTask: Task<Void, Never>?

    let filters = ["All", "Active", "Expired"]

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
                AppTheme.backgroundPrimary
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
            let maxAttempts = 20

            while !Task.isCancelled && attempts < maxAttempts {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
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
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("MY ESIMS")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.8)
                    .foregroundColor(AppTheme.textTertiary)

                Text("Your Plans")
                    .font(.system(size: 34, weight: .bold))
                    .tracking(-0.5)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()

            Button {
                coordinator.selectedTab = 1
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.accent)
                        .frame(width: 44, height: 44)

                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .accessibilityLabel("Acheter un nouveau plan")
            .scaleOnPress()
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }

    // MARK: - Filter

    private var filterSection: some View {
        HStack(spacing: 8) {
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
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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
            LazyVStack(spacing: 12) {
                ForEach(Array(filteredOrders.enumerated()), id: \.element.id) { index, order in
                    NavigationLink(value: order) {
                        EsimCardTech(order: order)
                    }
                    .buttonStyle(.plain)
                    .slideIn(delay: 0.03 * Double(index))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .tint(AppTheme.accent)
                .scaleEffect(1.2)
            Text("Loading eSIMs...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.accentSoft)
                    .frame(width: 80, height: 80)

                Image(systemName: "simcard")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
            }

            VStack(spacing: 8) {
                Text("No eSIMs Yet")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Purchase your first eSIM and\nstay connected worldwide")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
            }

            Button {
                coordinator.selectedTab = 1
            } label: {
                HStack(spacing: 10) {
                    Text("BROWSE PLANS")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.accent)
                )
            }
            .accessibilityLabel("Voir les plans disponibles")
            .scaleOnPress()

            Spacer()
        }
        .padding()
    }
}

// MARK: - eSIM Card

struct EsimCardTech: View {
    let order: ESIMOrder

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.success
        case "EXPIRED": return AppTheme.gray400
        case "PENDING", "PENDING_PAYMENT", "PROCESSING": return AppTheme.warning
        default: return AppTheme.gray500
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
        return 0.65
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.accent.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: "simcard.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.packageName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("ICCID: \(String(order.iccid.prefix(8)))...")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                }

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)

                    Text(statusText)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.1))
                )
            }

            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppTheme.gray100)

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
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text("\(Int(usagePercentage * 100))% used")
                            .font(.system(size: 11, weight: .medium))
                    }

                    Spacer()

                    Text(order.totalVolume)
                        .font(.system(size: 12, weight: .bold))

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .semibold))
                        Text(daysRemainingText)
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
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
            .foregroundColor(AppTheme.textTertiary)
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
