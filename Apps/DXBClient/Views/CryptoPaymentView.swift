import SwiftUI
import DXBCore

struct CryptoPaymentView: View {
    let amountUSD: Double
    let onComplete: () -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var depositAddress = ""
    @State private var asset = "USDC_POLYGON"
    @State private var invoiceId = ""
    @State private var status = "pending"
    @State private var expiresAt: Date?
    @State private var isLoading = true
    @State private var error: String?
    @State private var pollTask: Task<Void, Never>?

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    var body: some View {
        ZStack {
            BankingColors.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: BankingSpacing.xl) {
                headerSection

                if isLoading {
                    ProgressView("Creating invoice...")
                        .tint(BankingColors.accent)
                        .foregroundColor(BankingColors.textOnDarkMuted)
                        .padding(.top, 40)
                } else if let error = error {
                    errorView(error)
                } else {
                    invoiceContent
                }

                Spacer()

                Button {
                    cleanup()
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(BankingTypo.button())
                        .foregroundColor(BankingColors.textOnDarkMuted)
                }
                .padding(.bottom, 30)
            }
        }
        .task { await createInvoice() }
        .onDisappear { cleanup() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: BankingSpacing.sm) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(BankingColors.accent)

            Text("Pay with Crypto")
                .font(BankingTypo.detailAmount())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            Text(String(format: "$%.2f", amountUSD))
                .font(BankingTypo.heroAmount())
                .foregroundColor(BankingColors.textOnDarkPrimary)
        }
        .padding(.top, BankingSpacing.xxl)
    }

    // MARK: - Invoice Content

    private var invoiceContent: some View {
        VStack(spacing: 20) {
            // Status
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text(statusText)
                    .font(AppTheme.Typography.buttonMedium())
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(statusColor.opacity(0.1)))

            // Asset info
            HStack {
                Text("Asset")
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Text(assetLabel)
                    .font(AppTheme.Typography.buttonMedium())
                    .foregroundColor(AppTheme.textPrimary)
            }
            .padding(.horizontal, 20)

            // Address
            VStack(alignment: .leading, spacing: 8) {
                Text("Send to this address:")
                    .font(AppTheme.Typography.captionMedium())
                    .foregroundColor(AppTheme.textSecondary)

                Text(depositAddress)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.gray100)
                    )

                Button {
                    UIPasteboard.general.string = depositAddress
                    HapticFeedback.success()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13))
                        Text("Copy Address")
                            .font(AppTheme.Typography.tabLabel())
                    }
                    .foregroundColor(AppTheme.accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.accent.opacity(0.1))
                    )
                }
            }
            .padding(.horizontal, 20)

            // Expiry
            if let expires = expiresAt {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                    Text("Expires: \(expires, style: .relative)")
                        .font(AppTheme.Typography.captionMedium())
                }
                .foregroundColor(AppTheme.warning)
            }
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.error)
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    // MARK: - Helpers

    private var assetLabel: String {
        switch asset {
        case "USDC_POLYGON": return "USDC (Polygon)"
        case "USDT_POLYGON": return "USDT (Polygon)"
        case "USDC_ETH": return "USDC (Ethereum)"
        case "ETH": return "ETH"
        default: return asset
        }
    }

    private var statusColor: Color {
        switch status {
        case "confirmed": return AppTheme.success
        case "expired", "failed": return AppTheme.error
        default: return AppTheme.warning
        }
    }

    private var statusText: String {
        switch status {
        case "pending": return "Awaiting payment..."
        case "detected": return "Payment detected"
        case "confirmed": return "Payment confirmed!"
        case "expired": return "Invoice expired"
        case "failed": return "Payment failed"
        default: return status
        }
    }

    // MARK: - Network

    private func createInvoice() async {
        isLoading = true
        error = nil
        do {
            let response = try await coordinator.currentAPIService.createCryptoInvoice(
                amountUSD: amountUSD,
                asset: asset
            )
            invoiceId = response.id ?? ""
            depositAddress = response.deposit_address ?? ""
            status = response.status ?? "pending"

            if let expiresStr = response.expires_at {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                expiresAt = formatter.date(from: expiresStr)
            }

            isLoading = false
            startPolling()
        } catch {
            isLoading = false
            self.error = "Failed to create invoice. Please try again."
        }
    }

    private func startPolling() {
        pollTask = Task {
            while !Task.isCancelled && status != "confirmed" && status != "expired" && status != "failed" {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { return }

                do {
                    let response = try await coordinator.currentAPIService.pollCryptoInvoice(invoiceId: invoiceId)
                    await MainActor.run {
                        status = response.status ?? status
                        if status == "confirmed" {
                            HapticFeedback.success()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onComplete()
                            }
                        }
                    }
                } catch {
                    // Silently retry
                }
            }
        }
    }

    private func cleanup() {
        pollTask?.cancel()
        pollTask = nil
    }
}

#Preview {
    CryptoPaymentView(amountUSD: 9.99, onComplete: {}, onCancel: {})
        .environmentObject(AppCoordinator())
}
