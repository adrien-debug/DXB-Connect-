import SwiftUI
import DXBCore

struct SubscriptionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: SubPlan = .elite
    @State private var selectedBilling: BillingPeriod = .annual
    @State private var isSubscribing = false
    @State private var subscriptionError: String?
    @State private var showChangePlan = false
    @State private var showCancelConfirm = false

    enum SubPlan: String, CaseIterable {
        case privilege, elite, black

        var displayName: String {
            switch self {
            case .privilege: return "Privilege"
            case .elite:     return "Elite"
            case .black:     return "Black"
            }
        }

        var icon: String {
            switch self {
            case .privilege: return "shield.checkered"
            case .elite:     return "crown.fill"
            case .black:     return "diamond.fill"
            }
        }

        var color: Color {
            switch self {
            case .privilege: return .cyan
            case .elite:     return .purple
            case .black:     return AppColors.accent
            }
        }

        var discount: Int {
            switch self {
            case .privilege: return 10
            case .elite:     return 20
            case .black:     return 30
            }
        }

        var monthlyPrice: Double {
            switch self {
            case .privilege: return 4.99
            case .elite:     return 9.99
            case .black:     return 19.99
            }
        }

        var annualPrice: Double {
            switch self {
            case .privilege: return 39.99
            case .elite:     return 79.99
            case .black:     return 159.99
            }
        }

        var features: [String] {
            switch self {
            case .privilege: return ["-10% on all eSIM plans", "Priority support", "Partner offers access", "Privilege badge"]
            case .elite:     return ["-20% on all eSIM plans", "VIP 24/7 support", "Premium partner offers", "Gold Elite badge", "Early access to new destinations"]
            case .black:     return ["-30% on all eSIM plans", "Dedicated concierge", "Exclusive partner offers", "Diamond Black badge", "VIP event invitations", "2x bonus points"]
            }
        }
    }

    enum BillingPeriod: String, CaseIterable {
        case monthly = "Monthly"
        case annual = "Annual"
        var savings: String {
            switch self {
            case .monthly: return ""
            case .annual:  return "Save 33%"
            }
        }
    }

    private var currentSubscription: SubscriptionResponse? { appState.subscription }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    heroSection.slideIn(delay: 0)

                    if currentSubscription == nil {
                        billingToggle.slideIn(delay: 0.05)
                        planSelector.slideIn(delay: 0.08)
                        selectedPlanDetails.slideIn(delay: 0.1)
                        subscribeButton.slideIn(delay: 0.12)
                    } else {
                        currentPlanCard.slideIn(delay: 0.05)
                        managementOptions.slideIn(delay: 0.08)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, 120)
            }

            if isSubscribing {
                LoadingOverlay(message: "Processing...")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("SUBSCRIPTION")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.08))
                    .frame(width: 88, height: 88)
                    .blur(radius: 18)

                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColors.accent)
                    .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 4)
            }

            VStack(spacing: 6) {
                Text("SimPass Premium")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Travel connected at reduced prices")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }

    // MARK: - Billing Toggle

    private var billingToggle: some View {
        HStack(spacing: 4) {
            ForEach(BillingPeriod.allCases, id: \.self) { period in
                let isSelected = selectedBilling == period
                Button {
                    withAnimation(.spring(response: 0.3)) { selectedBilling = period }
                } label: {
                    VStack(spacing: 3) {
                        Text(period.rawValue)
                            .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        if !period.savings.isEmpty {
                            Text(period.savings)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(isSelected ? .black.opacity(0.6) : AppColors.success)
                        }
                    }
                    .foregroundStyle(isSelected ? .black : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(isSelected ? AppColors.accent : Color.clear)
                    )
                }
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(AppColors.surface)
                .overlay(Capsule().stroke(AppColors.border, lineWidth: 0.5))
        )
    }

    // MARK: - Plan Selector

    private var planSelector: some View {
        HStack(spacing: AppSpacing.md) {
            ForEach(SubPlan.allCases, id: \.self) { plan in
                planCard(plan)
            }
        }
    }

    private func planCard(_ plan: SubPlan) -> some View {
        let isSelected = selectedPlan == plan
        let perMonth = selectedBilling == .annual ? plan.annualPrice / 12 : plan.monthlyPrice

        return Button {
            withAnimation(.spring(response: 0.3)) { selectedPlan = plan }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: plan.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(plan.color)

                Text(plan.displayName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)

                VStack(spacing: 1) {
                    Text("$\(String(format: "%.2f", perMonth))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? plan.color : AppColors.textPrimary)
                    Text("/mo")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Text("-\(plan.discount)%")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(plan.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(plan.color.opacity(0.1)))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(isSelected ? AppColors.surfaceSecondary : AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(isSelected ? plan.color.opacity(0.6) : AppColors.border, lineWidth: isSelected ? 1.5 : 0.5)
                    )
            )
            .shadow(color: isSelected ? plan.color.opacity(0.1) : Color.clear, radius: 10, x: 0, y: 5)
        }
    }

    // MARK: - Details

    private var selectedPlanDetails: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(selectedPlan.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("Benefits")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }

            VStack(spacing: 10) {
                ForEach(selectedPlan.features, id: \.self) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(selectedPlan.color)
                        Text(feature)
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                    }
                }
            }
        }
        .pulseCard()
    }

    // MARK: - Subscribe

    private var subscribeButton: some View {
        VStack(spacing: 10) {
            if let error = subscriptionError {
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

            let price = selectedBilling == .annual ? selectedPlan.annualPrice : selectedPlan.monthlyPrice

            Button { Task { await subscribe() } } label: {
                HStack(spacing: 8) {
                    Text("Subscribe for $\(String(format: "%.2f", price))")
                    Text(selectedBilling == .annual ? "/year" : "/mo")
                        .opacity(0.6)
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            HStack(spacing: 4) {
                Image(systemName: "lock.fill").font(.system(size: 9))
                Text("Cancel anytime. Secure payment via Stripe.")
                    .font(.system(size: 11))
            }
            .foregroundStyle(AppColors.textTertiary)
        }
    }

    // MARK: - Current Plan

    private var currentPlanCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Plan")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                    HStack(spacing: 8) {
                        Image(systemName: AppTheme.tierIcon(currentSubscription?.plan ?? ""))
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.tierColor(currentSubscription?.plan ?? ""))
                        Text((currentSubscription?.plan ?? "Free").capitalized)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                Spacer()
                StatusBadge(
                    text: currentSubscription?.status ?? "active",
                    color: currentSubscription?.status == "active" ? AppColors.success : AppColors.warning
                )
            }

            Divider().background(AppColors.border)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Discount").font(.system(size: 11)).foregroundStyle(AppColors.textSecondary)
                    Text("-\(currentSubscription?.discount_percent ?? 0)%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.success)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Billing").font(.system(size: 11)).foregroundStyle(AppColors.textSecondary)
                    Text((currentSubscription?.billing_period ?? "monthly").capitalized)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
            }

            if let endDate = currentSubscription?.current_period_end {
                HStack(spacing: 6) {
                    Image(systemName: "calendar").font(.system(size: 12))
                    Text("Next renewal: \(formatDate(endDate))").font(.system(size: 13))
                }
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .pulseCard()
    }

    // MARK: - Management

    private var managementOptions: some View {
        VStack(spacing: 10) {
            Button { showChangePlan = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                    Text("Change Plan")
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            Button { showCancelConfirm = true } label: {
                Text("Cancel Subscription")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.error)
            }
            .padding(.top, 6)
        }
        .sheet(isPresented: $showChangePlan) {
            NavigationStack {
                changePlanSheet
            }
        }
        .confirmationDialog("Cancel Subscription", isPresented: $showCancelConfirm) {
            Button("Cancel Subscription", role: .destructive) {
                Task { await cancelSubscription() }
            }
            Button("Keep Subscription", role: .cancel) {}
        } message: {
            Text("Your subscription will remain active until the end of the current billing period. Are you sure?")
        }
    }

    private var changePlanSheet: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    billingToggle
                    planSelector
                    selectedPlanDetails

                    Button { Task { await changePlan() } } label: {
                        let price = selectedBilling == .annual ? selectedPlan.annualPrice : selectedPlan.monthlyPrice
                        HStack(spacing: 8) {
                            Text("Switch to \(selectedPlan.displayName) for $\(String(format: "%.2f", price))")
                            Text(selectedBilling == .annual ? "/year" : "/mo")
                                .opacity(0.6)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(AppSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("CHANGE PLAN")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.textSecondary)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button { showChangePlan = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
    }

    private func changePlan() async {
        isSubscribing = true; subscriptionError = nil
        do {
            let billing = selectedBilling == .annual ? "annual" : "monthly"
            _ = try await appState.apiService.createSubscription(plan: selectedPlan.rawValue, billingPeriod: billing)
            await appState.loadDashboard()
            isSubscribing = false; showChangePlan = false
        } catch {
            subscriptionError = "Unable to change plan"; isSubscribing = false
        }
    }

    private func cancelSubscription() async {
        isSubscribing = true
        subscriptionError = nil
        do {
            try await appState.apiService.cancelSubscription()
            await appState.loadDashboard()
        } catch {
            subscriptionError = "Unable to cancel subscription. Please contact support."
            appLog("Cancel subscription failed: \(error.localizedDescription)", level: .error, category: .data)
        }
        isSubscribing = false
    }

    // MARK: - Actions

    private func subscribe() async {
        isSubscribing = true; subscriptionError = nil
        do {
            let billing = selectedBilling == .annual ? "annual" : "monthly"
            _ = try await appState.apiService.createSubscription(plan: selectedPlan.rawValue, billingPeriod: billing)
            await appState.loadDashboard()
            isSubscribing = false; dismiss()
        } catch {
            subscriptionError = "Unable to create subscription"; isSubscribing = false
        }
    }

    private func formatDate(_ raw: String) -> String {
        DateFormatHelper.formatISO(raw)
    }
}

#Preview {
    NavigationStack { SubscriptionView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
