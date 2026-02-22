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
        .navigationTitle("Exclusive Offers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
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

    private func offerCard(_ offer: PartnerOfferResponse) -> some View {
        HStack(spacing: AppSpacing.md) {
            if let imageUrl = offer.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                    default:
                        ZStack {
                            Rectangle().fill(AppColors.surfaceSecondary)
                            Image(systemName: "tag.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(AppColors.accent.opacity(0.3))
                        }
                        .frame(width: 80, height: 80)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(AppColors.surfaceSecondary)
                    Image(systemName: "tag.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.accent.opacity(0.3))
                }
                .frame(width: 80, height: 80)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(offer.partner_name ?? "Partner")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(offer.title ?? "Special Offer")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if let cat = offer.category {
                        Text(cat.capitalized)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(AppColors.textTertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(AppColors.surfaceSecondary))
                    }

                    if let tier = offer.tier_required {
                        HStack(spacing: 2) {
                            Image(systemName: AppTheme.tierIcon(tier))
                                .font(.system(size: 7))
                            Text(tier.uppercased())
                                .font(.system(size: 8, weight: .black))
                        }
                        .foregroundStyle(AppTheme.tierColor(tier))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(AppTheme.tierColor(tier).opacity(0.1)))
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let discount = offer.discount_percent, discount > 0 {
                    Text("-\(discount)%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.success)
                }

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 0.5)
                )
        )
    }

    private var loadingCard: some View {
        HStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.md).fill(AppColors.surfaceSecondary).frame(width: 80, height: 80)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary).frame(width: 120, height: 14)
                RoundedRectangle(cornerRadius: AppRadius.xs).fill(AppColors.surfaceSecondary).frame(width: 180, height: 10)
            }
            Spacer()
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous).stroke(AppColors.border, lineWidth: 0.5))
        )
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
            appLog("Failed to load offers: \(error.localizedDescription)", level: .error, category: .data)
        }
    }

    private func openOffer(_ offer: PartnerOfferResponse) async {
        do {
            let response = try await appState.apiService.trackOfferClick(offerId: offer.id, country: nil)
            if let urlString = response.data?.redirectUrl, let url = URL(string: urlString) {
                await MainActor.run {
                    UIApplication.shared.open(url)
                }
            }
        } catch {
            appLog("Offer click failed: \(error.localizedDescription)", level: .warning, category: .data)
        }
    }
}

#Preview {
    NavigationStack { OffersListView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
