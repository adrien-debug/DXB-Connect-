import SwiftUI
import DXBCore

struct ESIMDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var esim: ESIMOrder?

    @State private var usage: ESIMUsage?
    @State private var isLoadingUsage = true
    @State private var topUpPackages: [TopUpPackage] = []
    @State private var isLoadingTopUp = false
    @State private var showQRCode = false
    @State private var actionInProgress: String?
    @State private var selectedTopUp: TopUpPackage?
    @State private var topUpError: String?
    @State private var topUpSuccess = false

    private var currentESIM: ESIMOrder? {
        esim ?? appState.activeESIMs.first
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            if let esim = currentESIM {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppSpacing.base) {
                        usageHero(esim).slideIn(delay: 0)
                        esimInfoCard(esim).slideIn(delay: 0.05)
                        actionsGrid(esim).slideIn(delay: 0.1)
                        if !topUpPackages.isEmpty {
                            topUpSection.slideIn(delay: 0.15)
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, 120)
                }
                .refreshable { await loadData() }
            } else {
                EmptyStateView(icon: "simcard", title: "No eSIM", subtitle: "You don't have an active eSIM")
            }

            if let action = actionInProgress {
                LoadingOverlay(message: action)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("eSIM DETAILS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .sheet(isPresented: $showQRCode) { qrCodeSheet }
        .confirmationDialog("Top Up", isPresented: Binding(
            get: { selectedTopUp != nil },
            set: { if !$0 { selectedTopUp = nil } }
        )) {
            if let pkg = selectedTopUp {
                Button("Buy \(pkg.name) for \(pkg.priceUSD.formattedPrice)") {
                    Task { await purchaseTopUp(pkg) }
                }
            }
            Button("Cancel", role: .cancel) { selectedTopUp = nil }
        } message: {
            if let pkg = selectedTopUp {
                Text("Add \(pkg.dataGB) GB for \(pkg.durationDays) days?")
            }
        }
        .alert("Top Up Successful", isPresented: $topUpSuccess) {
            Button("OK") {}
        } message: {
            Text("Your eSIM has been topped up. Data will be available shortly.")
        }
        .alert("Top Up Failed", isPresented: Binding(
            get: { topUpError != nil },
            set: { if !$0 { topUpError = nil } }
        )) {
            Button("OK") { topUpError = nil }
        } message: {
            Text(topUpError ?? "")
        }
        .task { await loadData() }
    }

    // MARK: - Usage Hero

    private func usageHero(_ esim: ESIMOrder) -> some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack {
                CleanArcProgress(progress: usage?.usagePercentage ?? 0, lineWidth: 8, size: 140)

                VStack(spacing: 4) {
                    if isLoadingUsage {
                        ProgressView().tint(AppColors.accent)
                    } else if let usage {
                        Text(usage.usedDisplay)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("of \(usage.totalDisplay)")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textSecondary)
                    } else {
                        Image(systemName: "simcard.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(AppColors.textTertiary)
                        Text("Unavailable")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
            }

            VStack(spacing: 6) {
                Text(esim.packageName)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                StatusBadge(text: statusLabel(esim.status), color: statusColor(esim.status))
            }

            if let usage {
                HStack(spacing: 0) {
                    usageStat(label: "Used", value: usage.usedDisplay, color: AppColors.warning)
                    Rectangle().fill(AppColors.border.opacity(0.5)).frame(width: 0.5, height: 32)
                    usageStat(label: "Remaining", value: usage.remainingDisplay, color: AppColors.success)
                    Rectangle().fill(AppColors.border.opacity(0.5)).frame(width: 0.5, height: 32)
                    usageStat(label: "Expires", value: formatExpiry(usage.expiredTime), color: AppColors.info)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .chromeCard(accentGlow: true)
    }

    private func usageStat(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Info Card

    private func esimInfoCard(_ esim: ESIMOrder) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("Information")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Button { showQRCode = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "qrcode")
                        Text("QR")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
                }
            }

            VStack(spacing: 10) {
                infoRow(label: "ICCID", value: esim.iccid.isEmpty ? "Pending" : esim.iccid)
                infoRow(label: "Order", value: esim.orderNo)
                infoRow(label: "Volume", value: esim.totalVolume)
                infoRow(label: "Expires", value: formatExpiry(esim.expiredTime))
                infoRow(label: "Created", value: formatDate(esim.createdAt))
            }
        }
        .pulseCard()
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value.isEmpty ? "--" : value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
        }
    }

    // MARK: - Actions Grid

    private func actionsGrid(_ esim: ESIMOrder) -> some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                actionTile(icon: "arrow.clockwise", label: "Refresh", color: AppColors.info) {
                    await loadData()
                }

                if isActive(esim.status) {
                    actionTile(icon: "pause.circle.fill", label: "Suspend", color: AppColors.warning) {
                        await suspendESIM(esim)
                    }
                } else if esim.status.uppercased() == "DISABLED" {
                    actionTile(icon: "play.circle.fill", label: "Activate", color: AppColors.success) {
                        await resumeESIM(esim)
                    }
                }
            }

            Button { showQRCode = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "qrcode")
                    Text("View Installation QR Code")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private func actionTile(icon: String, label: String, color: Color, action: @escaping () async -> Void) -> some View {
        Button { Task { await action() } } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .chromeCard()
        }
    }

    // MARK: - Top-Up

    private var topUpSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Top Up")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                if isLoadingTopUp {
                    ProgressView().tint(AppColors.accent).scaleEffect(0.8)
                }
            }

            ForEach(topUpPackages.prefix(3)) { pkg in
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(pkg.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        HStack(spacing: 8) {
                            Label("\(pkg.dataGB) GB", systemImage: "arrow.down.circle.fill")
                            Label("\(pkg.durationDays)d", systemImage: "calendar")
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(pkg.priceUSD.formattedPrice)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.accent)

                        Button {
                            selectedTopUp = pkg
                        } label: {
                            Text("Buy")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(AppColors.accent, in: Capsule())
                        }
                    }
                }
                .padding(AppSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(AppColors.backgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                )
            }
        }
        .pulseCard()
    }

    // MARK: - QR Code Sheet

    private var qrCodeSheet: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                HStack {
                    Text("Installation QR Code")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                    Button { showQRCode = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)

                Spacer()

                VStack(spacing: AppSpacing.lg) {
                    if let esim = currentESIM, !esim.qrCodeUrl.isEmpty {
                        AsyncImage(url: URL(string: esim.qrCodeUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit()
                                    .frame(width: 220, height: 220)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                            case .failure: qrPlaceholder
                            case .empty:
                                ProgressView().tint(AppColors.accent).frame(width: 220, height: 220)
                            @unknown default: qrPlaceholder
                            }
                        }
                    } else {
                        qrPlaceholder
                    }

                    VStack(spacing: 6) {
                        Text("Scan this QR code")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        Text("Settings > Cellular > Add eSIM Plan")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    if let esim = currentESIM, !esim.lpaCode.isEmpty {
                        VStack(spacing: 6) {
                            Text("Manual code")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                            Text(esim.lpaCode)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(AppColors.accent)
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: AppRadius.sm)
                                        .fill(AppColors.accent.opacity(0.08))
                                        .overlay(RoundedRectangle(cornerRadius: AppRadius.sm).stroke(AppColors.accent.opacity(0.2), lineWidth: 1))
                                )
                        }
                    }
                }
                .pulseCard(glow: true)
                .padding(.horizontal, AppSpacing.lg)

                Spacer()
            }
        }
    }

    private var qrPlaceholder: some View {
        VStack(spacing: 10) {
            Image(systemName: "qrcode")
                .font(.system(size: 50))
                .foregroundStyle(AppColors.textTertiary)
            Text("QR Code unavailable")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(width: 220, height: 220)
        .background(AppColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    // MARK: - Actions

    private func loadData() async {
        guard let esim = currentESIM, !esim.iccid.isEmpty else { isLoadingUsage = false; return }
        isLoadingUsage = true
        isLoadingTopUp = true
        async let u: () = loadUsage(esim.iccid)
        async let t: () = loadTopUpPackages(esim.iccid)
        await u; await t
    }

    private func loadUsage(_ iccid: String) async {
        do {
            let result = try await appState.apiService.fetchUsage(iccid: iccid)
            usage = result; isLoadingUsage = false
        } catch { isLoadingUsage = false }
    }

    private func loadTopUpPackages(_ iccid: String) async {
        do {
            let pkgs = try await appState.apiService.fetchTopUpPackages(iccid: iccid)
            topUpPackages = pkgs; isLoadingTopUp = false
        } catch { isLoadingTopUp = false }
    }

    private func suspendESIM(_ esim: ESIMOrder) async {
        actionInProgress = "Suspending..."
        do {
            _ = try await appState.apiService.suspendESIM(orderNo: esim.orderNo)
            await appState.loadDashboard()
            await loadData()
            HapticFeedback.success()
        } catch {
            topUpError = "Failed to suspend eSIM. Try again."
            appLog("Suspend failed: \(error.localizedDescription)", level: .error, category: .data)
        }
        actionInProgress = nil
    }

    private func resumeESIM(_ esim: ESIMOrder) async {
        actionInProgress = "Activating..."
        do {
            _ = try await appState.apiService.resumeESIM(orderNo: esim.orderNo)
            await appState.loadDashboard()
            await loadData()
            HapticFeedback.success()
        } catch {
            topUpError = "Failed to activate eSIM. Try again."
            appLog("Resume failed: \(error.localizedDescription)", level: .error, category: .data)
        }
        actionInProgress = nil
    }

    private func purchaseTopUp(_ pkg: TopUpPackage) async {
        guard let esim = currentESIM else { return }
        actionInProgress = "Purchasing top-up..."
        do {
            _ = try await appState.apiService.topUpESIM(iccid: esim.iccid, packageCode: pkg.packageCode)
            await loadData()
            HapticFeedback.success()
            topUpSuccess = true
        } catch {
            topUpError = "Top-up failed. Please try again."
            appLog("Top-up failed: \(error.localizedDescription)", level: .error, category: .data)
        }
        actionInProgress = nil
    }

    // MARK: - Helpers

    private func isActive(_ status: String) -> Bool {
        ESIMStatusHelper.isActive(status)
    }

    private func statusLabel(_ status: String) -> String {
        ESIMStatusHelper.label(status)
    }

    private func statusColor(_ status: String) -> Color {
        ESIMStatusHelper.color(status)
    }

    private func formatExpiry(_ raw: String) -> String {
        DateFormatHelper.formatISO(raw)
    }

    private func formatDate(_ date: Date) -> String {
        DateFormatHelper.format(date)
    }
}

#Preview {
    NavigationStack { ESIMDetailView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
