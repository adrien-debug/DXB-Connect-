import SwiftUI
import DXBCore

struct PaymentSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    let order: ESIMOrder
    var onViewESIM: (() -> Void)?
    var onBackToHome: (() -> Void)?

    @State private var checkmarkScale: CGFloat = 0
    @State private var contentOpacity: Double = 0
    @State private var confettiVisible = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            RadialGradient(
                colors: [AppColors.accent.opacity(0.08), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xxl) {
                    Spacer(minLength: AppSpacing.xxxl)

                    successIcon
                    successMessage
                    orderSummaryCard
                    installationSteps
                    actionButtons

                    Spacer(minLength: AppSpacing.xxxl)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            HapticFeedback.success()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2)) {
                checkmarkScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                contentOpacity = 1.0
            }
        }
    }

    // MARK: - Success Icon

    private var successIcon: some View {
        ZStack {
            Circle()
                .fill(AppColors.accent.opacity(0.12))
                .frame(width: 120, height: 120)
                .blur(radius: 20)

            Circle()
                .fill(AppColors.accent)
                .frame(width: 80, height: 80)

            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.black)
        }
        .scaleEffect(checkmarkScale)
    }

    // MARK: - Success Message

    private var successMessage: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Purchase Successful!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)

            Text("Your eSIM is ready to install")
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .opacity(contentOpacity)
    }

    // MARK: - Order Summary

    private var orderSummaryCard: some View {
        VStack(spacing: AppSpacing.base) {
            HStack {
                Text("ORDER DETAILS")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(AppColors.textTertiary)
                Spacer()
                StatusBadge(text: "Confirmed", color: AppColors.success)
            }

            VStack(spacing: AppSpacing.md) {
                orderRow(label: "Plan", value: order.packageName)
                orderRow(label: "Volume", value: order.totalVolume.isEmpty ? "—" : order.totalVolume)
                orderRow(label: "Order #", value: order.orderNo.isEmpty ? "—" : order.orderNo)

                if !order.iccid.isEmpty {
                    orderRow(label: "ICCID", value: String(order.iccid.prefix(10)) + "...")
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
        .opacity(contentOpacity)
    }

    private func orderRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
        }
    }

    // MARK: - Installation Steps

    private var installationSteps: some View {
        VStack(alignment: .leading, spacing: AppSpacing.base) {
            Text("INSTALLATION")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(AppColors.textTertiary)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                stepRow(number: 1, text: "Open Settings > Cellular")
                stepRow(number: 2, text: "Add an eSIM plan")
                stepRow(number: 3, text: "Scan the QR code from \"My eSIMs\"")
                stepRow(number: 4, text: "Enable data roaming")
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
        .opacity(contentOpacity)
    }

    private func stepRow(number: Int, text: String) -> some View {
        HStack(spacing: AppSpacing.md) {
            Text("\(number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 24, height: 24)
                .background(Circle().fill(AppColors.accent))

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: AppSpacing.md) {
            Button {
                HapticFeedback.medium()
                if let onViewESIM { onViewESIM() } else { dismiss() }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 16, weight: .semibold))
                    Text("View my eSIM")
                }
            }
            .buttonStyle(GoldButtonStyle())

            Button {
                if let onBackToHome { onBackToHome() } else { dismiss() }
            } label: {
                Text("Back to Home")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
            }
        }
        .opacity(contentOpacity)
    }
}

#Preview {
    PaymentSuccessView(
        order: ESIMOrder(
            id: "1", orderNo: "ORD-123456", iccid: "8901234567890123456",
            lpaCode: "LPA:1$example.com$ABC123", qrCodeUrl: "",
            status: "RELEASED", packageName: "France 5GB",
            totalVolume: "5 GB", expiredTime: "2025-12-31", createdAt: Date()
        )
    )
    .preferredColorScheme(.dark)
}
