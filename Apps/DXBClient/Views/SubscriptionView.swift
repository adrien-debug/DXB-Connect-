import SwiftUI
import DXBCore

struct SimPassSubscriptionView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var storeKit = StoreKitManager.shared
    @State private var selectedPeriod: BillingPeriod = .monthly
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss

    enum BillingPeriod {
        case monthly, yearly
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundSecondary.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerSection
                        periodToggle
                        plansSection
                        featuresComparison
                        restoreButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("SimPass Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
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
        VStack(spacing: 8) {
            Text("Unlock Premium Benefits")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Save on every eSIM purchase\nand unlock exclusive travel perks")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    // MARK: - Period Toggle

    private var periodToggle: some View {
        HStack(spacing: 0) {
            periodButton(title: "Monthly", period: .monthly)
            periodButton(title: "Yearly (-17%)", period: .yearly)
        }
        .background(AppTheme.gray100)
        .clipShape(Capsule())
    }

    private func periodButton(title: String, period: BillingPeriod) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPeriod = period
            }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(selectedPeriod == period ? Color(hex: "0F172A") : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedPeriod == period
                        ? Capsule().fill(AppTheme.accent)
                        : Capsule().fill(Color.clear)
                )
        }
    }

    // MARK: - Plans

    private var plansSection: some View {
        VStack(spacing: 14) {
            planCard(
                name: "Privilege",
                discount: 15,
                monthlyPrice: "$9.99",
                yearlyPrice: "$99/yr",
                features: ["15% off all eSIMs", "Global perks access"],
                color: AppTheme.success,
                isPopular: false
            )

            planCard(
                name: "Elite",
                discount: 30,
                monthlyPrice: "$19.99",
                yearlyPrice: "$199/yr",
                features: ["30% off all eSIMs", "Priority support", "Monthly raffle entry"],
                color: AppTheme.primary,
                isPopular: true
            )

            planCard(
                name: "Black",
                discount: 50,
                monthlyPrice: "$39.99",
                yearlyPrice: "$399/yr",
                features: ["50% off (1x/month)", "30% off remaining", "VIP lounge access", "Premium transfers"],
                color: AppTheme.accent,
                isPopular: false
            )
        }
    }

    private func planCard(name: String, discount: Int, monthlyPrice: String, yearlyPrice: String, features: [String], color: Color, isPopular: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        if isPopular {
                            Text("POPULAR")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(hex: "0F172A"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(AppTheme.accent))
                        }
                    }

                    Text(selectedPeriod == .monthly ? monthlyPrice + "/mo" : yearlyPrice)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Text("-\(discount)%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(color)
                        Text(feature)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }

            let isActive = storeKit.activePlanName == name
            Button {
                Task { await subscribeToPlan(name: name) }
            } label: {
                Text(isActive ? "Current Plan" : "Subscribe")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(isActive ? AppTheme.textSecondary : Color(hex: "0F172A"))
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isActive ? AppTheme.gray100 : color)
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            ForEach(["Automatic billing", "Cancel anytime", "Instant activation", "Global partner perks"], id: \.self) { feature in
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
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
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.gray100)
        )
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button {
            Task { await storeKit.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.system(size: 14, weight: .medium))
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
