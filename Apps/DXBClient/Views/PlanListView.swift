import SwiftUI
import DXBCore

// MARK: - Flag Image (CDN)

struct FlagImage: View {
    let code: String
    var size: CGFloat = 32

    private var flagURL: URL? {
        let lowered = code.lowercased()
        let width = Int(size * 3)
        return URL(string: "https://flagcdn.com/w\(width)/\(lowered).png")
    }

    var body: some View {
        AsyncImage(url: flagURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size * 0.7)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.12))
            case .failure:
                fallbackFlag
            case .empty:
                RoundedRectangle(cornerRadius: size * 0.12)
                    .fill(AppTheme.gray100)
                    .frame(width: size, height: size * 0.7)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.5)
                            .tint(AppTheme.textTertiary)
                    )
            @unknown default:
                fallbackFlag
            }
        }
    }

    private var fallbackFlag: some View {
        RoundedRectangle(cornerRadius: size * 0.12)
            .fill(AppTheme.gray100)
            .frame(width: size, height: size * 0.7)
            .overlay(
                Image(systemName: "globe")
                    .font(.system(size: size * 0.35, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            )
    }
}

struct PlanListView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedPlan: Plan?

    let filters = ["All", "1GB", "2GB", "5GB", "10GB"]

    var filteredPlans: [Plan] {
        var result = coordinator.plans

        if !searchText.isEmpty {
            result = result.filter {
                $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch selectedFilter {
        case "1GB": result = result.filter { $0.dataGB == 1 }
        case "2GB": result = result.filter { $0.dataGB == 2 }
        case "5GB": result = result.filter { $0.dataGB >= 3 && $0.dataGB <= 5 }
        case "10GB": result = result.filter { $0.dataGB >= 10 }
        default: break
        }

        return result.sorted { $0.priceUSD < $1.priceUSD }
    }

    private var popularDestinations: [DestinationInfo] {
        let grouped = Dictionary(grouping: coordinator.plans) { $0.locationCode }
        return grouped.compactMap { (code, plans) -> DestinationInfo? in
            guard let first = plans.first else { return nil }
            return DestinationInfo(location: first.location, code: code, count: plans.count, minPrice: plans.map(\.priceUSD).min() ?? 0)
        }
        .sorted { $0.count > $1.count }
        .prefix(8)
        .map { $0 }
    }

    private var bestValuePlanId: String? {
        guard !filteredPlans.isEmpty else { return nil }
        return filteredPlans.min(by: {
            ($0.priceUSD / max(Double($0.dataGB), 1)) < ($1.priceUSD / max(Double($1.dataGB), 1))
        })?.id
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundSecondary
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

    private var popularDestinationCodes: [String] {
        Array(Set(coordinator.plans.prefix(10).map { $0.locationCode }))
    }

    private var uniqueCountriesCount: Int {
        Set(coordinator.plans.map { $0.locationCode }).count
    }

    private var cheapestPrice: Double {
        coordinator.plans.map(\.priceUSD).min() ?? 0
    }

    private var headerSection: some View {
        ZStack {
            // Background anthracite
            AppTheme.anthracite

            // World map overlay
            WorldMapDarkView(
                highlightedCodes: popularDestinationCodes,
                showConnections: false,
                showDubaiPulse: true
            )
            .opacity(0.5)

            // Signal rings centered on Dubai
            GeometryReader { geo in
                SignalRings(color: AppTheme.accent.opacity(0.35), size: 90)
                    .position(
                        x: 0.654 * geo.size.width,
                        y: 0.42 * geo.size.height
                    )
            }

            // Gradient overlay for better text readability
            LinearGradient(
                colors: [
                    AppTheme.anthracite.opacity(0.8),
                    AppTheme.anthracite.opacity(0.3),
                    AppTheme.anthracite.opacity(0.6)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Explore")
                            .font(.system(size: 28, weight: .bold))
                            .tracking(-0.5)
                            .foregroundColor(.white)

                        Text("Find your perfect plan")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    Spacer()

                    // Filter button
                    Button {
                        HapticFeedback.light()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                Spacer()

                // Stats row with price highlight
                HStack(spacing: 8) {
                    // Destinations
                    HStack(spacing: 5) {
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(uniqueCountriesCount > 0 ? uniqueCountriesCount : 190)+")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.12)))

                    // Plans count
                    HStack(spacing: 5) {
                        Image(systemName: "simcard.2.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text("\(coordinator.plans.count)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.12)))

                    Spacer()

                    // Price highlight
                    if cheapestPrice > 0 {
                        HStack(spacing: 4) {
                            Text("from")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                            Text(cheapestPrice.formattedPrice)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.accent)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(AppTheme.accent.opacity(0.15))
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 180)
        .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
        .shadow(color: AppTheme.anthracite.opacity(0.5), radius: 20, x: 0, y: 10)
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(spacing: 14) {
            // Search bar elevated
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(AppTheme.accent)

                TextField("Search country or region...", text: $searchText)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppTheme.textPrimary)

                if !searchText.isEmpty {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            searchText = ""
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.backgroundPrimary)
                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(searchText.isEmpty ? Color.clear : AppTheme.accent.opacity(0.3), lineWidth: 1.5)
            )

            // Filter chips with icons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filters, id: \.self) { filter in
                        FilterChipEnhanced(
                            title: filter,
                            icon: iconForFilter(filter),
                            isSelected: selectedFilter == filter
                        ) {
                            HapticFeedback.selection()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = filter
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func iconForFilter(_ filter: String) -> String {
        switch filter {
        case "All": return "square.grid.2x2"
        case "1GB": return "leaf"
        case "2GB": return "bolt"
        case "5GB": return "flame"
        case "10GB": return "star.fill"
        default: return "circle"
        }
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
            VStack(spacing: 0) {
                if searchText.isEmpty && selectedFilter == "All" && !coordinator.plans.isEmpty {
                    destinationsSection
                }

                HStack {
                    Text(searchText.isEmpty && selectedFilter == "All" ? "ALL PLANS" : "\(filteredPlans.count) RESULTS")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                LazyVStack(spacing: 10) {
                    ForEach(Array(filteredPlans.enumerated()), id: \.element.id) { index, plan in
                        Button {
                            selectedPlan = plan
                        } label: {
                            PlanTechRow(plan: plan, isBestValue: plan.id == bestValuePlanId)
                        }
                        .buttonStyle(.plain)
                        .slideIn(delay: 0.02 * Double(index))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 100)
            }
        }
    }

    private var destinationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.accent)

                    Text("TRENDING")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Text("\(popularDestinations.count) popular")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(popularDestinations.enumerated()), id: \.element.id) { index, dest in
                        Button {
                            HapticFeedback.selection()
                            withAnimation(.spring(response: 0.3)) {
                                searchText = dest.location
                            }
                        } label: {
                            DestinationCardEnhanced(
                                code: dest.code,
                                name: dest.location,
                                count: dest.count,
                                price: dest.minPrice,
                                rank: index + 1
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var loadingView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.Spacing.base) {
                ForEach(0..<5, id: \.self) { index in
                    ShimmerPlaceholder(cornerRadius: 16)
                        .frame(height: 80)
                        .padding(.horizontal, 20)
                        .bounceIn(delay: Double(index) * 0.08)
                }
            }
            .padding(.top, AppTheme.Spacing.md)
        }
    }

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "simcard")
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("No Plans Available")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Pull to refresh")
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(AppTheme.textSecondary)
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
        case "RELEASED", "IN_USE": return AppTheme.success
        case "EXPIRED": return AppTheme.textSecondary
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
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                    .fill(AppTheme.accent.opacity(0.12))
                    .frame(width: 48, height: 48)

                Image(systemName: "simcard.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(order.packageName)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: AppTheme.Spacing.sm) {
                    HStack(spacing: 4) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(AppTheme.Typography.label())
                        Text(order.totalVolume)
                            .font(AppTheme.Typography.small())
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "number")
                            .font(AppTheme.Typography.label())
                        Text(String(order.iccid.prefix(8)) + "...")
                            .font(AppTheme.Typography.small())
                    }
                }
                .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 5, height: 5)

                Text(statusText)
                    .font(AppTheme.Typography.label())
                    .tracking(0.4)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.1))
            )

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
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

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            FlagImage(code: code, size: 44)
                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)

            Text(country)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 3) {
                Text("\(planCount) plans")
                    .font(AppTheme.Typography.label())
                    .foregroundColor(AppTheme.textSecondary)

                Text("·")
                    .foregroundColor(AppTheme.textSecondary)

                Text("from \(minPrice.formattedPrice)")
                    .font(AppTheme.Typography.label())
                    .foregroundColor(AppTheme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.base)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
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

    private var countryCode: String {
        plans.first?.locationCode ?? ""
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppTheme.gray100))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        FlagImage(code: countryCode, size: 28)
                        Text(country)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    Spacer()

                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.sm)
                .padding(.bottom, AppTheme.Spacing.base)

                HStack {
                    Text("\(plans.count) plans available")
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.base)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(plans) { plan in
                            Button {
                                selectedPlan = plan
                            } label: {
                                PlanTechRow(plan: plan)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
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
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? Color(hex: "0F172A") : AppTheme.textSecondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.accent : AppTheme.backgroundPrimary)
                        .shadow(color: Color.black.opacity(isSelected ? 0 : 0.04), radius: 4, x: 0, y: 2)
                )
        }
    }
}

