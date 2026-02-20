import SwiftUI
import DXBCore

struct SimPassSubscriptionView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var storeKit = StoreKitManager.shared
    @State private var selectedPeriod: BillingPeriod = .monthly
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingRadius = AppTheme.Banking.Radius
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    enum BillingPeriod {
        case monthly, yearly
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BankingColors.backgroundPrimary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: BankingSpacing.xl) {
                        headerSection
                        periodToggle
                        plansSection
                        featuresComparison
                        restoreButton
                    }
                    .padding(.horizontal, BankingSpacing.lg)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("SimPass Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(BankingTypo.button())
                            .foregroundColor(BankingColors.textOnDarkPrimary)
                    }
                }
            }
            .task { await storeKit.loadProducts() }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: BankingSpacing.sm) {
            Text("Unlock Premium Benefits")
                .font(BankingTypo.detailAmount())
                .foregroundColor(BankingColors.textOnDarkPrimary)

            Text("Save on every eSIM purchase\nand unlock exclusive travel perks")
                .font(BankingTypo.body())
                .foregroundColor(BankingColors.textOnDarkMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.top, BankingSpacing.base)
    }

    // MARK: - Period Toggle

    private var periodToggle: some View {
        HStack(spacing: 0) {
            periodButton(title: "Monthly", period: .monthly)
            periodButton(title: "Yearly (-17%)", period: .yearly)
        }
        .background(BankingColors.backgroundTertiary)
        .clipShape(Capsule())
    }

    private func periodButton(title: String, period: BillingPeriod) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPeriod = period
            }
        } label: {
            Text(title)
                .font(BankingTypo.button())
                .foregroundColor(selectedPeriod == period ? BankingColors.backgroundPrimary : BankingColors.textOnDarkMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedPeriod == period
                        ? Capsule().fill(BankingColors.accent)
                        : Capsule().fill(Color.clear)
                )
        }
    }

    // MARK: - Plans

    private var plansSection: some View {
        VStack(spacing: BankingSpacing.md) {
            planCard(
                name: "Privilege",
                discount: 15,
                monthlyPrice: "$9.99",
                yearlyPrice: "$99/yr",
                features: ["15% off all eSIMs", "Global perks access"],
                color: BankingColors.accentDark,
                isPopular: false
            )

            planCard(
                name: "Elite",
                discount: 30,
                monthlyPrice: "$19.99",
                yearlyPrice: "$199/yr",
                features: ["30% off all eSIMs", "Priority support", "Monthly raffle entry"],
                color: BankingColors.accent,
                isPopular: true
            )

            planCard(
                name: "Black",
                discount: 50,
                monthlyPrice: "$39.99",
                yearlyPrice: "$399/yr",
                features: ["50% off (1x/month)", "30% off remaining", "VIP lounge access", "Premium transfers"],
                color: BankingColors.accentLight,
                isPopular: false
            )
        }
    }

    private func planCard(name: String, discount: Int, monthlyPrice: String, yearlyPrice: String, features: [String], color: Color, isPopular: Bool) -> some View {
        VStack(alignment: .leading, spacing: BankingSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: BankingSpacing.sm) {
                        Text(name)
                            .font(BankingTypo.sectionTitle())
                            .foregroundColor(BankingColors.textOnLightPrimary)

                        if isPopular {
                            Text("POPULAR")
                                .font(BankingTypo.label())
                                .foregroundColor(BankingColors.backgroundPrimary)
                                .padding(.horizontal, BankingSpacing.sm)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(BankingColors.accent))
                        }
                    }

                    Text(selectedPeriod == .monthly ? monthlyPrice + "/mo" : yearlyPrice)
                        .font(BankingTypo.body())
                        .foregroundColor(BankingColors.textOnLightMuted)
                }

                Spacer()

                Text("-\(discount)%")
                    .font(BankingTypo.detailAmount())
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: BankingSpacing.sm) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: BankingSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(color)
                        Text(feature)
                            .font(BankingTypo.body())
                            .foregroundColor(BankingColors.textOnLightPrimary)
                    }
                }
            }

            let isActive = storeKit.activePlanName == name
            Button {
                Task { await subscribeToPlan(name: name) }
            } label: {
                Text(isActive ? "Current Plan" : "Subscribe")
                    .font(BankingTypo.button())
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(isActive ? BankingColors.textOnLightMuted : BankingColors.backgroundPrimary)
                    .background(
                        RoundedRectangle(cornerRadius: CGFloat(BankingRadius.medium))
                            .fill(isActive ? BankingColors.surfaceMedium : color)
                    )
            }
            .disabled(isActive || storeKit.isLoading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.backgroundPrimary)
                .overlay(
                    isPopular
                        ? RoundedRectangle(cornerRadius: 20).stroke(color, lineWidth: 2)
                        : RoundedRectangle(cornerRadius: 20).stroke(AppTheme.border.opacity(0.3), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Features Comparison

    private var featuresComparison: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All plans include")
                .font(AppTheme.Typography.bodyMedium())
                .foregroundColor(AppTheme.textPrimary)

            ForEach(["Automatic billing", "Cancel anytime", "Instant activation", "Global partner perks"], id: \.self) { feature in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(AppTheme.Typography.navTitle())
                        .foregroundColor(AppTheme.accent)
                    Text(feature)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.gray100)
        )
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button {
            Task { await storeKit.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(AppTheme.Typography.tabLabel())
                .foregroundColor(AppTheme.textTertiary)
        }
    }

    // MARK: - Actions

    private func subscribeToPlan(name: String) async {
        let suffix = selectedPeriod == .monthly ? "monthly" : "yearly"
        let productId = "com.simpass.\(name.lowercased()).\(suffix)"

        guard let product = storeKit.products.first(where: { $0.id == productId }) else {
            errorMessage = "Product not available"
            showError = true
            return
        }

        do {
            let _ = try await storeKit.purchase(product)

            // Sync subscription with backend
            let billingPeriod = selectedPeriod == .monthly ? "monthly" : "yearly"
            let _ = try? await coordinator.currentAPIService.createSubscription(
                plan: name.lowercased(),
                billingPeriod: billingPeriod
            )

            HapticFeedback.success()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    SimPassSubscriptionView()
        .environmentObject(AppCoordinator())
}
