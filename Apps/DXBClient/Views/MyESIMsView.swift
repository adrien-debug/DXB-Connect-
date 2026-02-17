import SwiftUI
import DXBCore

struct MyESIMsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedFilter = "All"

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

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
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
                if coordinator.esimOrders.isEmpty {
                    await coordinator.loadESIMs()
                }
            }
        }
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
                    .font(.system(size: 32, weight: .bold))
                    .tracking(-0.5)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()

            // Add button
            Button {
                coordinator.selectedTab = 1 // Navigate to Plans
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.textPrimary)
                        .frame(width: 44, height: 44)

                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .accessibilityLabel("Acheter un nouveau plan")
            .scaleOnPress()
        }
        .padding(.horizontal, 24)
        .padding(.top, 64)
        .padding(.bottom, 20)
    }

    // MARK: - Filter

    private var filterSection: some View {
        HStack(spacing: 10) {
            ForEach(filters, id: \.self) { filter in
                TechChip(
                    title: filter,
                    isSelected: selectedFilter == filter
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedFilter = filter
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
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
            LazyVStack(spacing: 14) {
                ForEach(Array(filteredOrders.enumerated()), id: \.element.id) { index, order in
                    NavigationLink(value: order) {
                        EsimCardTech(order: order)
                    }
                    .buttonStyle(.plain)
                    .slideIn(delay: 0.03 * Double(index))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 140)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .tint(AppTheme.textPrimary)
                .scaleEffect(1.3)
            Text("Loading eSIMs...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.gray100)
                    .frame(width: 88, height: 88)

                Image(systemName: "simcard")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(spacing: 10) {
                Text("No eSIMs Yet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Purchase your first eSIM and\nstay connected worldwide")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
            }

            Button {
                coordinator.selectedTab = 1 // Navigate to Plans
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
                        .fill(AppTheme.textPrimary)
                )
            }
            .accessibilityLabel("Voir les plans disponibles")
            .scaleOnPress()

            Spacer()
        }
        .padding()
    }
}

// MARK: - eSIM Card Tech

struct EsimCardTech: View {
    let order: ESIMOrder
    @State private var isPressed = false

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.textPrimary
        case "EXPIRED": return AppTheme.gray400
        default: return AppTheme.gray500
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
        VStack(spacing: 18) {
            // Header
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.textPrimary)
                        .frame(width: 52, height: 52)

                    Image(systemName: "simcard.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.packageName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("ICCID: \(String(order.iccid.prefix(8)))...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                }

                Spacer()

                // Status Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)

                    Text(statusText)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(statusColor.opacity(0.1))
                )
            }

            // Progress
            VStack(spacing: 10) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppTheme.gray100)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(AppTheme.textPrimary)
                            .frame(width: geo.size.width * 0.65)
                    }
                }
                .frame(height: 5)

                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 10, weight: .semibold))
                        Text("65% used")
                            .font(.system(size: 11, weight: .medium))
                    }

                    Spacer()

                    Text(order.totalVolume)
                        .font(.system(size: 12, weight: .semibold))

                    Spacer()

                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .semibold))
                        Text("12 days left")
                            .font(.system(size: 11, weight: .medium))
                    }
                }
                .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(isPressed ? 0.01 : 0.03), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 1 : 3)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(order.packageName), \(statusText), \(order.totalVolume)")
        .accessibilityHint("Double-tap pour voir les détails")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
    }
}

// Legacy compatibility
struct EsimCard: View {
    let order: ESIMOrder
    var body: some View { EsimCardTech(order: order) }
}

// Compatibility
struct ESIMCard: View {
    let order: ESIMOrder
    var body: some View { EsimCard(order: order) }
}
struct UltraEsimCard: View {
    let order: ESIMOrder
    var body: some View { EsimCard(order: order) }
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