struct FilterChipEnhanced: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))

                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .semibold))
            }
            .foregroundColor(isSelected ? Color(hex: "0F172A") : AppTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? AppTheme.accent : AppTheme.backgroundPrimary)
                    .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.04), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 3 : 2)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppTheme.accent : AppTheme.border.opacity(0.5), lineWidth: isSelected ? 0 : 0.5)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

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

// MARK: - Stock eSIM Row

struct StockESIMRow: View {
    let esim: ESIMOrder

    private var statusColor: Color {
        switch esim.status.uppercased() {
        case "RELEASED", "GOT_RESOURCE": return AppTheme.success
        case "IN_USE": return AppTheme.warning
        default: return AppTheme.textSecondary
        }
    }

    private var statusText: String {
        switch esim.status.uppercased() {
        case "RELEASED", "GOT_RESOURCE": return "AVAILABLE"
        case "IN_USE": return "IN USE"
        default: return esim.status.uppercased()
        }
    }

    private var guessedCode: String {
        let name = esim.packageName.lowercased()
        if name.contains("arab") || name.contains("uae") || name.contains("emirates") { return "AE" }
        if name.contains("turkey") || name.contains("türkiye") { return "TR" }
        if name.contains("saudi") { return "SA" }
        if name.contains("qatar") { return "QA" }
        if name.contains("oman") { return "OM" }
        if name.contains("bahrain") { return "BH" }
        if name.contains("kuwait") { return "KW" }
        return ""
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            FlagImage(code: guessedCode, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(esim.packageName)
                    .font(AppTheme.Typography.button())
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(esim.totalVolume)
                    .font(AppTheme.Typography.small())
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            HStack(spacing: AppTheme.Spacing.sm) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)

                    Text(statusText)
                        .font(AppTheme.Typography.label())
                        .tracking(0.3)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.vertical, 6)
                .background(Capsule().fill(statusColor.opacity(0.1)))
                .fixedSize()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Plan Tech Row

struct PlanTechRow: View {
    let plan: Plan
    var isBestValue: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if isBestValue {
                HStack(spacing: 5) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 9))
                    Text("BEST VALUE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundColor(Color(hex: "0F172A"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(AppTheme.accent)
                .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
            }

