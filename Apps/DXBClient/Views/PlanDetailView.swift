import SwiftUI
import DXBCore

struct PlanDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let plan: Plan

    @State private var isPurchasing = false
    @State private var showPaymentSheet = false
    @State private var purchaseResult: PurchaseResult?
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String?

    enum PurchaseResult {
        case success(ESIMOrder)
        case error(String)
    }

    private var discountedPrice: Double? {
        guard let discount = appState.subscription?.discount_percent, discount > 0 else { return nil }
        return plan.priceUSD * (1 - Double(discount) / 100)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    heroSection.slideIn(delay: 0)
                    specsSection.slideIn(delay: 0.05)

                    if appState.subscription == nil {
                        subscriptionUpsell.slideIn(delay: 0.08)
                    }

                    featuresSection.slideIn(delay: 0.1)
                    purchaseSection.slideIn(delay: 0.15)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, 120)
            }

            if isPurchasing {
                LoadingOverlay(message: "Preparing your eSIM...")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("PLAN DETAILS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .sheet(isPresented: $showPaymentSheet) {
            PaymentSheetView(plan: plan) { order in
                purchaseResult = .success(order)
                showSuccessAlert = true
            }
        }
        .alert("eSIM Purchased!", isPresented: $showSuccessAlert) {
            Button("View my eSIM") {
                Task { await appState.loadDashboard() }
                dismiss()
            }
        } message: {
            if case .success(let order) = purchaseResult {
                Text("Your eSIM \(order.packageName) is ready. Scan the QR code to install it.")
            }
        }
    }

    private var isSuccess: Bool {
        if case .success = purchaseResult { return true }
        return false
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Text(countryFlag(plan.locationCode))
                    .font(.system(size: 64))
            }

            VStack(spacing: 8) {
                Text(plan.location)
                    .font(AppFonts.largeTitle())
                    .foregroundStyle(AppColors.textPrimary)

                Text(plan.name)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }

            priceDisplay
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .pulseCard(glow: true)
    }

    private var priceDisplay: some View {
        VStack(spacing: 6) {
            if let discounted = discountedPrice {
                HStack(spacing: 8) {
                    Text("$\(String(format: "%.2f", plan.priceUSD))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                        .strikethrough()

                    StatusBadge(text: "-\(appState.subscription?.discount_percent ?? 0)%", color: AppColors.success)
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppColors.accent.opacity(0.7))
                    Text(String(format: "%.2f", discounted))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.accent)
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.accent.opacity(0.7))
                    Text(String(format: "%.2f", plan.priceUSD))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
    }

    // MARK: - Specs

    private var specsSection: some View {
        HStack(spacing: 0) {
            specItem(icon: "arrow.down.circle.fill", value: "\(plan.dataGB)", unit: "GB", label: "DATA")
            specDivider
            specItem(icon: "calendar", value: "\(plan.durationDays)", unit: "days", label: "VALIDITY")
            specDivider
            specItem(icon: "bolt.fill", value: plan.speed, unit: "", label: "NETWORK")
        }
        .chromeCard(accentGlow: true)
    }

    private func specItem(icon: String, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.accent)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var specDivider: some View {
        Rectangle()
            .fill(AppColors.border)
            .frame(width: 1, height: 60)
    }

    // MARK: - Subscription Upsell

    private var subscriptionUpsell: some View {
        NavigationLink {
            SubscriptionView()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.accent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Save $\(String(format: "%.2f", plan.priceUSD * 0.3)) with Premium")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Subscribe from $3.33/mo for -30% on all plans")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(AppColors.accent.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                            .stroke(AppColors.accent.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("INCLUDED")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(AppColors.textTertiary)

            VStack(spacing: 10) {
                featureRow("Instant QR code installation")
                featureRow("Hotspot / Tethering supported")
                featureRow("24/7 customer support")
                featureRow("Compatible with iPhone XS and newer")
                featureRow("Top-up anytime")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pulseCard()
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.success)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
    }

    // MARK: - Purchase

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            Button { showPaymentSheet = true } label: {
                HStack(spacing: 10) {
                    Image(systemName: "creditcard.fill")
                    Text("Buy Now")
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                Text("Secure payment via Stripe")
                    .font(.system(size: 11))
            }
            .foregroundStyle(AppColors.textTertiary)
        }
    }

    private func countryFlag(_ code: String) -> String {
        CountryHelper.flagFromCode(code)
    }
}

#Preview {
    NavigationStack {
        PlanDetailView(plan: Plan(id: "1", name: "UAE Premium", description: "30 days", dataGB: 10, durationDays: 30, priceUSD: 29.99, speed: "5G", location: "United Arab Emirates", locationCode: "AE"))
    }
    .environment(AppState())
    .preferredColorScheme(.dark)
}
