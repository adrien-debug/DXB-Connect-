import SwiftUI
import DXBCore
import AVFoundation

struct DashboardView: View {
    @Environment(AppState.self) private var appState

    @State private var heroAnimated = false

    @State private var showSupport = false
    @State private var showScanner = false
    @State private var usageCache: [String: ESIMUsage] = [:]

    var body: some View {
        ZStack {
            PulseBackground()

            VStack(spacing: 0) {
                smartHeader
                    .padding(.top, 8)

                Spacer()

                heroBalanceCard
                    .padding(.horizontal, AppSpacing.lg)

                Spacer()

                esimCardsRow

                Spacer()

                if appState.subscription == nil {
                    subscriptionPromoBanner
                        .padding(.horizontal, AppSpacing.lg)

                    Spacer()
                }

                if !appState.partnerOffers.isEmpty {
                    promoOffersSection

                    Spacer()
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

    // MARK: - Header

    private var smartHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 46, height: 46)

                Text(String(firstName.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
            .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: 8) {
                    Text(firstName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)

                    if let tier = appState.subscription?.plan {
                        HStack(spacing: 4) {
                            Image(systemName: AppTheme.tierIcon(tier))
                                .font(.system(size: 9))
                            Text(tier.uppercased())
                                .font(.system(size: 8, weight: .bold))
                                .tracking(0.8)
                        }
                        .foregroundStyle(AppTheme.tierColor(tier))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(AppTheme.tierColor(tier).opacity(0.12))
                                .overlay(Capsule().stroke(AppTheme.tierColor(tier).opacity(0.2), lineWidth: 1))
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
            VStack(spacing: 4) {
                HStack {
                    Image(systemName: "simcard.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.accent.opacity(0.8))
                    Text("Total Data Balance")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .tracking(0.8)
                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(remainingDataDisplay.0)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .contentTransition(.numericText())

                    Text(remainingDataDisplay.1)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 5, height: 5)
                        Text("\(usagePercent)% used")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.accent)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 3)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.accent, AppColors.accentLight],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(usagePercent) / 100, height: 3)
                            .shadow(color: AppColors.accent.opacity(0.5), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 3)
                .padding(.top, 2)
            }
            .padding(.horizontal, AppSpacing.base)
            .padding(.vertical, AppSpacing.md)

            Rectangle()
                .fill(Color.white.opacity(0.04))
                .frame(height: 1)

            HStack(spacing: 0) {
                heroMiniStat(
                    icon: "wifi",
                    value: "\(appState.activeESIMs.count)",
                    label: "eSIMs"
                )

                Rectangle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 1, height: 28)

                heroMiniStat(
                    icon: "checkmark.seal.fill",
                    value: "\(activeESIMCount)",
                    label: "Active"
                )

                Rectangle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 1, height: 28)

                heroMiniStat(
                    icon: "globe",
                    value: countriesCount,
                    label: "Countries"
                )
            }
            .padding(.vertical, AppSpacing.sm)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: AppColors.chromeLight, location: 0),
                                .init(color: AppColors.chromeDark, location: 0.4),
                                .init(color: AppColors.chromeMid, location: 0.7),
                                .init(color: AppColors.chromeLight.opacity(0.7), location: 1.0),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.05), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.chromeBorder,
                                AppColors.chromeHighlight.opacity(0.3),
                                AppColors.chromeBorder.opacity(0.5),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: AppColors.accent.opacity(0.08), radius: 24, x: 0, y: 12)
        .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 8)
        .slideIn(delay: 0.05)
    }

    private func heroMiniStat(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(AppColors.accent.opacity(0.7))

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
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
        let countries = Set(appState.activeESIMs.map { $0.packageName.lowercased() })
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
                            simPlaceholder(region: "Europe", data: "5 GB", icon: "globe.europe.africa.fill")
                        }.buttonStyle(.plain)
                        NavigationLink { PlanListView() } label: {
                            simPlaceholder(region: "USA", data: "10 GB", icon: "globe.americas.fill")
                        }.buttonStyle(.plain)
                    } else {
                        ForEach(Array(appState.activeESIMs.prefix(5).enumerated()), id: \.element.id) { index, esim in
                            NavigationLink { ESIMDetailView(esim: esim) } label: {
                                simBadge(esim: esim, isFirst: index == 0)
                            }
                            .buttonStyle(.plain)
                            .scaleOnPress()
                        }
                    }

                    NavigationLink { PlanListView() } label: {
                        addSimBadge
                    }
                    .buttonStyle(.plain)
                    .scaleOnPress()
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .slideIn(delay: 0.1)
    }

    private func simBadge(esim: ESIMOrder, isFirst: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(flagEmoji(for: esim.packageName))
                    .font(.system(size: 16))
                Text(esim.packageName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isFirst ? AppColors.accent : AppColors.textPrimary)
                    .lineLimit(1)
            }

            HStack {
                Text(isFirst ? "Active" : ESIMStatusHelper.label(esim.status))
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(isFirst ? AppColors.accent : AppColors.textSecondary.opacity(0.3))
                    )
                    .foregroundColor(isFirst ? .black : AppColors.textPrimary)

                Spacer()

                Text(esim.totalVolume.isEmpty ? "--" : esim.totalVolume)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(AppSpacing.sm)
        .frame(width: 130, height: 58)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(isFirst ? AppColors.accent.opacity(0.3) : AppColors.border, lineWidth: 1)
                )
        )
    }

    private func simPlaceholder(region: String, data: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textTertiary)
                Text(region)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            HStack {
                Text("eSIM")
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(AppColors.textSecondary.opacity(0.2)))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Text(data)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.sm)
        .frame(width: 130, height: 58)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .strokeBorder(AppColors.border, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                )
        )
    }

    private var addSimBadge: some View {
        VStack(spacing: 4) {
            Image(systemName: "plus.circle")
                .font(.system(size: 18, weight: .light))
                .foregroundColor(AppColors.accent.opacity(0.6))
            Text("Get eSIM")
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(width: 60, height: 58)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .strokeBorder(AppColors.accent.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                )
        )
    }

    // MARK: - Subscription Promo Banner

    private var subscriptionPromoBanner: some View {
        NavigationLink {
            SubscriptionView()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("SimPass Premium")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Up to -30% on eSIMs · From $3.33/mo")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text("TRY FREE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppColors.accent))
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.base)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                            .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
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
            PulseSectionHeader(title: "Exclusive Offers")
                .padding(.horizontal, AppSpacing.lg)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(appState.partnerOffers.prefix(5)) { offer in
                        promoOfferCard(offer)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .slideIn(delay: 0.18)
    }

    private func promoOfferCard(_ offer: PartnerOfferResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = offer.image_url, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .frame(width: 200, height: 100)
                            .clipped()
                    default:
                        ZStack {
                            Rectangle().fill(AppColors.surfaceSecondary)
                            Image(systemName: "tag.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.accent.opacity(0.3))
                        }
                        .frame(width: 200, height: 100)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(offer.partner_name ?? "Partner")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(offer.title ?? "Special Offer")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }

            if let discount = offer.discount_percent, discount > 0 {
                Text("-\(discount)%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.success)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(AppColors.success.opacity(0.12)))
            }
        }
        .frame(width: 200)
        .bentoCard()
    }

    // MARK: - My eSIMs Section

    private var myEsimsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            NavigationLink {
                MyESIMsView()
            } label: {
                PulseSectionHeader(
                    title: "My eSIMs",
                    action: appState.activeESIMs.isEmpty ? nil : "View all",
                    onAction: {}
                )
            }
            .buttonStyle(.plain)

            if appState.activeESIMs.isEmpty {
                emptyESIMCard
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(appState.activeESIMs.prefix(3).enumerated()), id: \.element.id) { index, order in
                        NavigationLink {
                            ESIMDetailView(esim: order)
                        } label: {
                            esimRow(order: order)
                        }
                        .buttonStyle(.plain)

                        if index < min(2, appState.activeESIMs.count - 1) {
                            Divider()
                                .background(AppColors.border)
                                .padding(.leading, 56)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .fill(AppColors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
            }
        }
        .slideIn(delay: 0.25)
    }

    private var emptyESIMCard: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.1))
                    .frame(width: 72, height: 72)

                Image(systemName: "simcard")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(AppColors.accent)
            }

            VStack(spacing: 6) {
                Text("No eSIMs yet")
                    .font(AppFonts.bodyMedium())
                    .foregroundColor(AppColors.textPrimary)

                Text("Get connected worldwide in seconds")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }

            NavigationLink {
                PlanListView()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Get Started")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
                .background(
                    Capsule().fill(AppColors.accent)
                )
            }
            .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 6)
            .scaleOnPress()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxxl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
    }

    private func esimRow(order: ESIMOrder) -> some View {
        let isActive = ["RELEASED", "IN_USE", "ENABLED", "ACTIVE"].contains(order.status.uppercased())

        return HStack(spacing: AppSpacing.md) {
            Text(flagEmoji(for: order.packageName))
                .font(.system(size: 24))
                .frame(width: 40, height: 40)
                .background(Circle().fill(AppColors.surfaceSecondary))

            VStack(alignment: .leading, spacing: 2) {
                Text(order.packageName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Text(isActive ? "Active" : order.status.capitalized)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Text(order.totalVolume.isEmpty ? "—" : order.totalVolume)
                .font(.system(size: 14))
                .foregroundColor(isActive ? AppColors.accent : AppColors.textSecondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.base)
        .padding(.vertical, AppSpacing.md)
    }

    // MARK: - Helpers

    private var remainingDataDisplay: (String, String) {
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
        guard !usageCache.isEmpty else {
            let active = appState.activeESIMs.filter {
                ["RELEASED", "IN_USE", "ENABLED", "ACTIVE"].contains($0.status.uppercased())
            }
            guard !active.isEmpty else { return 0 }
            return 0
        }
        let totalBytes = usageCache.values.reduce(Int64(0)) { $0 + $1.totalBytes }
        let usedBytes = usageCache.values.reduce(Int64(0)) { $0 + $1.usedBytes }
        guard totalBytes > 0 else { return 0 }
        return Int(Double(usedBytes) / Double(totalBytes) * 100)
    }

    private func flagEmoji(for packageName: String) -> String {
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
                appLog("Usage fetch failed for \(esim.iccid): \(error.localizedDescription)", level: .warning, category: .data)
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
            appLog("Camera setup failed: \(error.localizedDescription)", level: .error, category: .general)
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
            appLog("Torch configuration failed: \(error.localizedDescription)", level: .warning, category: .general)
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