            HStack(spacing: 14) {
                FlagImage(code: plan.locationCode, size: 48)
                    .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)

                VStack(alignment: .leading, spacing: 5) {
                    Text(plan.location)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)

                    HStack(spacing: 12) {
                        Label("\(plan.dataGB) GB", systemImage: "arrow.down.circle.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.accent)

                        Label("\(plan.durationDays)d", systemImage: "clock")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)

                        Label(plan.speed, systemImage: "bolt.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .labelStyle(CompactLabelStyle())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.priceUSD.formattedPrice)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("one-time")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textMuted)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isBestValue ? AppTheme.accent.opacity(0.4) : AppTheme.border.opacity(0.3),
                            lineWidth: isBestValue ? 1.5 : 0.5
                        )
                )
                .shadow(color: Color.black.opacity(isBestValue ? 0.08 : 0.04), radius: isBestValue ? 14 : 8, x: 0, y: isBestValue ? 5 : 3)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plan.location), \(plan.dataGB) gigabytes, \(plan.durationDays) jours, \(plan.priceUSD.formattedPrice)")
        .accessibilityHint("Double-tap pour voir les détails")
        .contentShape(Rectangle())
    }
}

struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 3) {
            configuration.icon
            configuration.title
        }
    }
}

// MARK: - Spec Pill

