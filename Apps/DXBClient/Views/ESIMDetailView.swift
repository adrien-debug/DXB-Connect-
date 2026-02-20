import SwiftUI
import DXBCore

struct ESIMDetailView: View {
    let order: ESIMOrder
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showCopiedToast = false
    @State private var copiedText = ""
    @State private var showTopUp = false
    @State private var showCancelConfirm = false
    @State private var showSuspendConfirm = false
    @State private var actionInProgress = false
    @State private var actionResult: String?

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingRadius = AppTheme.Banking.Radius
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return BankingColors.accentDark
        case "EXPIRED": return BankingColors.textOnLightMuted
        default: return Color.orange
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

    private var isPaymentConfirmed: Bool {
        let statusesWithQR = ["RELEASED", "IN_USE", "SUSPENDED", "EXPIRED", "GOT_RESOURCE"]
        let status = order.status.uppercased()
        return statusesWithQR.contains(status) && !order.qrCodeUrl.isEmpty
    }

    var body: some View {
        ZStack {
            BankingColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(BankingTypo.button())
                            .foregroundColor(BankingColors.textOnDarkPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(BankingColors.backgroundTertiary))
                    }

                    Spacer()

                    Text("ESIM DETAILS")
                        .font(BankingTypo.label())
                        .tracking(1.5)
                        .foregroundColor(BankingColors.textOnDarkMuted)

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, BankingSpacing.lg)
                .padding(.top, BankingSpacing.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: BankingSpacing.lg) {
                        if isPaymentConfirmed {
                            qrCodeSection
                        } else {
                            pendingPaymentSection
                        }

                        packageInfoSection
                        usageSection
                        technicalInfoSection

                        if isPaymentConfirmed {
                            manageSection
                            installationGuideSection
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .task {
                await coordinator.loadUsage(for: order)
            }

            if showCopiedToast {
                VStack {
                    Spacer()

                    HStack(spacing: BankingSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(BankingTypo.body())
                        Text("\(copiedText) copied")
                            .font(BankingTypo.button())
                    }
                    .foregroundColor(BankingColors.backgroundPrimary)
                    .padding(.horizontal, BankingSpacing.lg)
                    .padding(.vertical, BankingSpacing.md)
                    .background(
                        Capsule()
                            .fill(BankingColors.accent)
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showTopUp) {
            TopUpSheet(order: order)
                .environmentObject(coordinator)
        }
        .alert("Cancel Order", isPresented: $showCancelConfirm) {
            Button("Keep Order", role: .cancel) {}
            Button("Cancel Order", role: .destructive) {
                Task {
                    actionInProgress = true
                    let success = await coordinator.cancelOrder(order)
                    actionInProgress = false
                    if success { dismiss() }
                }
            }
        } message: {
            Text("This order will be cancelled. This action cannot be undone.")
        }
        .alert(isSuspended ? "Resume eSIM" : "Suspend eSIM", isPresented: $showSuspendConfirm) {
            Button("Cancel", role: .cancel) {}
            Button(isSuspended ? "Resume" : "Suspend") {
                Task {
                    actionInProgress = true
                    if isSuspended {
                        _ = await coordinator.resumeESIM(order)
                    } else {
                        _ = await coordinator.suspendESIM(order)
                    }
                    actionInProgress = false
                }
            }
        } message: {
            Text(isSuspended
                 ? "Your eSIM will be reactivated."
                 : "Your eSIM will be temporarily suspended. You can resume it later.")
        }
    }

    private var isActive: Bool {
        let s = order.status.uppercased()
        return s == "RELEASED" || s == "IN_USE" || s == "ENABLED"
    }

    private var isSuspended: Bool {
        order.status.uppercased() == "SUSPENDED"
    }

    // MARK: - Manage Section

    private var manageSection: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.md) {
            Text("Manage")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            VStack(spacing: BankingSpacing.sm) {
                if isActive {
                    Button {
                        showTopUp = true
                    } label: {
                        HStack(spacing: BankingSpacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Top Up Data")
                                .font(BankingTypo.button())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(BankingColors.backgroundPrimary)
                        .padding(.horizontal, BankingSpacing.lg)
                        .padding(.vertical, BankingSpacing.base)
                        .background(
                            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                                .fill(BankingColors.accent)
                        )
                    }
                    .scaleOnPress()

                    Button {
                        showSuspendConfirm = true
                    } label: {
                        HStack(spacing: BankingSpacing.sm) {
                            Image(systemName: "pause.circle")
                                .font(.system(size: 18))
                            Text("Suspend eSIM")
                                .font(BankingTypo.button())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(BankingColors.textOnDarkPrimary)
                        .padding(.horizontal, BankingSpacing.lg)
                        .padding(.vertical, BankingSpacing.base)
                        .background(
                            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                                .fill(BankingColors.backgroundTertiary)
                        )
                    }
                }

                if isSuspended {
                    Button {
                        showSuspendConfirm = true
                    } label: {
                        HStack(spacing: BankingSpacing.sm) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 18))
                            Text("Resume eSIM")
                                .font(BankingTypo.button())
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(BankingColors.backgroundPrimary)
                        .padding(.horizontal, BankingSpacing.lg)
                        .padding(.vertical, BankingSpacing.base)
                        .background(
                            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                                .fill(BankingColors.accent)
                        )
                    }
                    .scaleOnPress()
                }

                Button {
                    showCancelConfirm = true
                } label: {
                    HStack(spacing: BankingSpacing.sm) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 18))
                        Text("Cancel Order")
                            .font(BankingTypo.button())
                        Spacer()
                    }
                    .foregroundColor(AppTheme.error)
                    .padding(.horizontal, BankingSpacing.lg)
                    .padding(.vertical, BankingSpacing.base)
                    .background(
                        RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                            .fill(AppTheme.error.opacity(0.08))
                    )
                }
            }
        }
        .padding(BankingSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.backgroundSecondary)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
        )
        .padding(.horizontal, BankingSpacing.lg)
        .slideIn(delay: 0.18)
    }

    // MARK: - Pending Payment

    private var pendingPaymentSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)

                Text("PROCESSING")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.orange.opacity(0.15)))

            ZStack {
                RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                    .fill(BankingColors.backgroundTertiary)
                    .frame(width: 200, height: 200)

                VStack(spacing: BankingSpacing.md) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.orange)

                    Text("Payment Processing")
                        .font(BankingTypo.button())
                        .foregroundColor(BankingColors.textOnDarkPrimary)

                    Text("Your QR code will appear\nonce payment is confirmed")
                        .font(BankingTypo.caption())
                        .foregroundColor(BankingColors.textOnDarkMuted)
                        .multilineTextAlignment(.center)
                }
            }

            Text("This usually takes a few seconds")
                .font(BankingTypo.caption())
                .foregroundColor(BankingColors.textOnDarkMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, BankingSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.backgroundSecondary)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
        )
        .padding(.horizontal, BankingSpacing.lg)
        .padding(.top, BankingSpacing.base)
        .slideIn(delay: 0)
    }

    // MARK: - QR Code

    private var qrCodeSection: some View {
        VStack(spacing: 24) {
            qrStatusBadge
            qrCodeDisplay
            qrInstructions
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(qrBackground)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .slideIn(delay: 0)
    }

    private var qrStatusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Capsule().fill(statusColor.opacity(0.1)))
    }

    private var qrCodeDisplay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(Color.white)
                .frame(width: 250, height: 250)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)

            qrImageLoader
            qrCornerAccents
        }
    }

    private var qrImageLoader: some View {
        AsyncImage(url: URL(string: order.qrCodeUrl)) { image in
            ZStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(BankingRadius.chartBar)))
                AnimatedScanLine(color: BankingColors.accent, height: 2)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(BankingRadius.chartBar)))
            }
        } placeholder: {
            VStack(spacing: BankingSpacing.md) {
                ProgressView().tint(BankingColors.accent)
                Text("Loading QR...")
                    .font(BankingTypo.caption())
                    .foregroundColor(BankingColors.textOnDarkMuted)
            }
        }
    }

    private var qrCornerAccents: some View {
        Group {
            singleCorner(0)
            singleCorner(1)
            singleCorner(2)
            singleCorner(3)
        }
    }

    private func singleCorner(_ corner: Int) -> some View {
        let xOff: CGFloat = (corner == 0 || corner == 2) ? -110 : 110
        let yOff: CGFloat = (corner == 0 || corner == 1) ? -110 : 110
        return CornerShape(corner: corner, length: 24)
            .stroke(BankingColors.accent, lineWidth: 3)
            .frame(width: 30, height: 30)
            .offset(x: xOff, y: yOff)
    }

    private var qrInstructions: some View {
        VStack(spacing: BankingSpacing.sm) {
            Text("Scan to install")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnDarkPrimary)
            Text("Open your Camera app and\npoint at the QR code")
                .font(BankingTypo.body())
                .foregroundColor(BankingColors.textOnDarkMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    private var qrBackground: some View {
        RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
            .fill(BankingColors.backgroundSecondary)
            .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
    }

    // MARK: - Package Info

    private var packageInfoSection: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.lg) {
            Text("Package details")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            HStack(spacing: BankingSpacing.md) {
                Circle()
                    .fill(BankingColors.surfaceMedium)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "simcard.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(BankingColors.accentDark)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.packageName)
                        .font(BankingTypo.body())
                        .foregroundColor(BankingColors.textOnLightPrimary)

                    Text(order.totalVolume)
                        .font(BankingTypo.caption())
                        .foregroundColor(BankingColors.textOnLightMuted)
                }

                Spacer()
            }

            HStack(spacing: BankingSpacing.sm) {
                InfoMiniCard(label: "Expires", value: formatDate(order.expiredTime))
                InfoMiniCard(label: "Order", value: "#\(String(order.orderNo.suffix(6)))")
            }
        }
        .padding(BankingSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.surfaceLight)
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .slideIn(delay: 0.1)
    }

    // MARK: - Usage

    private var currentUsage: (percentage: Double, used: String, total: String, remaining: String) {
        if let display = coordinator.usageDisplay(for: order) {
            let pct = coordinator.usagePercentage(for: order)
            return (pct, display.used, display.total, display.remaining)
        }
        return (0, "—", order.totalVolume, order.totalVolume)
    }

    private var usageSection: some View {
        let usage = currentUsage

        return VStack(alignment: .leading, spacing: BankingSpacing.base) {
            Text("Data usage")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnLightPrimary)

            HStack(spacing: BankingSpacing.xl) {
                RadialGauge(
                    progress: usage.percentage,
                    size: 80,
                    trackColor: BankingColors.surfaceMedium,
                    fillColor: BankingColors.accent,
                    lineWidth: 6,
                    valueText: "\(Int(usage.percentage * 100))",
                    unitText: "%"
                )

                VStack(alignment: .leading, spacing: BankingSpacing.md) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Used")
                            .font(BankingTypo.caption())
                            .foregroundColor(BankingColors.textOnLightMuted)
                        Text(usage.used)
                            .font(BankingTypo.body())
                            .foregroundColor(BankingColors.textOnLightPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining")
                            .font(BankingTypo.caption())
                            .foregroundColor(BankingColors.textOnLightMuted)
                        Text(usage.remaining)
                            .font(BankingTypo.body())
                            .foregroundColor(BankingColors.accentDark)
                    }
                }

                Spacer()
            }
        }
        .padding(BankingSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.surfaceLight)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
        )
        .padding(.horizontal, BankingSpacing.lg)
        .slideIn(delay: 0.12)
    }

    // MARK: - Technical Info

    private var technicalInfoSection: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.lg) {
            Text("Technical info")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            VStack(spacing: 0) {
                TechInfoRow(label: "ICCID", value: order.iccid) {
                    copyToClipboard(order.iccid, label: "ICCID")
                }

                Rectangle()
                    .fill(BankingColors.borderDark)
                    .frame(height: 0.5)
                    .padding(.leading, BankingSpacing.base)

                TechInfoRow(label: "LPA Code", value: order.lpaCode) {
                    copyToClipboard(order.lpaCode, label: "LPA Code")
                }

                Rectangle()
                    .fill(BankingColors.borderDark)
                    .frame(height: 0.5)
                    .padding(.leading, BankingSpacing.base)

                TechInfoRow(label: "Order No", value: order.orderNo) {
                    copyToClipboard(order.orderNo, label: "Order No")
                }
            }
            .background(
                RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                    .fill(BankingColors.backgroundTertiary)
            )
        }
        .padding(BankingSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.backgroundSecondary)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
        )
        .padding(.horizontal, BankingSpacing.lg)
        .slideIn(delay: 0.15)
    }

    // MARK: - Installation Guide

    private var installationGuideSection: some View {
        VStack(alignment: .leading, spacing: BankingSpacing.lg) {
            Text("How to install")
                .font(BankingTypo.sectionTitle())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            VStack(spacing: BankingSpacing.base) {
                InstallStepTech(number: 1, text: "Go to Settings → Cellular")
                InstallStepTech(number: 2, text: "Tap 'Add eSIM' or 'Add Cellular Plan'")
                InstallStepTech(number: 3, text: "Scan the QR code above")
                InstallStepTech(number: 4, text: "Follow the on-screen instructions")
            }
        }
        .padding(BankingSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                .fill(BankingColors.backgroundSecondary)
                .shadow(color: AppTheme.Banking.Shadow.card.color, radius: AppTheme.Banking.Shadow.card.radius, x: AppTheme.Banking.Shadow.card.x, y: AppTheme.Banking.Shadow.card.y)
        )
        .padding(.horizontal, BankingSpacing.lg)
        .slideIn(delay: 0.2)
    }

    private func copyToClipboard(_ value: String, label: String) {
        UIPasteboard.general.string = value
        HapticFeedback.light()
        copiedText = label
        withAnimation(.spring(response: 0.3)) {
            showCopiedToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.3)) {
                showCopiedToast = false
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        if dateString.isEmpty { return "N/A" }
        if dateString.count >= 10 {
            return String(dateString.prefix(10))
        }
        return dateString
    }
}

