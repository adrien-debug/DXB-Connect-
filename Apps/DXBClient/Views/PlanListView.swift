import SwiftUI
import DXBCore

struct PlanListView: View {
    @Environment(AppState.self) private var appState

    @State private var plans: [Plan] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedCountry: CountryEntry?
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

    struct CountryEntry: Identifiable, Equatable {
        var id: String { name }
        let name: String
        let code: String
        let planCount: Int
        let startingPrice: Double
    }

    private var countries: [CountryEntry] {
        let grouped = Dictionary(grouping: plans) { $0.location }
        var result = grouped.map { key, value in
            CountryEntry(
                name: key,
                code: value.first?.locationCode ?? "",
                planCount: value.count,
                startingPrice: value.map(\.priceUSD).min() ?? 0
            )
        }
        .sorted { $0.name < $1.name }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return result
    }

    private var plansForSelectedCountry: [Plan] {
        guard let country = selectedCountry else { return [] }
        var result = plans.filter { $0.location == country.name }
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

                if appState.subscription == nil && selectedCountry == nil {
                    subscriptionBanner
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, 8)
                }

                if selectedCountry == nil {
                    promoCodeField
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, 8)
                }

                if selectedCountry != nil {
                    countryOffersHeader
                } else {
                    countriesGrid
                }
            }
        }
        .navigationTitle(selectedCountry == nil ? "Browse Plans" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await loadPlans() }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textTertiary)

            TextField(
                selectedCountry == nil ? "Search country..." : "Search plans...",
                text: $searchText
            )
            .font(.system(size: 15))
            .foregroundStyle(AppColors.textPrimary)

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + 3)
        .background(
            Capsule()
                .fill(AppColors.surface)
                .overlay(
                    Capsule()
                        .stroke(AppColors.border, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
        .padding(.bottom, AppSpacing.sm)
    }

    // MARK: - Countries Grid

    private var countriesGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.base) {
                if isLoading {
                    countriesLoadingGrid
                } else if let error = errorMessage {
                    errorView(error)
                        .padding(.horizontal, AppSpacing.lg)
                } else if countries.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No countries found",
                        subtitle: "Try a different search"
                    )
                    .padding(.horizontal, AppSpacing.lg)
                } else {
                    HStack {
                        Text("\(countries.count) destinations")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: AppSpacing.md),
                            GridItem(.flexible(), spacing: AppSpacing.md)
                        ],
                        spacing: AppSpacing.md
                    ) {
                        ForEach(countries) { country in
                            countryCard(country)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            }
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, 120)
        }
        .refreshable { await loadPlans() }
    }

    private func countryCard(_ country: CountryEntry) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                searchText = ""
                selectedCountry = country
            }
            HapticFeedback.light()
        } label: {
            VStack(spacing: AppSpacing.md) {
                Text(flagEmoji(for: country.name))
                    .font(.system(size: 40))

                VStack(spacing: 3) {
                    Text(country.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("\(country.planCount) plan\(country.planCount > 1 ? "s" : "")")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Text("From $\(String(format: "%.2f", country.startingPrice))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AppColors.accent.opacity(0.1)))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(ScaleOnPressStyle())
    }

    private var countriesLoadingGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: AppSpacing.md),
                GridItem(.flexible(), spacing: AppSpacing.md)
            ],
            spacing: AppSpacing.md
        ) {
            ForEach(0..<8, id: \.self) { _ in
                VStack(spacing: AppSpacing.md) {
                    Circle()
                        .fill(AppColors.surfaceSecondary)
                        .frame(width: 44, height: 44)
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: AppRadius.xs)
                            .fill(AppColors.surfaceSecondary)
                            .frame(width: 80, height: 14)
                        RoundedRectangle(cornerRadius: AppRadius.xs)
                            .fill(AppColors.surfaceSecondary)
                            .frame(width: 50, height: 10)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                        .fill(AppColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                                .stroke(AppColors.border, lineWidth: 0.5)
                        )
                )
                .shimmer()
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }

    // MARK: - Country Offers (Detail)

    private var countryOffersHeader: some View {
        VStack(spacing: 0) {
            if let country = selectedCountry {
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            selectedCountry = nil
                            searchText = ""
                        }
                        HapticFeedback.light()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                            Text("Back")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(AppColors.accent)
                    }

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
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 11, weight: .semibold))
                            Text(sortOption.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(AppColors.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(AppColors.accent.opacity(0.08))
                        )
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)

                countryHeroBanner(country)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.sm)
            }

            countryPlansList
        }
    }

    private func countryHeroBanner(_ country: CountryEntry) -> some View {
        HStack(spacing: 14) {
            Text(flagEmoji(for: country.name))
                .font(.system(size: 36))

            VStack(alignment: .leading, spacing: 2) {
                Text(country.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(country.planCount) plan\(country.planCount > 1 ? "s" : "") available")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("From")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
                Text("$\(String(format: "%.2f", country.startingPrice))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                        .stroke(AppColors.accent.opacity(0.15), lineWidth: 0.5)
                )
        )
    }

    private var countryPlansList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppSpacing.sm) {
                if plansForSelectedCountry.isEmpty {
                    EmptyStateView(
                        icon: "simcard",
                        title: "No plans available",
                        subtitle: "Check back later for plans in this region"
                    )
                } else {
                    ForEach(plansForSelectedCountry) { plan in
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

    // MARK: - Plan Card

    private func planCard(_ plan: Plan) -> some View {
        let isBestValue = isBestValuePlan(plan)

        return HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(plan.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    if isBestValue {
                        Text("BEST")
                            .font(.system(size: 7, weight: .black))
                            .tracking(0.5)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AppColors.accent))
                    }

                    if plan.speed.lowercased().contains("5g") {
                        Text("5G")
                            .font(.system(size: 7, weight: .black))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AppColors.accent))
                    }
                }

                HStack(spacing: 12) {
                    Label("\(plan.dataGB) GB", systemImage: "arrow.down.circle.fill")
                    Label("\(plan.durationDays) days", systemImage: "clock.fill")
                    if !plan.speed.lowercased().contains("5g") {
                        Label(plan.speed, systemImage: "antenna.radiowaves.left.and.right")
                    }
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let discount = appState.subscription?.discount_percent, discount > 0 {
                    Text("$\(String(format: "%.2f", plan.priceUSD))")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .strikethrough()
                    Text("$\(String(format: "%.2f", plan.priceUSD * (1 - Double(discount) / 100)))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.accent)
                } else {
                    Text("$\(String(format: "%.2f", plan.priceUSD))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.accent)
                }

                Text("$\(String(format: "%.2f", plan.priceUSD / max(Double(plan.dataGB), 1)))/GB")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(isBestValue ? AppColors.accent.opacity(0.2) : AppColors.border, lineWidth: isBestValue ? 1 : 0.5)
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

    private func errorView(_ message: String) -> some View {
        EmptyStateView(icon: "wifi.exclamationmark", title: "Connection Error", subtitle: message, actionTitle: "Try Again") {
            Task { await loadPlans() }
        }
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
                            .stroke(AppColors.accent.opacity(0.15), lineWidth: 0.5)
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
                            .stroke(promoApplied ? AppColors.success.opacity(0.3) : AppColors.border, lineWidth: 0.5)
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
        Task {
            do {
                let isValid = try await appState.apiService.validatePromoCode(code)
                if isValid {
                    promoApplied = true
                    HapticFeedback.success()
                } else {
                    promoError = "Invalid promo code"
                    HapticFeedback.error()
                }
            } catch {
                promoError = "Unable to validate code"
                HapticFeedback.error()
            }
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
