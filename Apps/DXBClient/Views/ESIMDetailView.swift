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

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.success
        case "EXPIRED": return AppTheme.textSecondary
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
            AppTheme.backgroundSecondary
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
                            .background(Circle().fill(AppTheme.gray100))
                    }

                    Spacer()

                    Text("ESIM DETAILS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
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

                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("\(copiedText) copied")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "0F172A"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(AppTheme.accent)
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
        VStack(alignment: .leading, spacing: 14) {
            Text("Manage")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 10) {
                if isActive {
                    Button {
                        showTopUp = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                            Text("Top Up Data")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "0F172A"))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.accent)
                        )
                    }
                    .scaleOnPress()

                    Button {
                        showSuspendConfirm = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "pause.circle")
                                .font(.system(size: 18))
                            Text("Suspend eSIM")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.textPrimary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.backgroundTertiary)
                        )
                    }
                }

                if isSuspended {
                    Button {
                        showSuspendConfirm = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 18))
                            Text("Resume eSIM")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "0F172A"))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.accent)
                        )
                    }
                    .scaleOnPress()
                }

                Button {
                    showCancelConfirm = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 18))
                        Text("Cancel Order")
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                    }
                    .foregroundColor(AppTheme.error)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.error.opacity(0.08))
                    )
                }
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
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
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.gray100)
                    .frame(width: 200, height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )

                VStack(spacing: 14) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.orange)

                    Text("Payment Processing")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text("Your QR code will appear\nonce payment is confirmed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
            }

            Text("This usually takes a few seconds")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppTheme.border, lineWidth: 1))
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .slideIn(delay: 0)
    }

    // MARK: - QR Code

    private var qrCodeSection: some View {
        VStack(spacing: 24) {
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

            // QR code with decorative frame + animated scan line
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .frame(width: 250, height: 250)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)

                AsyncImage(url: URL(string: order.qrCodeUrl)) { image in
                    ZStack {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        // Animated scan line overlay
                        AnimatedScanLine(color: AppTheme.accent, height: 2)
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                } placeholder: {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(AppTheme.accent)
                        Text("Loading QR...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }

                // Corner accents
                ForEach(0..<4, id: \.self) { corner in
                    CornerShape(corner: corner, length: 24)
                        .stroke(AppTheme.accent, lineWidth: 3)
                        .frame(width: 30, height: 30)
                        .offset(
                            x: (corner == 0 || corner == 2) ? -110 : 110,
                            y: (corner == 0 || corner == 1) ? -110 : 110
                        )
                }
            }

            VStack(spacing: 8) {
                Text("Scan to install")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Open your Camera app and\npoint at the QR code")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .slideIn(delay: 0)
    }

    // MARK: - Package Info

    private var packageInfoSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Package details")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: 14) {
                Circle()
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "simcard.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.packageName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(order.totalVolume)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                InfoMiniCard(label: "Expires", value: formatDate(order.expiredTime))
                InfoMiniCard(label: "Order", value: "#\(String(order.orderNo.suffix(6)))")
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
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

        return VStack(alignment: .leading, spacing: 16) {
            Text("Data usage")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: 24) {
                RadialGauge(
                    progress: usage.percentage,
                    size: 80,
                    trackColor: AppTheme.backgroundTertiary,
                    fillColor: AppTheme.accent,
                    lineWidth: 6,
                    valueText: "\(Int(usage.percentage * 100))",
                    unitText: "%"
                )

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Used")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                        Text(usage.used)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                        Text(usage.remaining)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.accent)
                    }
                }

                Spacer()
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .slideIn(delay: 0.12)
    }

    // MARK: - Technical Info

    private var technicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Technical info")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 0) {
                TechInfoRow(label: "ICCID", value: order.iccid) {
                    copyToClipboard(order.iccid, label: "ICCID")
                }

                Rectangle()
                    .fill(AppTheme.border.opacity(0.5))
                    .frame(height: 0.5)
                    .padding(.leading, 16)

                TechInfoRow(label: "LPA Code", value: order.lpaCode) {
                    copyToClipboard(order.lpaCode, label: "LPA Code")
                }

                Rectangle()
                    .fill(AppTheme.border.opacity(0.5))
                    .frame(height: 0.5)
                    .padding(.leading, 16)

                TechInfoRow(label: "Order No", value: order.orderNo) {
                    copyToClipboard(order.orderNo, label: "Order No")
                }
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.backgroundTertiary)

                    // Tech grid pattern background
                    TechGridPattern(dotSize: 2, spacing: 16, color: AppTheme.anthracite, opacity: 0.03)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            )
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .slideIn(delay: 0.15)
    }

    // MARK: - Installation Guide

    private var installationGuideSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("How to install")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 16) {
                InstallStepTech(number: 1, text: "Go to Settings → Cellular")
                InstallStepTech(number: 2, text: "Tap 'Add eSIM' or 'Add Cellular Plan'")
                InstallStepTech(number: 3, text: "Scan the QR code above")
                InstallStepTech(number: 4, text: "Follow the on-screen instructions")
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
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
                AppTheme.backgroundSecondary.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(AppTheme.gray100))
                        }
                        Spacer()
                        Text("TOP UP")
                            .font(.system(size: 12, weight: .bold))
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
                                .font(.system(size: 16, weight: .semibold))
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
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Your data has been added")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondary)
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(hex: "0F172A"))
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
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(AppTheme.textPrimary)
                                                Text("\(pkg.dataGB) GB · \(pkg.durationDays) days")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(AppTheme.textSecondary)
                                            }
                                            Spacer()
                                            Text(pkg.priceUSD.formattedPrice)
                                                .font(.system(size: 17, weight: .bold))
                                                .foregroundColor(AppTheme.accent)
                                        }
                                        .padding(18)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(AppTheme.backgroundPrimary)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
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
                                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "0F172A")))
                                                .scaleEffect(0.8)
                                        } else {
                                            Text("Top Up for \(selected.priceUSD.formattedPrice)")
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                    }
                                    .foregroundColor(Color(hex: "0F172A"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
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
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)

            Text(value)
                .font(.system(size: 15, weight: .semibold))
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
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onCopy) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .medium))
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