// MARK: - Top-Up Sheet

struct TopUpSheet: View {
    let order: ESIMOrder
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var packages: [TopUpPackage] = []
    @State private var isLoading = true
    @State private var selectedPackage: TopUpPackage?
    @State private var isPurchasing = false
    @State private var purchaseSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Banking.Colors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(AppTheme.Typography.tabLabel())
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(AppTheme.gray100))
                        }
                        Spacer()
                        Text("TOP UP")
                            .font(AppTheme.Typography.navTitle())
                            .tracking(1.5)
                            .foregroundColor(AppTheme.textSecondary)
                        Spacer()
                        Color.clear.frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    if isLoading {
                        Spacer()
                        ProgressView()
                            .tint(AppTheme.accent)
                        Spacer()
                    } else if packages.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                            Text("No top-up packages available")
                                .font(AppTheme.Typography.bodyMedium())
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Try again later")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    } else if purchaseSuccess {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 56, weight: .medium))
                                .foregroundColor(AppTheme.success)
                            Text("Top-Up Successful!")
                                .font(AppTheme.Typography.cardTitle())
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Your data has been added")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .font(AppTheme.Typography.buttonMedium())
                                    .foregroundColor(AppTheme.anthracite)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.accent))
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 8)
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 12) {
                                ForEach(packages) { pkg in
                                    Button {
                                        HapticFeedback.selection()
                                        selectedPackage = pkg
                                    } label: {
                                        HStack(spacing: 14) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(pkg.name)
                                                    .font(AppTheme.Typography.bodyMedium())
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text("\(pkg.dataGB) GB · \(pkg.durationDays) days")
                                                    .font(AppTheme.Typography.captionMedium())
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            Spacer()
                                            Text(pkg.priceUSD.formattedPrice)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(AppTheme.accent)
                                        }
                                        .padding(18)
                                        .background(
                                            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                                .fill(AppTheme.backgroundPrimary)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                                        .stroke(
                                                            selectedPackage?.id == pkg.id
                                                                ? AppTheme.accent
                                                                : AppTheme.border.opacity(0.4),
                                                            lineWidth: selectedPackage?.id == pkg.id ? 2 : 0.5
                                                        )
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, 100)
                        }

                        if let selected = selectedPackage {
                            VStack(spacing: 0) {
                                Button {
                                    Task {
                                        isPurchasing = true
                                        let success = await coordinator.performTopUp(
                                            for: order,
                                            packageCode: selected.packageCode
                                        )
                                        isPurchasing = false
                                        if success {
                                            HapticFeedback.success()
                                            withAnimation { purchaseSuccess = true }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        if isPurchasing {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.anthracite))
                                                .scaleEffect(0.8)
                                        } else {
                                            Text("Top Up for \(selected.priceUSD.formattedPrice)")
                                                .font(AppTheme.Typography.bodyMedium())
                                        }
                                    }
                                    .foregroundColor(AppTheme.anthracite)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                            .fill(AppTheme.accent)
                                    )
                                }
                                .disabled(isPurchasing)
                                .scaleOnPress()
                                .padding(.horizontal, 20)
                                .padding(.bottom, 34)
                            }
                            .background(
                                AppTheme.backgroundPrimary
                                    .shadow(color: Color.black.opacity(0.08), radius: 10, y: -4)
                            )
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            packages = await coordinator.fetchTopUpPackages(for: order)
            isLoading = false
        }
    }
}

