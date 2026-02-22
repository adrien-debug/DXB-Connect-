import SwiftUI
import DXBCore
import AVFoundation

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    @State private var showSupport = false
    @State private var showScanner = false
    @State private var usageCache: [String: ESIMUsage] = [:]

    var body: some View {
        ZStack {
            PulseBackground()

            if appState.isDashboardLoading && appState.activeESIMs.isEmpty {
                loadingState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        smartHeader
                            .padding(.top, 8)

                        heroBalanceCard
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.top, AppSpacing.xl)

                        esimCardsRow
                            .padding(.top, AppSpacing.xl)

                        if let errorMsg = appState.dashboardError {
                            errorBanner(errorMsg)
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.top, AppSpacing.md)
                        }

                        if appState.subscription == nil {
                            subscriptionPromoBanner
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.top, AppSpacing.xl)
                        }

                        if !appState.partnerOffers.isEmpty {
                            promoOffersSection
                                .padding(.top, AppSpacing.xl)
                        }

                        Spacer(minLength: AppSpacing.xxl)
                    }
                }
                .refreshable {
                    await appState.loadDashboard()
                    usageCache.removeAll()
                    await loadUsageData()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if appState.activeESIMs.isEmpty && !appState.isDashboardLoading {
                await appState.loadDashboard()
            }
            await loadUsageData()
        }
        .sheet(isPresented: $showSupport) { SupportView() }
        .sheet(isPresented: $showScanner) { ScannerSheet() }
    }

    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .tint(AppColors.accent)
                .scaleEffect(1.2)

            Text("Loading your dashboard...")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(AppColors.warning)

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)

            Spacer()

            Button {
                Task { await appState.loadDashboard() }
            } label: {
                Text("Retry")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.accent)
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(AppColors.warning.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .stroke(AppColors.warning.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Header

    private var smartHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 42, height: 42)

                Text(String(firstName.prefix(1)).uppercased())
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
            .shadow(color: AppColors.accent.opacity(0.2), radius: 8, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 1) {
                Text(greeting)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: 6) {
                    Text(firstName)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    if let tier = appState.subscription?.plan {
                        HStack(spacing: 3) {
                            Image(systemName: AppTheme.tierIcon(tier))
                                .font(.system(size: 8))
                            Text(tier.uppercased())
                                .font(.system(size: 7, weight: .black))
                                .tracking(0.6)
                        }
                        .foregroundStyle(AppTheme.tierColor(tier))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(AppTheme.tierColor(tier).opacity(0.1))
                        )
                    }
                }
            }

            Spacer()

            PulseIconButton(icon: "qrcode.viewfinder") {
                HapticFeedback.light()
                showScanner = true
            }

            PulseIconButton(icon: "bell") {
                HapticFeedback.light()
                showSupport = true
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .slideIn(delay: 0)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private var firstName: String {
        let name = appState.currentUser?.name ?? "User"
        return name.components(separatedBy: " ").first ?? name
    }

    // MARK: - Hero Balance Card

    private var heroBalanceCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "simcard.2.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.accent.opacity(0.7))
                    Text("Total Data Balance")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .tracking(1.0)
                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(remainingDataDisplay.0)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .contentTransition(.numericText())

                    Text(remainingDataDisplay.1)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textTertiary)

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 6, height: 6)
                        Text("\(usagePercentDisplay) used")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.accent)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.accent, AppColors.accentLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * CGFloat(usagePercent) / 100, 0), height: 4)
                            .shadow(color: AppColors.accent.opacity(0.4), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 4)
                .padding(.top, 4)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.base)

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                heroMiniStat(
                    icon: "wifi",
                    value: "\(appState.activeESIMs.count)",
                    label: "eSIMs"
                )

                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 0.5, height: 30)

                heroMiniStat(
                    icon: "checkmark.seal.fill",
                    value: "\(activeESIMCount)",
                    label: "Active"
                )

                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 0.5, height: 30)

                heroMiniStat(
                    icon: "globe",
                    value: countriesCount,
                    label: "Countries"
                )
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: AppColors.chromeLight.opacity(0.8), location: 0),
                                .init(color: AppColors.chromeDark, location: 0.5),
                                .init(color: AppColors.chromeMid.opacity(0.9), location: 1.0),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.04), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.chromeBorder.opacity(0.6),
                                AppColors.chromeHighlight.opacity(0.2),
                                AppColors.chromeBorder.opacity(0.3),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
        )
        .shadow(color: AppColors.accent.opacity(0.06), radius: 20, x: 0, y: 10)
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        .slideIn(delay: 0.05)
    }

    private func heroMiniStat(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(AppColors.accent.opacity(0.6))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var activeESIMCount: Int {
        appState.activeESIMs.filter {
            ["RELEASED", "IN_USE", "ENABLED", "ACTIVE"].contains($0.status.uppercased())
        }.count
    }

    private var countriesCount: String {
        let countries = Set(appState.activeESIMs.map {
            $0.packageName.components(separatedBy: " ").first?.lowercased() ?? $0.packageName.lowercased()
        })
        return "\(countries.count)"
    }

    // MARK: - eSIM Cards Row

    private var esimCardsRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                PulseSectionHeader(title: "My SIMs")
                Spacer()
                if !appState.activeESIMs.isEmpty {
                    NavigationLink { MyESIMsView() } label: {
                        Text("View all")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.accent)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    if appState.activeESIMs.isEmpty {
                        NavigationLink { PlanListView() } label: {
                            emptySimPrompt
                        }.buttonStyle(.plain)
                    } else {
                        ForEach(Array(appState.activeESIMs.prefix(5).enumerated()), id: \.element.id) { index, esim in
                            NavigationLink { ESIMDetailView(esim: esim) } label: {
                                simBadge(esim: esim, isFirst: index == 0)
                            }
                            .buttonStyle(.plain)
                            .scaleOnPress()
                        }

                        NavigationLink { PlanListView() } label: {
                            addSimBadge
                        }
                        .buttonStyle(.plain)
                        .scaleOnPress()
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .slideIn(delay: 0.1)
    }

    private func simBadge(esim: ESIMOrder, isFirst: Bool) -> some View {
        let isActive = ESIMStatusHelper.isActive(esim.status)
        let statusLabel = ESIMStatusHelper.label(esim.status)
        let statusColor = ESIMStatusHelper.color(esim.status)

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(flagFromPackage(esim.packageName))
                    .font(.system(size: 18))
                Text(esim.packageName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }

            HStack {
                Text(statusLabel)
                    .font(.system(size: 8, weight: .black))
                    .tracking(0.3)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(isActive ? statusColor : AppColors.textSecondary.opacity(0.2))
                    )
                    .foregroundColor(isActive ? .black : AppColors.textPrimary)

                Spacer()

                Text(esim.totalVolume.isEmpty ? "--" : esim.totalVolume)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(width: 140, height: 64)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(isActive ? AppColors.accent.opacity(0.25) : AppColors.border, lineWidth: 0.5)
                )
        )
    }

    private var emptySimPrompt: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(AppColors.accent.opacity(0.6))

            VStack(alignment: .leading, spacing: 2) {
                Text("Get your first eSIM")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text("Browse plans")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.md)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .strokeBorder(AppColors.accent.opacity(0.15), style: StrokeStyle(lineWidth: 0.5, dash: [6, 4]))
                )
        )
    }

    private var addSimBadge: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus.circle")
                .font(.system(size: 20, weight: .light))
                .foregroundColor(AppColors.accent.opacity(0.5))
            Text("Get eSIM")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(width: 64, height: 64)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .strokeBorder(AppColors.accent.opacity(0.12), style: StrokeStyle(lineWidth: 0.5, dash: [6, 4]))
                )
        )
    }

    // MARK: - Subscription Promo Banner

    private var subscriptionPromoBanner: some View {
        NavigationLink {
            SubscriptionView()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("SimPass Premium")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Up to -50% on eSIMs · From $3.33/mo")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text("SUBSCRIBE")
                    .font(.system(size: 10, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppColors.accent))
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                            .stroke(AppColors.accent.opacity(0.15), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleOnPress()
        .slideIn(delay: 0.15)
    }

    // MARK: - Partner Offers / Promos

    private var promoOffersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    PulseSectionHeader(title: "Exclusive Offers")
                    if let country = appState.locationManager.detectedCountryCode {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 9))
                            Text(countryName(for: country))
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(AppColors.accent)
                        .padding(.leading, 2)
                    }
                }
                Spacer()
                NavigationLink { OffersListView() } label: {
                    Text("View all")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.accent)
                }
            }
            .padding(.horizontal, AppSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(appState.partnerOffers) { offer in
                        Button {
                            Task { await openOffer(offer) }
                        } label: {
                            promoOfferCard(offer)
                        }
                        .buttonStyle(.plain)
                        .scaleOnPress()
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .slideIn(delay: 0.18)
    }

    private func offerImageURL(_ offer: PartnerOfferResponse) -> URL? {
        if let imageUrl = offer.image_url, let url = URL(string: imageUrl) { return url }
        let keyword: String
        if let city = offer.city { keyword = city }
        else if let codes = offer.country_codes, let first = codes.first {
            keyword = countryName(for: first)
        } else if let cat = offer.category { keyword = cat == "activity" ? "travel" : cat }
        else { keyword = "travel" }
        let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "travel"
        return URL(string: "https://source.unsplash.com/600x400/?\(encoded)")
    }

    private func promoOfferCard(_ offer: PartnerOfferResponse) -> some View {
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
                                .font(.system(size: 32, weight: .light))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                .frame(width: 170, height: 120)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)

                Group {
                    if let codes = offer.country_codes, let code = codes.first {
                        HStack(spacing: 3) {
                            Text(flagEmoji(for: code))
                                .font(.system(size: 12))
                            if let city = offer.city {
                                Text(city)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(.ultraThinMaterial))
                    } else if offer.is_global == true {
                        HStack(spacing: 3) {
                            Text("🌍")
                                .font(.system(size: 11))
                            Text("Global")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(.ultraThinMaterial))
                    }
                }
                .padding(6)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(offer.title ?? "Special Offer")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 0) {
                    Text(offer.partner_name ?? "Viator")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppColors.accent)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(AppColors.accent)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
            .padding(.bottom, 8)
        }
        .frame(width: 170)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 0.5)
                )
        )
    }

    private func offerCategoryIcon(_ category: String?) -> String {
        switch category {
        case "activity": return "figure.hiking"
        case "transport": return "car.fill"
        case "food": return "fork.knife"
        case "hotel": return "bed.double.fill"
        case "lounge": return "cup.and.saucer.fill"
        case "insurance": return "shield.checkered"
        default: return "sparkles"
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
            print("[Dashboard] Offer click failed: \(error.localizedDescription)")
            #endif
        }
    }

    private func countryName(for code: String) -> String {
        Locale.current.localizedString(forRegionCode: code) ?? code
    }

    private func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        return countryCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value).map(String.init)
        }.joined()
    }

    // MARK: - Helpers

    private var isUsageLoaded: Bool { !usageCache.isEmpty || appState.activeESIMs.isEmpty }

    private var remainingDataDisplay: (String, String) {
        guard isUsageLoaded else { return ("--", "") }
        let totalRemaining = totalRemainingGB
        if totalRemaining >= 1 {
            return (String(format: "%.1f", totalRemaining), "GB")
        } else {
            return (String(format: "%.0f", totalRemaining * 1024), "MB")
        }
    }

    private var totalRemainingGB: Double {
        guard !usageCache.isEmpty else { return 0 }
        let totalRemaining = usageCache.values.reduce(Int64(0)) { $0 + $1.remainingBytes }
        return Double(totalRemaining) / 1_073_741_824
    }

    private var usagePercent: Int {
        guard !usageCache.isEmpty else { return 0 }
        let totalBytes = usageCache.values.reduce(Int64(0)) { $0 + $1.totalBytes }
        let usedBytes = usageCache.values.reduce(Int64(0)) { $0 + $1.usedBytes }
        guard totalBytes > 0 else { return 0 }
        return Int(Double(usedBytes) / Double(totalBytes) * 100)
    }

    private var usagePercentDisplay: String {
        guard isUsageLoaded else { return "--" }
        return "\(usagePercent)%"
    }

    private func flagFromPackage(_ packageName: String) -> String {
        CountryHelper.flagFromName(packageName)
    }

    // MARK: - Data Loading

    private func loadUsageData() async {
        for esim in appState.activeESIMs where !esim.iccid.isEmpty && usageCache[esim.iccid] == nil {
            do {
                if let usage = try await appState.apiService.fetchUsage(iccid: esim.iccid) {
                    usageCache[esim.iccid] = usage
                }
            } catch {
                #if DEBUG
                print("[Dashboard] Usage fetch failed for \(esim.iccid): \(error.localizedDescription)")
                #endif
            }
        }
    }
}

