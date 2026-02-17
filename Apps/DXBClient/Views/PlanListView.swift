import SwiftUI
import DXBCore

struct PlanListView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var searchText = ""
    @State private var selectedRegion = "All"
    @State private var showFilterSheet = false
    @State private var sortOption: SortOption = .popular
    @State private var minData: Int = 0
    @State private var maxPrice: Double = 100

    enum SortOption: String, CaseIterable {
        case popular = "Popular"
        case priceLow = "Price: Low to High"
        case priceHigh = "Price: High to Low"
        case dataHigh = "Data: High to Low"
    }

    let regions = ["All", "Europe", "Asia", "Americas", "Middle East", "Africa"]

    var filteredPlans: [Plan] {
        var plans = coordinator.plans.filter { plan in
            (searchText.isEmpty || plan.name.localizedCaseInsensitiveContains(searchText) || plan.location.localizedCaseInsensitiveContains(searchText)) &&
            (selectedRegion == "All" || plan.location.localizedCaseInsensitiveContains(selectedRegion)) &&
            plan.dataGB >= minData &&
            plan.priceUSD <= maxPrice
        }

        switch sortOption {
        case .popular:
            break // Keep original order
        case .priceLow:
            plans.sort { $0.priceUSD < $1.priceUSD }
        case .priceHigh:
            plans.sort { $0.priceUSD > $1.priceUSD }
        case .dataHigh:
            plans.sort { $0.dataGB > $1.dataGB }
        }

        return plans
    }

    var hasActiveFilters: Bool {
        sortOption != .popular || minData > 0 || maxPrice < 100
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    headerSection
                    searchSection
                    contentSection
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Plan.self) { plan in
                PlanDetailView(plan: plan)
            }
            .refreshable {
                await coordinator.loadPlans()
            }
            .task {
                if coordinator.plans.isEmpty {
                    await coordinator.loadPlans()
                }
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

                Text("eSIM Plans")
                    .font(.system(size: 36, weight: .bold))
                    .tracking(-0.5)
                    .foregroundColor(AppTheme.textPrimary)
            }

            Spacer()

            // Filter button
            Button {
                showFilterSheet = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(hasActiveFilters ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(hasActiveFilters ? AppTheme.textPrimary.opacity(0.1) : Color.white)
                        )

                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .accessibilityLabel("Filtres et tri")
            .scaleOnPress()
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(
                    sortOption: $sortOption,
                    minData: $minData,
                    maxPrice: $maxPrice,
                    onReset: {
                        sortOption = .popular
                        minData = 0
                        maxPrice = 100
                    }
                )
                .presentationDetents([.medium])
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

                TextField("Search countries...", text: $searchText)
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
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )
            )

            // Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(regions, id: \.self) { region in
                        TechChip(
                            title: region,
                            isSelected: selectedRegion == region
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedRegion = region
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
            ErrorStateTech(message: "Unable to load plans") {
                Task { await coordinator.loadPlans() }
            }
        } else {
            plansList
        }
    }

    private var plansList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ForEach(Array(filteredPlans.enumerated()), id: \.element.id) { index, plan in
                    NavigationLink(value: plan) {
                        PlanTechRow(plan: plan)
                    }
                    .buttonStyle(.plain)
                    .slideIn(delay: 0.02 * Double(index))
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
    @State private var isPressed = false

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
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
                .shadow(color: Color.black.opacity(isPressed ? 0.01 : 0.03), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 1 : 3)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plan.location), \(plan.dataGB) gigabytes, \(plan.durationDays) jours, \(plan.priceUSD.formattedPrice)")
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

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sortOption: PlanListView.SortOption
    @Binding var minData: Int
    @Binding var maxPrice: Double
    var onReset: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }
                    .accessibilityLabel("Fermer")

                    Spacer()

                    Text("FILTERS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    Button {
                        onReset()
                    } label: {
                        Text("Reset")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        // Sort Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("SORT BY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(AppTheme.textTertiary)

                            VStack(spacing: 10) {
                                ForEach(PlanListView.SortOption.allCases, id: \.self) { option in
                                    Button {
                                        sortOption = option
                                    } label: {
                                        HStack {
                                            Text(option.rawValue)
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(AppTheme.textPrimary)

                                            Spacer()

                                            if sortOption == option {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 20, weight: .semibold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                            } else {
                                                Circle()
                                                    .stroke(AppTheme.border, lineWidth: 1.5)
                                                    .frame(width: 20, height: 20)
                                            }
                                        }
                                        .padding(16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(sortOption == option ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                        )
                                    }
                                }
                            }
                        }

                        // Min Data Section
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("MINIMUM DATA")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)

                                Spacer()

                                Text("\(minData)GB+")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            HStack(spacing: 10) {
                                ForEach([0, 1, 3, 5, 10], id: \.self) { value in
                                    Button {
                                        minData = value
                                    } label: {
                                        Text(value == 0 ? "Any" : "\(value)GB")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(minData == value ? .white : AppTheme.textSecondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(minData == value ? AppTheme.textPrimary : Color.white)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(minData == value ? Color.clear : AppTheme.border, lineWidth: 1.5)
                                                    )
                                            )
                                    }
                                }
                            }
                        }

                        // Max Price Section
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("MAX PRICE")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)

                                Spacer()

                                Text(maxPrice >= 100 ? "Any" : "$\(Int(maxPrice))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Slider(value: $maxPrice, in: 5...100, step: 5)
                                .tint(AppTheme.textPrimary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 100)
                }

                // Apply Button
                VStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("APPLY FILTERS")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.textPrimary)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(
                    Color.white
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                )
            }
        }
    }
}

#Preview {
    PlanListView()
        .environmentObject(AppCoordinator())
}
