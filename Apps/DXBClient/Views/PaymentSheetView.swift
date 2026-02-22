import SwiftUI
import DXBCore

struct PaymentSheetView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let plan: Plan
    var onPurchaseComplete: ((ESIMOrder) -> Void)?

    @State private var selectedMethod: PaymentMethod = .applePay
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    enum PaymentMethod: String, CaseIterable {
        case applePay = "Apple Pay"
        case card = "Credit Card"
        case crypto = "Crypto (USDC/USDT)"

        var icon: String {
            switch self {
            case .applePay: return "apple.logo"
            case .card:     return "creditcard.fill"
            case .crypto:   return "bitcoinsign.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .applePay: return .white
            case .card:     return AppColors.info
            case .crypto:   return .orange
            }
        }
    }

    private var discountedPrice: Double {
        guard let discount = appState.subscription?.discount_percent, discount > 0 else { return plan.priceUSD }
        return plan.priceUSD * (1 - Double(discount) / 100)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppSpacing.lg) {
                        orderSummary.slideIn(delay: 0)
                        paymentMethods.slideIn(delay: 0.05)
                        purchaseButton.slideIn(delay: 0.1)
                    }
                    .padding(AppSpacing.lg)
                }

                if isPurchasing {
                    LoadingOverlay(message: "Processing payment...")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("PAYMENT")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppColors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
            }
        }
    }

    // MARK: - Order Summary

    private var orderSummary: some View {
        VStack(spacing: 14) {
            HStack {
                Text("ORDER SUMMARY")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.textTertiary)
                Spacer()
            }

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .fill(AppColors.accent)
                        .frame(width: 48, height: 48)

                    Text(countryFlag(plan.locationCode))
                        .font(.system(size: 22))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(plan.location)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    HStack(spacing: 6) {
                        Text("\(plan.dataGB) GB")
                        Text("•")
                        Text("\(plan.durationDays) days")
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
            }

            Divider().background(AppColors.border)

            HStack {
                Text("Subtotal")
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text("$\(String(format: "%.2f", plan.priceUSD))")
                    .foregroundStyle(AppColors.textPrimary)
            }
            .font(.system(size: 14))

            if let discount = appState.subscription?.discount_percent, discount > 0 {
                HStack {
                    Text("Discount (-\(discount)%)")
                        .foregroundStyle(AppColors.success)
                    Spacer()
                    Text("-$\(String(format: "%.2f", plan.priceUSD - discountedPrice))")
                        .foregroundStyle(AppColors.success)
                }
                .font(.system(size: 14))
            }

            Divider().background(AppColors.border)

            HStack {
                Text("Total")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("$\(String(format: "%.2f", discountedPrice))")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.accent)
            }
        }
        .pulseCard(glow: true)
    }

    // MARK: - Payment Methods

    private var paymentMethods: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PAYMENT METHOD")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppColors.textTertiary)

            VStack(spacing: 8) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    paymentMethodRow(method)
                }
            }
        }
    }

    private func paymentMethodRow(_ method: PaymentMethod) -> some View {
        let isSelected = selectedMethod == method
        let isDisabled = method == .crypto

        return Button {
            withAnimation(.spring(response: 0.3)) { selectedMethod = method }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(method.color.opacity(0.1))
                        .frame(width: 38, height: 38)
                    Image(systemName: method.icon)
                        .font(.system(size: 15))
                        .foregroundStyle(method.color)
                }

                Text(method.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isDisabled ? AppColors.textTertiary : AppColors.textPrimary)

                if isDisabled {
                    Text("Coming Soon")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(AppColors.warning)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.warning.opacity(0.12), in: Capsule())
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.accent : AppColors.border, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle().fill(AppColors.accent).frame(width: 10, height: 10)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(isSelected ? AppColors.surfaceSecondary : AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .stroke(isSelected ? AppColors.accent.opacity(0.3) : AppColors.border, lineWidth: 1)
                    )
            )
            .opacity(isDisabled ? 0.5 : 1)
        }
        .disabled(isDisabled)
    }

    // MARK: - Purchase

    private var purchaseButton: some View {
        VStack(spacing: 10) {
            if let error = errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(AppColors.error)
                    Text(error).font(.system(size: 13)).foregroundStyle(AppColors.textPrimary)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.sm).fill(AppColors.error.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.sm).stroke(AppColors.error.opacity(0.15), lineWidth: 1))
                )
            }

            Button { Task { await processPurchase() } } label: {
                HStack(spacing: 8) {
                    Image(systemName: selectedMethod.icon)
                    Text("Pay $\(String(format: "%.2f", discountedPrice))")
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill").font(.system(size: 10)).foregroundStyle(AppColors.success)
                Text("Secure and encrypted payment").font(.system(size: 11)).foregroundStyle(AppColors.textTertiary)
            }
        }
    }

    private func processPurchase() async {
        isPurchasing = true; errorMessage = nil
        do {
            let order = try await appState.apiService.purchasePlan(planId: plan.id)
            isPurchasing = false; onPurchaseComplete?(order); dismiss()
        } catch {
            errorMessage = "Payment failed. Please try again."; isPurchasing = false
        }
    }

    private func countryFlag(_ code: String) -> String {
        CountryHelper.flagFromCode(code)
    }
}

#Preview {
    PaymentSheetView(plan: Plan(id: "1", name: "UAE Premium", description: "30 days", dataGB: 10, durationDays: 30, priceUSD: 29.99, speed: "5G", location: "UAE", locationCode: "AE"))
        .environment(AppState())
        .preferredColorScheme(.dark)
}
