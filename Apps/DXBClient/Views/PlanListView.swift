import SwiftUI
import DXBCore

struct PlanListView: View {
    @Environment(AppState.self) private var appState

    @State private var plans: [Plan] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedRegion: String?
    @State private var sortOption: SortOption = .priceAsc
    @State private var promoCode = ""
    @State private var promoApplied = false
    @State private var promoError: String?

    enum SortOption: String, CaseIterable {
        case priceAsc = "Price ↑"
        case priceDesc = "Price ↓"
        case dataDesc = "Data ↓"
        case duration = "Duration"
    }

    private var regions: [String] {
        Array(Set(plans.map { $0.location })).sorted()
    }

    private var filteredPlans: [Plan] {
        var result = plans
        if !searchText.isEmpty {
            result = result.filter {
                $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let region = selectedRegion {
            result = result.filter { $0.location == region }
        }
        switch sortOption {
        case .priceAsc:  result.sort { $0.priceUSD < $1.priceUSD }
        case .priceDesc: result.sort { $0.priceUSD > $1.priceUSD }
        case .dataDesc:  result.sort { $0.dataGB > $1.dataGB }
        case .duration:  result.sort { $0.durationDays > $1.durationDays }
        }
        return result
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                searchBar

                if appState.subscription == nil {
                    subscriptionBanner
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, 8)
                }

                promoCodeField
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, 8)

                filtersSection
                plansList
            }
        }
        .navigationTitle("Browse Plans")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await loadPlans() }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textTertiary)

            TextField("Search country or plan...", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textPrimary)

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Filters

    private var filtersSection: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    regionPill(nil, label: "All")
                    ForEach(regions.prefix(10), id: \.self) { region in
                        regionPill(region, label: region)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }

            HStack {
                Text("\(filteredPlans.count) plans")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)

                Spacer()

                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(sortOption.rawValue)
                            .font(.system(size: 13, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppColors.accent)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.bottom, 8)
    }

    private func regionPill(_ region: String?, label: String) -> some View {
        let isSelected = selectedRegion == region

        return Button {
            withAnimation(.spring(response: 0.3)) { selectedRegion = region }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .black : AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.base)
                    .padding(.vertical, AppSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accent : AppColors.surface)
                        .overlay(
                            Capsule().stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 1)
                        )
                )
        }
    }

    // MARK: - Plans List

    private var plansList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ForEach(0..<6, id: \.self) { _ in planLoadingCard }
                } else if let error = errorMessage {
                    errorView(error)
                } else if filteredPlans.isEmpty {
                    emptyView
                } else {
                    ForEach(filteredPlans) { plan in
                        NavigationLink { PlanDetailView(plan: plan) } label: {
                            planCard(plan)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, 120)
        }
        .refreshable { await loadPlans() }
    }

    private func planCard(_ plan: Plan) -> some View {
        let isBestValue = isBestValuePlan(plan)

        return HStack(spacing: AppSpacing.md) {
            ZStack(alignment: .bottomTrailing) {
                Text(flagEmoji(for: plan.location))
                    .font(.system(size: 32))
                    .frame(width: 52, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .fill(AppColors.surfaceSecondary)
                    )

                if plan.speed.lowercased().contains("5g") {
                    Text("5G")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(AppColors.accent))
                        .offset(x: 4, y: 4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(plan.location)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    if isBestValue {
                        Text("BEST VALUE")
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.5)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AppColors.accent))
                    }
                }

                HStack(spacing: 10) {
                    Label("\(plan.dataGB) GB", systemImage: "arrow.down.circle.fill")
                    Label("\(plan.durationDays)d", systemImage: "clock.fill")
                    if !plan.speed.lowercased().contains("5g") {
                        Label(plan.speed, systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let discount = appState.subscription?.discount_percent, discount > 0 {
                    Text("$\(String(format: "%.2f", plan.priceUSD))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .strikethrough()
                    Text("$\(String(format: "%.2f", plan.priceUSD * (1 - Double(discount) / 100)))")
                        .font(AppFonts.cardAmount())
                        .foregroundStyle(AppColors.accent)
                } else {
                    Text("$\(String(format: "%.2f", plan.priceUSD))")
                        .font(AppFonts.cardAmount())
                        .foregroundStyle(AppColors.accent)
                }

                Text("$\(String(format: "%.2f", plan.priceUSD / max(Double(plan.dataGB), 1)))/GB")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(isBestValue ? AppColors.accent.opacity(0.3) : AppColors.border, lineWidth: isBestValue ? 1.5 : 1)
                )
        )
    }

    private func isBestValuePlan(_ plan: Plan) -> Bool {
        guard plan.dataGB > 0 else { return false }
        let pricePerGB = plan.priceUSD / Double(plan.dataGB)
        let sameDest = plans.filter { $0.location == plan.location && $0.dataGB > 0 }
        guard sameDest.count > 2 else { return false }
        let cheapest = sameDest.min { ($0.priceUSD / Double($0.dataGB)) < ($1.priceUSD / Double($1.dataGB)) }
        return cheapest?.id == plan.id && pricePerGB < 5
    }

    private var planLoadingCard: some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.md).fill(AppColors.surfaceSecondary).frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary).frame(width: 100, height: 14)
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary).frame(width: 140, height: 10)
            }
            Spacer()
            RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary).frame(width: 50, height: 18)
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous).stroke(AppColors.border, lineWidth: 1))
        )
        .shimmer()
    }

    private func errorView(_ message: String) -> some View {
        EmptyStateView(icon: "wifi.exclamationmark", title: "Connection Error", subtitle: message, actionTitle: "Try Again") {
            Task { await loadPlans() }
        }
    }

    private var emptyView: some View {
        EmptyStateView(icon: "magnifyingglass", title: "No plans found", subtitle: "Try adjusting your search or filters")
    }

    // MARK: - Subscription Banner

    private var subscriptionBanner: some View {
        NavigationLink {
            SubscriptionView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Save up to 30%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Subscribe to SimPass Premium")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text("VIEW")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(AppColors.accent))
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.accent.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .stroke(AppColors.accent.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Promo Code

    private var promoCodeField: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(promoApplied ? AppColors.success : AppColors.textTertiary)

                TextField("Promo code", text: $promoCode)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textPrimary)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .disabled(promoApplied)

                if promoApplied {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("Applied")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(AppColors.success)
                } else if !promoCode.isEmpty {
                    Button {
                        applyPromoCode()
                    } label: {
                        Text("Apply")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(AppColors.accent))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .stroke(promoApplied ? AppColors.success.opacity(0.3) : AppColors.border, lineWidth: 1)
                    )
            )

            if let error = promoError {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
            }
        }
    }

    private func applyPromoCode() {
        let code = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !code.isEmpty else { return }

        promoError = nil
        if ["WELCOME10", "SIMPASS20", "DXB2025"].contains(code) {
            promoApplied = true
            HapticFeedback.success()
        } else {
            promoError = "Invalid promo code"
            HapticFeedback.error()
        }
    }

    private func loadPlans() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await appState.apiService.fetchPlans(locale: "en")
            plans = fetched; isLoading = false
        } catch {
            errorMessage = error.localizedDescription; isLoading = false
        }
    }

    private func flagEmoji(for country: String) -> String {
        CountryHelper.flagFromName(country)
    }
}

#Preview {
    NavigationStack { PlanListView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
