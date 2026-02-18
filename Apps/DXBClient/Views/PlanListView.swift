import SwiftUI
import DXBCore

struct PlanListView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var viewMode: ViewMode = .countries
    @State private var selectedPlan: Plan?

    enum ViewMode: String, CaseIterable {
        case countries = "Countries"
        case list = "All Plans"
    }

    let filters = ["All", "Europe", "Asia", "Americas"]

    /// Plans filtrés par recherche et région
    var filteredPlans: [Plan] {
        var plans = coordinator.plans.filter { plan in
            searchText.isEmpty || 
            plan.name.localizedCaseInsensitiveContains(searchText) ||
            plan.location.localizedCaseInsensitiveContains(searchText)
        }

        switch selectedFilter {
        case "Europe":
            plans = plans.filter { isEuropean($0.locationCode) }
        case "Asia":
            plans = plans.filter { isAsian($0.locationCode) }
        case "Americas":
            plans = plans.filter { isAmericas($0.locationCode) }
        default:
            break
        }

        return plans
    }

    /// Plans groupés par pays
    var plansByCountry: [(country: String, code: String, plans: [Plan])] {
        let grouped = Dictionary(grouping: coordinator.plans) { $0.location }
        return grouped.map { (country: $0.key, code: $0.value.first?.locationCode ?? "", plans: $0.value) }
            .sorted { $0.country < $1.country }
            .filter { searchText.isEmpty || $0.country.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func isEuropean(_ code: String) -> Bool {
        ["FR", "DE", "IT", "ES", "GB", "NL", "BE", "PT", "AT", "CH", "PL", "CZ", "GR", "SE", "NO", "DK", "FI", "IE", "HU", "RO", "BG", "HR", "SK", "SI", "LT", "LV", "EE", "LU", "MT", "CY", "EU"].contains(code.uppercased())
    }
    
    private func isAsian(_ code: String) -> Bool {
        ["JP", "KR", "CN", "HK", "TW", "SG", "TH", "VN", "MY", "ID", "PH", "IN", "AE", "SA", "QA", "KW", "BH", "OM", "IL", "TR"].contains(code.uppercased())
    }
    
    private func isAmericas(_ code: String) -> Bool {
        ["US", "CA", "MX", "BR", "AR", "CL", "CO", "PE", "VE", "EC", "UY", "PY", "BO", "CR", "PA", "DO", "PR", "JM", "TT", "BB"].contains(code.uppercased())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerSection
                    searchSection
                    contentSection
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                await coordinator.loadPlans()
            }
            .task {
                if coordinator.plans.isEmpty {
                    await coordinator.loadPlans()
                }
            }
            .sheet(item: $selectedPlan) { plan in
                PlanDetailView(plan: plan)
                    .environmentObject(coordinator)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("EXPLORE")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.8)
                    .foregroundColor(AppTheme.textTertiary)

                Text("Explore")
                    .font(.system(size: 36, weight: .bold))
                    .tracking(-0.5)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()

            // Refresh indicator
            if coordinator.isLoadingPlans {
                ProgressView()
                    .tint(AppTheme.textPrimary)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 64)
        .padding(.bottom, 20)
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack(spacing: 14) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textTertiary)

                TextField("Search eSIMs...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )
            )

            // Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
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
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        if coordinator.isLoadingPlans {
            loadingView
        } else if coordinator.plans.isEmpty {
            emptyView
        } else {
            plansList
        }
    }

    private var plansList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ForEach(Array(filteredPlans.prefix(100).enumerated()), id: \.element.id) { index, plan in
                    Button {
                        selectedPlan = plan
                    } label: {
                        PlanTechRow(plan: plan)
                    }
                    .buttonStyle(.plain)
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
            Text("Loading plans...")
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

                Image(systemName: "globe")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(spacing: 10) {
                Text("No Plans Available")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Pull to refresh")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - ESIMOrder Row

struct ESIMOrderRow: View {
    let order: ESIMOrder

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
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.textPrimary)
                    .frame(width: 56, height: 56)

                Image(systemName: "simcard.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(order.packageName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 12) {
                    HStack(spacing: 5) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 11, weight: .semibold))
                        Text(order.totalVolume)
                            .font(.system(size: 12, weight: .medium))
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "number")
                            .font(.system(size: 11, weight: .semibold))
                        Text(String(order.iccid.prefix(8)) + "...")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            // Status
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

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Country Card

struct CountryCard: View {
    let country: String
    let code: String
    let planCount: Int
    let minPrice: Double

