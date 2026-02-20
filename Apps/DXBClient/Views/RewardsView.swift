import SwiftUI
import DXBCore
import CoreLocation

struct RewardsView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var locationManager = RewardsLocationManager()
    @State private var offers: [PartnerOffer] = []
    @State private var categories: [OfferCategory] = []
    @State private var selectedCategory: String? = nil
    @State private var isLoading = true
    @State private var wallet: UserWallet?

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    var body: some View {
        NavigationStack {
            ZStack {
                BankingColors.backgroundPrimary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        walletHeader
                        categoryFilter
                        offersContent
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Perks & Rewards")
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await loadOffers() }
            .task { await loadOffers() }
        }
    }

    // MARK: - Wallet Header

    private var walletHeader: some View {
        HStack(spacing: BankingSpacing.base) {
            WalletStat(icon: "star.fill", value: "\(wallet?.xp_total ?? 0)", label: "XP", color: BankingColors.accent)
            WalletStat(icon: "circle.fill", value: "\(wallet?.points_balance ?? 0)", label: "Points", color: BankingColors.accentDark)
            WalletStat(icon: "ticket.fill", value: "\(wallet?.tickets_balance ?? 0)", label: "Tickets", color: AppTheme.warning)
            WalletStat(icon: "flame.fill", value: "\(wallet?.streak_days ?? 0)", label: "Streak", color: AppTheme.error)
        }
        .padding(.horizontal, BankingSpacing.lg)
        .padding(.vertical, BankingSpacing.base)
        .background(BankingColors.backgroundSecondary)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(categories, id: \.id) { cat in
                    CategoryChip(title: cat.label, isSelected: selectedCategory == cat.id) {
                        selectedCategory = cat.id
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Offers

    private var filteredOffers: [PartnerOffer] {
        guard let cat = selectedCategory else { return offers }
        return offers.filter { $0.category == cat }
    }

    private var nearbyOffers: [PartnerOffer] {
        guard let country = locationManager.countryCode else { return [] }
        return filteredOffers.filter { !$0.is_global && ($0.country_codes ?? []).contains(country) }
    }

    private var globalOffers: [PartnerOffer] {
        filteredOffers.filter { $0.is_global }
    }

    private var offersContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else {
                if !nearbyOffers.isEmpty {
                    offerSection(title: locationManager.countryCode != nil ? "Near you" : "In your destination", offers: nearbyOffers)
                }

                offerSection(title: "Global perks", offers: globalOffers)
            }
        }
        .padding(.top, 8)
    }

    private func offerSection(title: String, offers: [PartnerOffer]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)

            ForEach(offers, id: \.id) { offer in
                OfferCard(offer: offer)
                    .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Data Loading

    private func loadOffers() async {
        isLoading = true

        do {
            let country = locationManager.countryCode
            let apiOffers = try await coordinator.currentAPIService.fetchOffers(
                country: country,
                category: selectedCategory
            )

            offers = apiOffers.map { o in
                PartnerOffer(
                    id: o.id,
                    partner_name: o.partner_name ?? "",
                    category: o.category ?? "other",
                    title: o.title ?? "",
                    description: o.description,
                    image_url: o.image_url,
                    discount_percent: o.discount_percent,
                    discount_type: o.discount_type,
                    country_codes: o.country_codes,
                    city: o.city,
                    is_global: o.is_global ?? true,
                    tier_required: o.tier_required
                )
            }
        } catch {
            appLogError(error, message: "Failed to load offers", category: .data)
        }

        do {
            let summary = try await coordinator.currentAPIService.fetchRewardsSummary()
            if let w = summary.wallet {
                wallet = UserWallet(
                    xp_total: w.xp_total ?? 0,
                    level: w.level ?? 1,
                    points_balance: w.points_balance ?? 0,
                    points_earned_total: w.points_earned_total ?? 0,
                    tickets_balance: w.tickets_balance ?? 0,
                    tier: w.tier ?? "free",
                    streak_days: w.streak_days ?? 0
                )
            }
        } catch {
            // Wallet data is non-critical
        }

        locationManager.requestIfNeeded()
        isLoading = false
    }
}

// MARK: - Models

struct PartnerOffer: Identifiable, Codable {
    let id: String
    let partner_name: String
    let category: String
    let title: String
    let description: String?
    let image_url: String?
    let discount_percent: Int?
    let discount_type: String?
    let country_codes: [String]?
    let city: String?
    let is_global: Bool
    let tier_required: String?
}

struct OfferCategory: Identifiable, Codable {
    let id: String
    let label: String
    let icon: String
}

struct UserWallet: Codable {
    let xp_total: Int
    let level: Int
    let points_balance: Int
    let points_earned_total: Int
    let tickets_balance: Int
    let tier: String
    let streak_days: Int
}

// MARK: - Sub-views

struct WalletStat: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = AppTheme.accent

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(AppTheme.Typography.tabLabel())
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            Text(title)
                .font(AppTheme.Typography.tabLabel())
                .foregroundColor(isSelected ? AppTheme.anthracite : AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? AppTheme.accent : AppTheme.gray100)
                )
        }
    }
}

struct OfferCard: View {
    let offer: PartnerOffer

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 56, height: 56)

                Image(systemName: categoryIcon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(offer.partner_name)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.textTertiary)
                        .textCase(.uppercase)

                    if let tier = offer.tier_required {
                        Text(tier.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AppTheme.accent.opacity(0.15)))
                    }
                }

                Text(offer.title)
                    .font(AppTheme.Typography.bodyMedium())
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)

                if let desc = offer.description {
                    Text(desc)
                        .font(AppTheme.Typography.caption())
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let pct = offer.discount_percent, pct > 0 {
                Text("-\(pct)%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.success)
            }

            Image(systemName: "chevron.right")
                .font(AppTheme.Typography.navTitle())
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        )
    }

    private var categoryIcon: String {
        switch offer.category {
        case "activity": return "ticket.fill"
        case "lounge": return "airplane"
        case "transport": return "car.fill"
        case "insurance": return "shield.fill"
        case "food": return "fork.knife"
        case "hotel": return "bed.double.fill"
        default: return "gift.fill"
        }
    }
}

// MARK: - Location Manager

class RewardsLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var countryCode: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    func requestIfNeeded() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            DispatchQueue.main.async {
                self?.countryCode = placemarks?.first?.isoCountryCode
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

#Preview {
    RewardsView()
        .environmentObject(AppCoordinator())
}