// MARK: - Scanner Sheet

struct ScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scannedCode: String?
    @State private var torchOn = false
    @State private var showCopied = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    PulseIconButton(icon: "xmark") { dismiss() }
                    Spacer()
                    Text("SCAN QR CODE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    PulseIconButton(icon: torchOn ? "flashlight.on.fill" : "flashlight.off.fill") {
                        torchOn.toggle()
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)

                Spacer()

                ZStack {
                    QRScannerView(scannedCode: $scannedCode, torchOn: $torchOn)
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))

                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .stroke(AppColors.accent, lineWidth: 3)
                        .frame(width: 280, height: 280)
                        .shadow(color: AppColors.accent.opacity(0.4), radius: 20)

                    ScannerCorners()
                        .frame(width: 280, height: 280)
                }

                if let code = scannedCode {
                    VStack(spacing: AppSpacing.sm) {
                        Text("QR Code Scanned")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.success)

                        Text(code)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                            .padding(AppSpacing.sm)
                            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: AppRadius.sm))

                        Button {
                            UIPasteboard.general.string = code
                            showCopied = true
                            HapticFeedback.success()
                        } label: {
                            Label(showCopied ? "Copied!" : "Copy LPA Code", systemImage: showCopied ? "checkmark" : "doc.on.doc")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.top, 20)
                } else {
                    VStack(spacing: 8) {
                        Text("Position QR code in frame")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)

                        Text("Align the eSIM QR code within the scanner area")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                }

                Spacer()
            }
        }
    }
}

