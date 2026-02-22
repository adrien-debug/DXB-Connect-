import SwiftUI
import DXBCore

struct OffersListView: View {
    @Environment(AppState.self) private var appState

    @State private var offers: [PartnerOfferResponse] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedCategory: String?

    private var categories: [String] {
        Array(Set(offers.compactMap { $0.category })).sorted()
    }

    private var filteredOffers: [PartnerOfferResponse] {
        guard let cat = selectedCategory else { return offers }
        return offers.filter { $0.category == cat }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                categoryFilter
                offersList
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("Exclusive Offers")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                    if let country = appState.locationManager.detectedCountryCode {
                        HStack(spacing: 3) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                            Text(Locale.current.localizedString(forRegionCode: country) ?? country)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(AppColors.accent)
                    }
                }
            }
        }
        .task { await loadOffers() }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                categoryPill(nil, label: "All")
                ForEach(categories, id: \.self) { cat in
                    categoryPill(cat, label: cat.capitalized)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
        }
    }

    private func categoryPill(_ category: String?, label: String) -> some View {
        let isSelected = selectedCategory == category

        return Button {
            withAnimation(.spring(response: 0.3)) { selectedCategory = category }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .black : AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.base)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.accent : AppColors.surface)
                        .overlay(
                            Capsule().stroke(isSelected ? Color.clear : AppColors.border, lineWidth: 0.5)
                        )
                )
        }
    }

    // MARK: - Offers List

    private var offersList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppSpacing.md) {
                if isLoading {
                    ForEach(0..<4, id: \.self) { _ in loadingCard }
                } else if let error = errorMessage {
                    EmptyStateView(icon: "wifi.exclamationmark", title: "Error", subtitle: error, actionTitle: "Retry") {
                        Task { await loadOffers() }
                    }
                } else if filteredOffers.isEmpty {
                    EmptyStateView(icon: "tag.fill", title: "No offers", subtitle: "Check back soon for exclusive deals")
                } else {
                    ForEach(filteredOffers) { offer in
                        Button {
                            Task { await openOffer(offer) }
                        } label: {
                            offerCard(offer)
                        }
                        .buttonStyle(.plain)
                        .scaleOnPress()
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, 120)
        }
        .refreshable { await loadOffers() }
    }

    private func offerImageURL(_ offer: PartnerOfferResponse) -> URL? {
        if let imageUrl = offer.image_url, let url = URL(string: imageUrl) { return url }
        let keyword: String
        if let city = offer.city { keyword = city }
        else if let codes = offer.country_codes, let first = codes.first {
            keyword = Locale.current.localizedString(forRegionCode: first) ?? first
        } else if let cat = offer.category { keyword = cat == "activity" ? "travel" : cat }
        else { keyword = "travel" }
        let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "travel"
        return URL(string: "https://source.unsplash.com/600x400/?\(encoded)")
    }

    private func flagEmoji(for countryCode: String) -> String {
        OfferHelper.flagEmoji(for: countryCode)
    }

    private func offerCategoryIcon(_ category: String?) -> String {
        OfferHelper.categoryIcon(category)
    }

    private func offerCard(_ offer: PartnerOfferResponse) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: offerImageURL(offer)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        ZStack {
                            Rectangle().fill(
                                LinearGradient(
                                    colors: [AppColors.accent.opacity(0.3), AppColors.surfaceSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            Image(systemName: offerCategoryIcon(offer.category))
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.65)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)

                HStack(spacing: 6) {
                    if let codes = offer.country_codes, let code = codes.first {
                        HStack(spacing: 4) {
                            Text(flagEmoji(for: code))
                                .font(.system(size: 16))
                            if let city = offer.city {
                                Text(city)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.ultraThinMaterial))
                    } else if offer.is_global == true {
                        HStack(spacing: 4) {
                            Text("🌍")
                                .font(.system(size: 14))
                            Text("Worldwide")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.ultraThinMaterial))
                    }

                    if let discount = offer.discount_percent, discount > 0 {
                        Text("-\(discount)%")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(AppColors.success))
                    }

                    if let tier = offer.tier_required {
                        HStack(spacing: 3) {
                            Image(systemName: AppTheme.tierIcon(tier))
                                .font(.system(size: 8))
                            Text(tier.uppercased())
                                .font(.system(size: 9, weight: .black))
                        }
                        .foregroundStyle(AppTheme.tierColor(tier))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.tierColor(tier).opacity(0.15)))
                    }
                }
                .padding(AppSpacing.sm)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 6) {
                        Text(offer.partner_name ?? "Viator")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppColors.accent)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        if let cat = offer.category {
                            Text("·")
                                .foregroundStyle(AppColors.textTertiary)
                            Text(cat.capitalized)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(AppColors.textTertiary)
                        }
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.accent)
                }

                Text(offer.title ?? "Special Offer")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(offer.description ?? "")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            .padding(AppSpacing.base)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 0.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
    }

    private var loadingCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 0).fill(AppColors.surfaceSecondary)
                .frame(height: 180)
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary)
                    .frame(width: 80, height: 10)
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary)
                    .frame(width: 220, height: 16)
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary)
                    .frame(width: 180, height: 12)
            }
            .padding(AppSpacing.base)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous).stroke(AppColors.border, lineWidth: 0.5))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .shimmer()
    }

    // MARK: - Actions

    private func loadOffers() async {
        isLoading = true
        errorMessage = nil
        do {
            let country = appState.locationManager.detectedCountryCode
            let tier = appState.subscription?.plan
            offers = try await appState.apiService.fetchOffers(country: country, category: nil, tier: tier)
            isLoading = false
        } catch {
            errorMessage = "Unable to load offers"
            isLoading = false
            #if DEBUG
            print("[OffersListView] Failed to load offers: \(error.localizedDescription)")
            #endif
        }
    }

    private func openOffer(_ offer: PartnerOfferResponse) async {
        do {
            let country = appState.locationManager.detectedCountryCode
            let response = try await appState.apiService.trackOfferClick(offerId: offer.id, country: country)
            if let urlString = response.data?.redirectUrl, let url = URL(string: urlString) {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        } catch {
            #if DEBUG
            print("[OffersListView] Offer click failed: \(error.localizedDescription)")
            #endif
        }
    }
}

#Preview {
    NavigationStack { OffersListView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
