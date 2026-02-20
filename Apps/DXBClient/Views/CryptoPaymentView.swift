import SwiftUI
import DXBCore

struct CryptoPaymentView: View {
    let amountUSD: Double
    let onComplete: () -> Void
    let onCancel: () -> Void

    @State private var depositAddress = ""
    @State private var asset = "USDC_POLYGON"
    @State private var invoiceId = ""
    @State private var status = "pending"
    @State private var expiresAt: Date?
    @State private var isLoading = true
    @State private var error: String?
    @State private var pollTimer: Timer?

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 24) {
                headerSection

                if isLoading {
                    ProgressView("Creating invoice...")
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
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.bottom, 30)
            }
        }
        .task { await createInvoice() }
        .onDisappear { cleanup() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(AppTheme.accent)

            Text("Pay with Crypto")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text(String(format: "$%.2f", amountUSD))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding(.top, 32)
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
                    .font(.system(size: 15, weight: .semibold))
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
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }
            .padding(.horizontal, 20)

            // Address
            VStack(alignment: .leading, spacing: 8) {
                Text("Send to this address:")
                    .font(.system(size: 13, weight: .medium))
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
                            .font(.system(size: 14, weight: .semibold))
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
                        .font(.system(size: 13, weight: .medium))
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
        // TODO: Appeler Railway via DXBAPIService.createCryptoInvoice(amountUSD:asset:)
        // Pour l'instant, placeholder — sera branché quand les méthodes API seront ajoutées
        isLoading = false
        error = "Crypto payments coming soon"
    }

    private func cleanup() {
        pollTimer?.invalidate()
        pollTimer = nil
    }
}

#Preview {
    CryptoPaymentView(amountUSD: 9.99, onComplete: {}, onCancel: {})
}