struct ScannerCorners: View {
    var body: some View {
        ZStack {
            ForEach([0, 1, 2, 3], id: \.self) { index in
                CornerShape()
                    .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(
                        x: index == 0 || index == 3 ? -115 : 115,
                        y: index == 0 || index == 1 ? -115 : 115
                    )
            }
        }
    }
}

struct CornerShape: Shape {
    var length: CGFloat = 20
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + length))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + length, y: rect.minY))
        return path
    }
}

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var torchOn: Bool

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        uiViewController.setTorch(on: torchOn)
    }

    func makeCoordinator() -> Coordinator { Coordinator(scannedCode: $scannedCode) }

    class Coordinator: NSObject, QRScannerDelegate {
        @Binding var scannedCode: String?
        init(scannedCode: Binding<String?>) { _scannedCode = scannedCode }
        func didScan(code: String) {
            HapticFeedback.success()
            scannedCode = code
        }
    }
}

protocol QRScannerDelegate: AnyObject {
    func didScan(code: String)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerDelegate?
    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input) { captureSession.addInput(input) }
            let output = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: .main)
                output.metadataObjectTypes = [.qr]
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill
            previewLayer?.frame = view.bounds
            if let layer = previewLayer { view.layer.addSublayer(layer) }
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        } catch {
            #if DEBUG
            print("[Scanner] Camera setup failed: \(error.localizedDescription)")
            #endif
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            #if DEBUG
            print("[Scanner] Torch configuration failed: \(error.localizedDescription)")
            #endif
        }
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }
        captureSession.stopRunning()
        delegate?.didScan(code: code)
    }
}

#Preview {
    DashboardView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
