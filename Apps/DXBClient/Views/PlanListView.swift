import SwiftUI
import DXBCore

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
                Text("ESIM PLANS")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.8)
                    .foregroundColor(AppTheme.textTertiary)

                Text("Explore")
                    .font(.system(size: 34, weight: .bold))
                    .tracking(-0.5)
                    .foregroundColor(AppTheme.textPrimary)

                Text("\(coordinator.plans.count) plans available")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            if coordinator.isLoadingPlans {
                ProgressView()
                    .tint(AppTheme.accent)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)

                TextField("Search plans...", text: $searchText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.surfaceLight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            )

            ScrollView(.horizontal, showsIndicators: false) {
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
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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
            LazyVStack(spacing: 12) {
                ForEach(filteredPlans) { plan in
                    Button {
                        selectedPlan = plan
                    } label: {
                        PlanTechRow(plan: plan)
                    }
                    .buttonStyle(.plain)
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
            Text("Loading plans...")
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
                Text("No Plans Available")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Pull to refresh")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
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

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 52, height: 52)

                Image(systemName: "simcard.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
            }

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
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
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
            ZStack {
                Circle()
                    .fill(AppTheme.gray100)
                    .frame(width: 52, height: 52)

                Text(flagEmoji)
                    .font(.system(size: 26))
            }

            Text(country)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 4) {
                Text("\(planCount) plans")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)

                Text("•")
                    .foregroundColor(AppTheme.textMuted)

                Text("from \(minPrice.formattedPrice)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
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
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AppTheme.surfaceHeavy))
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
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)

                HStack {
                    Text("\(plans.count) plans available")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(plans) { plan in
                            Button {
                                selectedPlan = plan
                            } label: {
                                PlanTechRow(plan: plan)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
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
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AppTheme.accent : AppTheme.surfaceLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.clear : AppTheme.border, lineWidth: 1)
                        )
                )
        }
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
        default: return AppTheme.gray400
        }
    }

    private var statusText: String {
        switch esim.status.uppercased() {
        case "RELEASED", "GOT_RESOURCE": return "AVAILABLE"
        case "IN_USE": return "IN USE"
        default: return esim.status.uppercased()
        }
    }

    private var flagEmoji: String {
        let name = esim.packageName.lowercased()
        if name.contains("arab") || name.contains("uae") || name.contains("emirates") { return "🇦🇪" }
        if name.contains("turkey") || name.contains("türkiye") { return "🇹🇷" }
        if name.contains("saudi") { return "🇸🇦" }
        if name.contains("qatar") { return "🇶🇦" }
        if name.contains("oman") { return "🇴🇲" }
        if name.contains("bahrain") { return "🇧🇭" }
        if name.contains("kuwait") { return "🇰🇼" }
        return "🌍"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.gray100)
                    .frame(width: 44, height: 44)

                Text(flagEmoji)
                    .font(.system(size: 20))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(esim.packageName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(esim.totalVolume)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)

                    Text(statusText)
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.3)
                        .foregroundColor(statusColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(statusColor.opacity(0.1)))
                .fixedSize()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.textMuted)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Plan Tech Row

struct PlanTechRow: View {
    let plan: Plan

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.gray100)
                    .frame(width: 52, height: 52)

                Text(flagEmoji)
                    .font(.system(size: 26))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(plan.location)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 10, weight: .semibold))
                        Text("\(plan.dataGB)GB")
                            .font(.system(size: 12, weight: .medium))
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: .semibold))
                        Text("\(plan.durationDays)d")
                            .font(.system(size: 12, weight: .medium))
                    }
                }
                .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(plan.priceUSD.formattedPrice)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accent)

                Text(plan.speed)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
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
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppTheme.errorLight)
                    .frame(width: 72, height: 72)

                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(AppTheme.error)
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
