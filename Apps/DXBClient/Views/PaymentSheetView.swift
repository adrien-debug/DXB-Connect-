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
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(AppTheme.gray300)
                .frame(width: 36, height: 5)
                .padding(.top, 12)
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CHECKOUT")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)
                    
                    Text(plan.location)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(AppTheme.gray100)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Order Summary
                    VStack(spacing: 16) {
                        HStack {
                            Text("ORDER SUMMARY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            // Plan details
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(plan.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    
                                    Text("\(plan.dataGB) GB • \(plan.durationDays) days")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.textTertiary)
                                }
                                
                                Spacer()
                                
                                Text(plan.priceUSD.formattedPrice)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            
                            Rectangle()
                                .fill(AppTheme.border)
                                .frame(height: 1)
                            
                            // Total
                            HStack {
                                Text("Total")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                Text(plan.priceUSD.formattedPrice)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                        )
                    }
                    
                    // Payment Methods
                    VStack(spacing: 16) {
                        HStack {
                            Text("PAYMENT METHOD")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundColor(AppTheme.textTertiary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            // Apple Pay Button (Primary)
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
                                .disabled(viewModel.isProcessing)
                            }
                            
                            // Or separator
                            if ApplePayService.isAvailable {
                                HStack(spacing: 16) {
                                    Rectangle()
                                        .fill(AppTheme.border)
                                        .frame(height: 1)
                                    
                                    Text("or")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(AppTheme.textTertiary)
                                    
                                    Rectangle()
                                        .fill(AppTheme.border)
                                        .frame(height: 1)
                                }
                            }
                            
                            // Card Payment (Fallback)
                            Button {
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
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .foregroundColor(AppTheme.textPrimary)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                            }
                            .disabled(viewModel.isProcessing)
                        }
                    }
                    
                    // Security Note
                    HStack(spacing: 8) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textTertiary)
                        
                        Text("Secured by Stripe. Your payment details are encrypted.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppTheme.gray50)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            
            // Processing overlay
            if viewModel.isProcessing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            
                            Text("Processing payment...")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(AppTheme.textPrimary.opacity(0.9))
                        )
                    )
            }
        }
        .background(Color.white)
        .onChange(of: viewModel.paymentSucceeded) { succeeded in
            if succeeded {
                onSuccess()
            }
        }
        .alert("Payment Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Apple Pay Button (UIKit Wrapper)

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
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
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
            // 1. Présenter Apple Pay
            let payment = try await ApplePayService.shared.presentPaymentSheet(
                amount: plan.priceUSD,
                label: "\(plan.name) - \(plan.dataGB)GB"
            )
            
            // 2. Envoyer le token au backend pour traitement
            let tokenData = payment.tokenBase64
            
            _ = try await apiService.processApplePayPayment(
                planId: plan.id,
                paymentToken: tokenData,
                paymentNetwork: payment.paymentNetwork
            )
            
            // 3. Succès
            paymentSucceeded = true
            
        } catch let error as ApplePayError {
            switch error {
            case .cancelled:
                // L'utilisateur a annulé, pas d'erreur à afficher
                break
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
            // Pour l'instant, utiliser la méthode d'achat existante
            // TODO: Intégrer Stripe SDK pour card input
            _ = try await apiService.purchasePlan(planId: plan.id)
            paymentSucceeded = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Preview

#Preview {
    PaymentSheetView(
        plan: Plan(
            id: "1",
            name: "Dubai Starter",
            description: "Perfect for short trips",
            dataGB: 5,
            durationDays: 7,
            priceUSD: 9.99,
            speed: "4G/LTE",
            location: "United Arab Emirates",
            locationCode: "AE"
        ),
        onSuccess: { print("Success!") },
        onCancel: { print("Cancelled") }
    )
    .environmentObject(AppCoordinator())
}
