import SwiftUI
import PassKit
import DXBCore

// MARK: - Payment Sheet View

struct PaymentSheetView: View {
    let plan: Plan
    let onSuccess: () -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = PaymentSheetViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showCryptoPayment = false

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingRadius = AppTheme.Banking.Radius
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    var body: some View {
        ZStack {
            BankingColors.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(BankingColors.backgroundTertiary)
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield.fill")
                                .font(BankingTypo.label())
                                .foregroundColor(BankingColors.accent)
                            Text("SECURE CHECKOUT")
                                .font(BankingTypo.label())
                                .tracking(1.5)
                                .foregroundColor(BankingColors.textOnDarkMuted)
                        }

                        Text(plan.location)
                            .font(BankingTypo.sectionTitle())
                            .foregroundColor(BankingColors.textOnDarkPrimary)
                    }

                    Spacer()

                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark")
                            .font(BankingTypo.button())
                            .foregroundColor(BankingColors.textOnDarkPrimary)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(BankingColors.backgroundTertiary))
                    }
                }
                .padding(.horizontal, BankingSpacing.xl)
                .padding(.top, BankingSpacing.lg)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(spacing: 14) {
                            HStack {
                                Text("ORDER SUMMARY")
                                    .font(AppTheme.Typography.label())
                                    .tracking(2)
                                    .foregroundColor(AppTheme.textTertiary)
                                Spacer()
                            }

                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(plan.name)
                                            .font(AppTheme.Typography.bodyMedium())
                                            .foregroundColor(AppTheme.textPrimary)

                                        Text("\(plan.dataGB) GB · \(plan.durationDays) days")
                                            .font(AppTheme.Typography.tabLabel())
                                            .foregroundColor(AppTheme.textTertiary)
                                    }

                                    Spacer()

                                    Text(plan.priceUSD.formattedPrice)
                                        .font(AppTheme.Typography.bodyMedium())
                                        .foregroundColor(AppTheme.textPrimary)
                                }

                                Rectangle()
                                    .fill(AppTheme.border.opacity(0.4))
                                    .frame(height: 0.5)

                                if StoreKitManager.shared.activeDiscountPercent > 0 {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppTheme.accent)
                                            Text("Plan discount")
                                                .font(AppTheme.Typography.tabLabel())
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        Spacer()
                                        Text("-\(StoreKitManager.shared.activeDiscountPercent)%")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.success)
                                    }
                                }

                                HStack {
                                    Text("Total")
                                        .font(AppTheme.Typography.bodyMedium())
                                        .foregroundColor(AppTheme.textPrimary)

                                    Spacer()

                                    if StoreKitManager.shared.activeDiscountPercent > 0 {
                                        let discounted = plan.priceUSD * (1 - Double(StoreKitManager.shared.activeDiscountPercent) / 100)
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(plan.priceUSD.formattedPrice)
                                                .font(AppTheme.Typography.tabLabel())
                                                .foregroundColor(AppTheme.textMuted)
                                                .strikethrough()
                                            Text(discounted.formattedPrice)
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .foregroundColor(AppTheme.accent)
                                        }
                                    } else {
                                        Text(plan.priceUSD.formattedPrice)
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.accent)
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(AppTheme.backgroundPrimary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                                    )
                                    .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                            )
                        }

                        // Payment Methods
                        VStack(spacing: 14) {
                            HStack {
                                Text("PAYMENT METHOD")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.5)
                                    .foregroundColor(AppTheme.textSecondary)
                                Spacer()
                            }

                            VStack(spacing: 12) {
                                if ApplePayService.isAvailable {
                                    ApplePayButtonView {
                                        Task {
                                            await viewModel.payWithApplePay(
                                                plan: plan,
                                                apiService: coordinator.currentAPIService
                                            )
                                        }
                                    }
                                    .frame(height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .disabled(viewModel.isProcessing)
                                }

                                if ApplePayService.isAvailable {
                                    HStack(spacing: 16) {
                                        Rectangle().fill(AppTheme.gray200).frame(height: 1)
                                        Text("or")
                                            .font(AppTheme.Typography.captionMedium())
                                            .foregroundColor(AppTheme.textSecondary)
                                        Rectangle().fill(AppTheme.gray200).frame(height: 1)
                                    }
                                }

                                Button {
                                    HapticFeedback.medium()
                                    Task {
                                        await viewModel.payWithCard(
                                            plan: plan,
                                            apiService: coordinator.currentAPIService
                                        )
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "creditcard.fill")
                                            .font(.system(size: 18))
                                        Text("Pay with Card")
                                            .font(AppTheme.Typography.bodyMedium())
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .glassmorphism(cornerRadius: 14, opacity: 0.05)
                                }
                                .scaleOnPress()
                                .disabled(viewModel.isProcessing)
                            }
                        }

                        // Crypto payment button
                        Button {
                            showCryptoPayment = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .font(.system(size: 20))
                                Text("Pay with Crypto")
                                    .font(AppTheme.Typography.bodyMedium())
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(AppTheme.textPrimary)
                            .glassmorphism(cornerRadius: 14, opacity: 0.05)
                        }
                        .scaleOnPress()
                        .disabled(viewModel.isProcessing)

                        HStack(spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.accent)

                            Text("Secured by Stripe & Fireblocks. Payments are encrypted.")
                                .font(AppTheme.Typography.navTitle())
                                .foregroundColor(AppTheme.textSecondary)

                            Spacer()
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.gray100)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }

                if viewModel.isProcessing {
                    AppTheme.anthracite.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)

                                Text("Processing payment...")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            .padding(32)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.xxl)
                                    .fill(AppTheme.anthracite.opacity(0.9))
                            )
                        )
                }
            }
        }
        .onChange(of: viewModel.paymentSucceeded) { _, succeeded in
            if succeeded {
                HapticFeedback.success()
                onSuccess()
            }
        }
        .alert("Payment Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $showCryptoPayment) {
            CryptoPaymentView(
                amountUSD: plan.priceUSD,
                onComplete: { onSuccess() },
                onCancel: { showCryptoPayment = false }
            )
            .environmentObject(coordinator)
        }
    }
}