    private var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in code.uppercased().unicodeScalars {
            if let s = UnicodeScalar(base + scalar.value) {
                emoji.append(String(s))
            }
        }
        return emoji.isEmpty ? "🌍" : emoji
    }

    var body: some View {
        VStack(spacing: 14) {
            // Flag
            ZStack {
                Circle()
                    .fill(AppTheme.gray100)
                    .frame(width: 56, height: 56)

                Text(flagEmoji)
                    .font(.system(size: 28))
            }

            // Country name
            Text(country)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Info
            HStack(spacing: 4) {
                Text("\(planCount) plans")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)

                Text("•")
                    .foregroundColor(AppTheme.textMuted)

                Text("from \(minPrice.formattedPrice)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Country Plans View

struct CountryPlansView: View {
    let country: String
    let plans: [Plan]
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedPlan: Plan?

    private var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        if let code = plans.first?.locationCode {
            for scalar in code.uppercased().unicodeScalars {
                if let s = UnicodeScalar(base + scalar.value) {
                    emoji.append(String(s))
                }
            }
        }
        return emoji.isEmpty ? "🌍" : emoji
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Text(flagEmoji)
                            .font(.system(size: 20))
                        Text(country)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 16)

                // Plans count
                HStack {
                    Text("\(plans.count) plans available")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Plans list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        ForEach(plans) { plan in
                            Button {
                                selectedPlan = plan
                            } label: {
                                PlanTechRow(plan: plan)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedPlan) { plan in
            PlanDetailView(plan: plan)
                .environmentObject(coordinator)
        }
    }
}

// MARK: - Tech Chip

struct TechChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(0.5)
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? AppTheme.textPrimary : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.clear : AppTheme.border, lineWidth: 1.5)
                        )
                )
        }
    }
}

// Compatibility
struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View { TechChip(title: title, isSelected: isSelected, action: action) }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View { TechChip(title: title, isSelected: isSelected, action: action) }
}

struct PremiumFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View { TechChip(title: title, isSelected: isSelected, action: action) }
}

// MARK: - Plan Tech Row

struct PlanTechRow: View {
    let plan: Plan

    var body: some View {
        HStack(spacing: 16) {
            // Flag
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.gray100)
                    .frame(width: 56, height: 56)

                Text(flagEmoji)
                    .font(.system(size: 28))
            }

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(plan.location)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 12) {
                    HStack(spacing: 5) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(plan.dataGB)GB")
                            .font(.system(size: 12, weight: .medium))
                    }

                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(plan.durationDays)d")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 3) {
                Text(plan.priceUSD.formattedPrice)
                    .font(.system(size: 20, weight: .bold))
                    .tracking(-0.5)
                    .foregroundColor(AppTheme.textPrimary)

                Text(plan.speed)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plan.location), \(plan.dataGB) gigabytes, \(plan.durationDays) jours, \(plan.priceUSD.formattedPrice)")
        .accessibilityHint("Double-tap pour voir les détails")
        .contentShape(Rectangle())
    }

    private var flagEmoji: String {
        let base: UInt32 = 127397
        var emoji = ""
        for scalar in plan.locationCode.uppercased().unicodeScalars {
            if let s = UnicodeScalar(base + scalar.value) {
                emoji.append(String(s))
            }
        }
        return emoji.isEmpty ? "🌍" : emoji
    }
}

// Compatibility
struct PlanRow: View {
    let plan: Plan
    var body: some View { PlanTechRow(plan: plan) }
}

struct PlanCard: View {
    let plan: Plan
    var body: some View { PlanTechRow(plan: plan) }
}

struct UltraPlanCard: View {
    let plan: Plan
    var body: some View { PlanTechRow(plan: plan) }
}

// MARK: - Error State Tech

struct ErrorStateTech: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.gray100)
                    .frame(width: 80, height: 80)

                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(spacing: 8) {
                Text("Connection Error")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: retry) {
                Text("TRY AGAIN")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.textPrimary)
                    )
            }
            .scaleOnPress()

            Spacer()
        }
        .padding()
    }
}

// Compatibility
struct ErrorStateView: View {
    let message: String
    let retry: () -> Void
    var body: some View { ErrorStateTech(message: message, retry: retry) }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    var body: some View { ErrorStateTech(message: message, retry: retry) }
}

// MARK: - ViewModel

@MainActor
final class PlanListViewModel: ObservableObject {
    @Published var plans: [Plan] = []
    @Published var isLoading = false
    @Published var error: String?

    func loadPlans(apiService: DXBAPIServiceProtocol) async {
        isLoading = true
        error = nil

        do {
            plans = try await apiService.fetchPlans(locale: "en")
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}


#Preview {
    PlanListView()
        .environmentObject(AppCoordinator())
}
