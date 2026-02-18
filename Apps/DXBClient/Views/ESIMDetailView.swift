import SwiftUI
import DXBCore

struct ESIMDetailView: View {
    let order: ESIMOrder
    @Environment(\.dismiss) private var dismiss
    @State private var showCopiedToast = false
    @State private var copiedText = ""

    private var statusColor: Color {
        switch order.status.uppercased() {
        case "RELEASED", "IN_USE": return AppTheme.textPrimary
        case "EXPIRED": return AppTheme.gray400
        default: return AppTheme.gray500
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

    // MARK: - Computed Properties
    
    private var isPaymentConfirmed: Bool {
        // ✅ RÈGLE : QR Code visible UNIQUEMENT si paiement confirmé
        // Statuts confirmés : RELEASED, IN_USE, SUSPENDED
        // Statuts en attente : PENDING, PENDING_PAYMENT, PROCESSING
        let confirmedStatuses = ["RELEASED", "IN_USE", "SUSPENDED", "EXPIRED"]
        return confirmedStatuses.contains(order.status.uppercased())
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Nav Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }

                    Spacer()

                    Text("ESIM DETAILS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // QR Code Card - UNIQUEMENT si paiement confirmé
                        if isPaymentConfirmed {
                            qrCodeSection
                        } else {
                            pendingPaymentSection
                        }
                        
                        // Package Info (toujours visible)
                        packageInfoSection
                        
                        // Technical Info (toujours visible)
                        technicalInfoSection
                        
                        // Installation Guide - UNIQUEMENT si paiement confirmé
                        if isPaymentConfirmed {
                            installationGuideSection
                        }

                        Spacer(minLength: 40)
                    }
                }
            }

            // Toast
            if showCopiedToast {
                VStack {
                    Spacer()

                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("\(copiedText) copied")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(AppTheme.textPrimary)
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Pending Payment Section
    
    private var pendingPaymentSection: some View {
        VStack(spacing: 20) {
            // Status Badge
            HStack(spacing: 6) {
                Circle()
                    .fill(AppTheme.gray400)
                    .frame(width: 8, height: 8)

                Text("PENDING PAYMENT")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundColor(AppTheme.gray400)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AppTheme.gray400.opacity(0.1))
            )

            // Pending Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.gray50)
                    .frame(width: 200, height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )

                VStack(spacing: 16) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(AppTheme.textTertiary)
                    
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
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.gray50)
        )
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .slideIn(delay: 0)
    }
    
    // MARK: - QR Code Section
    
    private var qrCodeSection: some View {
        VStack(spacing: 20) {
            // Status Badge
            HStack(spacing: 6) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)

                Text(statusText)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.1))
            )

            // QR Code
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppTheme.surfaceLight)
                    .frame(width: 200, height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )

                AsyncImage(url: URL(string: order.qrCodeUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                } placeholder: {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(AppTheme.textPrimary)
                        Text("Loading QR...")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
            }

            Text("Scan to install eSIM")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.gray50)
        )
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .slideIn(delay: 0)
    }
    
    // MARK: - Package Info Section
    
    private var packageInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
                            Text("PACKAGE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)

                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppTheme.textPrimary)
                                        .frame(width: 52, height: 52)

                                    Image(systemName: "simcard.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(order.packageName)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Text(order.totalVolume)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textTertiary)
                                }

                                Spacer()
                            }

                            // Info Grid
                            HStack(spacing: 12) {
                                InfoMiniCard(label: "EXPIRES", value: formatDate(order.expiredTime))
                                InfoMiniCard(label: "ORDER", value: "#\(String(order.orderNo.suffix(6)))")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppTheme.surfaceLight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 24)
                        .slideIn(delay: 0.1)
    }
    
    // MARK: - Technical Info Section
    
    private var technicalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
                            Text("TECHNICAL INFO")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)

                            VStack(spacing: 0) {
                                TechInfoRow(label: "ICCID", value: order.iccid) {
                                    copyToClipboard(order.iccid, label: "ICCID")
                                }

                                Divider()
                                    .padding(.leading, 16)

                                TechInfoRow(label: "LPA Code", value: order.lpaCode) {
                                    copyToClipboard(order.lpaCode, label: "LPA Code")
                                }

                                Divider()
                                    .padding(.leading, 16)

                                TechInfoRow(label: "Order No", value: order.orderNo) {
                                    copyToClipboard(order.orderNo, label: "Order No")
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.gray50)
                            )
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppTheme.surfaceLight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 24)
                        .slideIn(delay: 0.15)
    }
    
    // MARK: - Installation Guide Section
    
    private var installationGuideSection: some View {
        VStack(alignment: .leading, spacing: 16) {
                            Text("INSTALLATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)

                            VStack(spacing: 18) {
                                InstallStepTech(number: 1, text: "Go to Settings → Cellular")
                                InstallStepTech(number: 2, text: "Tap 'Add eSIM' or 'Add Cellular Plan'")
                                InstallStepTech(number: 3, text: "Scan the QR code above")
                                InstallStepTech(number: 4, text: "Follow the on-screen instructions")
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppTheme.surfaceLight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 24)
                        .slideIn(delay: 0.2)
    }

    private func copyToClipboard(_ value: String, label: String) {
        UIPasteboard.general.string = value
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
        // Simple format - just return first 10 chars if it's a date string
        if dateString.count >= 10 {
            return String(dateString.prefix(10))
        }
        return dateString
    }
}

// MARK: - Info Mini Card

struct InfoMiniCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
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
                .fill(AppTheme.gray50)
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
            VStack(alignment: .leading, spacing: 4) {
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
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(16)
    }
}

// MARK: - Install Step Tech

struct InstallStepTech: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.textPrimary)
                    .frame(width: 28, height: 28)

                Text("\(number)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Legacy Components (compatibility)

struct DetailRow: View {
    let label: String
    let value: String
    var copyable: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(AppTheme.textTertiary)
            Spacer()
            Text(value)
                .foregroundColor(AppTheme.textPrimary)
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

    var body: some View {
        InstallStepTech(number: number, text: text)
    }
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
    }
}