// MARK: - Apple Pay Button

struct ApplePayButtonView: UIViewRepresentable {
    let action: () -> Void

    func makeUIView(context: Context) -> PKPaymentButton {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: PKPaymentButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    class Coordinator: NSObject {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }

        @objc func buttonTapped() { action() }
    }
}

// MARK: - Payment Sheet ViewModel

@MainActor
final class PaymentSheetViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var paymentSucceeded = false
    @Published var showError = false
    @Published var errorMessage = ""

    func payWithApplePay(plan: Plan, apiService: DXBAPIServiceProtocol) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let payment = try await ApplePayService.shared.presentPaymentSheet(
                amount: plan.priceUSD,
                label: "\(plan.name) - \(plan.dataGB)GB"
            )

            let tokenData = payment.tokenBase64
            _ = try await apiService.processApplePayPayment(
                planId: plan.id,
                paymentToken: tokenData,
                paymentNetwork: payment.paymentNetwork
            )

            paymentSucceeded = true
        } catch let error as ApplePayError {
            switch error {
            case .cancelled: break
            default:
                errorMessage = error.localizedDescription
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func payWithCard(plan: Plan, apiService: DXBAPIServiceProtocol) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            _ = try await apiService.purchasePlan(planId: plan.id)
            paymentSucceeded = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    PaymentSheetView(
        plan: Plan(
            id: "1", name: "Dubai Starter", description: "Perfect for short trips",
            dataGB: 5, durationDays: 7, priceUSD: 9.99, speed: "4G/LTE",
            location: "United Arab Emirates", locationCode: "AE"
        ),
        onSuccess: {},
        onCancel: {}
    )
    .environmentObject(AppCoordinator())
}