struct SpecPill: View {
    let text: String
    var isHighlighted: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: isHighlighted ? .semibold : .medium))
            .foregroundColor(isHighlighted ? AppTheme.primary : AppTheme.textSecondary)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(isHighlighted ? AppTheme.accent.opacity(0.15) : AppTheme.gray100)
            )
    }
}

// MARK: - Destination Pill

struct DestinationInfo: Identifiable {
    var id: String { code }
    let location: String
    let code: String
    let count: Int
    let minPrice: Double
}

struct DestinationPill: View {
    let code: String
    let name: String
    let count: Int
    let price: Double

    var body: some View {
        VStack(spacing: 10) {
            FlagImage(code: code, size: 52)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                Text("from \(price.formattedPrice)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accent)
            }
        }
        .frame(width: 105)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

struct DestinationCardEnhanced: View {
    let code: String
    let name: String
    let count: Int
    let price: Double
    var rank: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Flag with rank badge
            ZStack(alignment: .topTrailing) {
                FlagImage(code: code, size: 56)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

                if rank > 0 && rank <= 3 {
                    Text("#\(rank)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(rank == 1 ? Color(hex: "0F172A") : .white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(rank == 1 ? AppTheme.accent : AppTheme.anthracite)
                        )
                        .offset(x: 6, y: -4)
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 10)

            VStack(spacing: 3) {
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)

                Text("\(count) plans")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
            }

            Spacer().frame(height: 8)

            // Price tag
            Text(price.formattedPrice)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(AppTheme.accent.opacity(0.1))
                )
                .padding(.bottom, 14)
        }
        .frame(width: 110)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.border.opacity(0.3), lineWidth: 0.5)
        )
    }
}

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

// MARK: - Error State

struct ErrorStateTech: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.error.opacity(0.12))
                    .frame(width: 72, height: 72)

                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(AppTheme.error)
            }

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("Connection Error")
                    .font(AppTheme.Typography.cardAmount())
                    .foregroundColor(.white)

                Text(message)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xxl)
            }

            Button(action: retry) {
                Text("TRY AGAIN")
                    .font(AppTheme.Typography.small())
                    .tracking(1.2)
                    .foregroundColor(Color(hex: "0F172A"))
                    .padding(.horizontal, AppTheme.Spacing.xxl)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .fill(AppTheme.accent)
                    )
            }
            .scaleOnPress()

            Spacer()
        }
        .padding()
    }
}

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