// MARK: - Info Mini Card

struct InfoMiniCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppTheme.Typography.navTitle())
                .foregroundColor(AppTheme.textTertiary)

            Text(value)
                .font(AppTheme.Typography.buttonMedium())
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.backgroundTertiary)
        )
    }
}

// MARK: - Tech Info Row

struct TechInfoRow: View {
    let label: String
    let value: String
    let onCopy: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(AppTheme.textTertiary)

                Text(value)
                    .font(AppTheme.Typography.captionMedium())
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(AppTheme.Typography.tabLabel())
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppTheme.accent.opacity(0.1))
                    )
            }
        }
        .padding(14)
    }
}

// MARK: - Install Step

struct InstallStepTech: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.12))
                    .frame(width: 36, height: 36)

                Text("\(number)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.accent)
            }

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Legacy Compatibility

struct DetailRow: View {
    let label: String
    let value: String
    var copyable: Bool = false

    var body: some View {
        HStack {
            Text(label).foregroundColor(AppTheme.textTertiary)
            Spacer()
            Text(value).foregroundColor(AppTheme.textPrimary)
            if copyable {
                Button {
                    UIPasteboard.general.string = value
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

struct InstallStep: View {
    let number: Int
    let text: String
    var body: some View { InstallStepTech(number: number, text: text) }
}

#Preview {
    NavigationStack {
        ESIMDetailView(order: ESIMOrder(
            id: "123",
            orderNo: "ORD123456",
            iccid: "8901234567890123456",
            lpaCode: "LPA:1$example.com$123",
            qrCodeUrl: "https://example.com/qr.png",
            status: "RELEASED",
            packageName: "Dubai 5GB - 7 Days",
            totalVolume: "5 GB",
            expiredTime: "2024-12-31",
            createdAt: Date()
        ))
        .environmentObject(AppCoordinator())
    }
}
