import SwiftUI
import DXBCore
import PassKit

struct SubscriptionView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlan: SubPlan = .elite
    @State private var selectedBilling: BillingPeriod = .annual
    @State private var isSubscribing = false
    @State private var subscriptionError: String?
    @State private var showChangePlan = false
    @State private var showCancelConfirm = false
    @State private var useApplePay: Bool = {
        #if targetEnvironment(simulator)
        return false
        #else
        return ApplePayService.canMakePayments
        #endif
    }()

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
            case .privilege: return AppColors.chromeLight
            case .elite:     return AppColors.accent
            case .black:     return AppColors.white
            }
        }

        var discount: Int {
            switch self {
            case .privilege: return 15
            case .elite:     return 30
            case .black:     return 50
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
            case .privilege: return ["-15% on all eSIM plans", "Priority support", "Partner offers access", "Privilege badge"]
            case .elite:     return ["-30% on all eSIM plans", "VIP 24/7 support", "Premium partner offers", "Gold Elite badge", "Early access to new destinations"]
            case .black:     return ["-50% on 1st eSIM/month, then -30%", "Dedicated concierge", "Exclusive partner offers", "Diamond Black badge", "VIP event invitations", "2x bonus points"]
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

            VStack(spacing: 0) {
                if currentSubscription == nil {
                    heroSection.slideIn(delay: 0)

                    billingToggle.slideIn(delay: 0.05)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, 10)

                    planSelector.slideIn(delay: 0.08)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, 10)

                    selectedPlanDetails.slideIn(delay: 0.1)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, 14)

                    subscribeButton.slideIn(delay: 0.12)
                        .padding(.horizontal, AppSpacing.lg)
                } else {
                    heroSection.slideIn(delay: 0)

                    currentPlanCard.slideIn(delay: 0.05)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, 14)

                    managementOptions.slideIn(delay: 0.08)
                        .padding(.horizontal, AppSpacing.lg)
                }

                Spacer()
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
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.08))
                    .frame(width: 56, height: 56)
                    .blur(radius: 12)

                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.accent)
                    .shadow(color: AppColors.accent.opacity(0.3), radius: 8, x: 0, y: 3)
            }

            VStack(spacing: 3) {
                Text("SimPass Premium")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Travel connected at reduced prices")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .padding(.bottom, 12)
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
                                .foregroundStyle(isSelected ? .black.opacity(0.7) : AppColors.accent)
                        }
                    }
                    .foregroundStyle(isSelected ? .black : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
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
        let isBlack = plan == .black

        return Button {
            withAnimation(.spring(response: 0.3)) { selectedPlan = plan }
            HapticFeedback.light()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(plan.color.opacity(isBlack ? 0.08 : 0.06))
                        .frame(width: 32, height: 32)

                    Image(systemName: plan.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(plan.color)
                }

                Text(plan.displayName.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(isSelected ? plan.color : AppColors.textSecondary)

                VStack(spacing: 1) {
                    Text("$\(String(format: "%.2f", perMonth))")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("/mo")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }

                Text("-\(plan.discount)%")
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(plan == .elite ? .black : plan.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(plan == .elite ? AppColors.accent : plan.color.opacity(0.1))
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(isSelected ? AppColors.surfaceElevated : AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(
                                isSelected ? (plan == .elite ? AppColors.accent.opacity(0.5) : plan.color.opacity(0.3)) : AppColors.border,
                                lineWidth: isSelected ? 1.5 : 0.5
                            )
                    )
            )
        }
    }

    // MARK: - Details

    private var selectedPlanDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: selectedPlan.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(selectedPlan == .elite ? AppColors.accent : selectedPlan.color)
                    Text(selectedPlan.displayName)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                }
                Spacer()
                Text("BENEFITS")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(AppColors.textTertiary)
            }

            VStack(spacing: 5) {
                ForEach(selectedPlan.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(AppColors.accent)
                            .frame(width: 16, height: 16)
                            .background(
                                Circle().fill(AppColors.accent.opacity(0.1))
                            )
                        Text(feature)
                            .font(.system(size: 13))
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
        VStack(spacing: 6) {
            if let error = subscriptionError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(AppColors.error)
                    Text(error).font(.system(size: 12)).foregroundStyle(AppColors.textPrimary)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.sm).fill(AppColors.error.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.sm).stroke(AppColors.error.opacity(0.15), lineWidth: 1))
                )
            }

            let price = selectedBilling == .annual ? selectedPlan.annualPrice : selectedPlan.monthlyPrice

            if useApplePay {
                Button { Task { await subscribeWithApplePay() } } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 16))
                        Text("Pay $\(String(format: "%.2f", price))")
                            .font(.system(size: 16, weight: .bold))
                        Text(selectedBilling == .annual ? "/year" : "/mo")
                            .font(.system(size: 14))
                            .opacity(0.6)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Capsule().fill(.black))
                    .overlay(Capsule().stroke(AppColors.borderLight, lineWidth: 0.5))
                }

                Button {
                    useApplePay = false
                } label: {
                    Text("Use card instead")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else {
                Button { Task { await subscribe() } } label: {
                    HStack(spacing: 6) {
                        Text("Subscribe for $\(String(format: "%.2f", price))")
                        Text(selectedBilling == .annual ? "/year" : "/mo")
                            .opacity(0.6)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())

                if ApplePayService.isAvailable {
                    Button {
                        useApplePay = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "apple.logo").font(.system(size: 10))
                            Text("Use Apple Pay")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            HStack(spacing: 3) {
                Image(systemName: "lock.fill").font(.system(size: 8))
                Text("Cancel anytime. Secure payment.")
                    .font(.system(size: 10))
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
            let billing = selectedBilling == .annual ? "yearly" : "monthly"
            _ = try await appState.apiService.createSubscription(plan: selectedPlan.rawValue, billingPeriod: billing)
            await appState.loadDashboard()
            isSubscribing = false; showChangePlan = false
        } catch {
            subscriptionError = error.localizedDescription
            isSubscribing = false
            #if DEBUG
            print("[Subscription] Change plan failed: \(error)")
            #endif
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
            #if DEBUG
            print("[Subscription] Cancel failed: \(error.localizedDescription)")
            #endif
        }
        isSubscribing = false
    }

    // MARK: - Apple Pay Subscribe

    private func subscribeWithApplePay() async {
        guard ApplePayService.isAvailable else {
            subscriptionError = "Apple Pay is not available on this device. Use card instead."
            useApplePay = false
            return
        }

        isSubscribing = true; subscriptionError = nil
        do {
            let price = selectedBilling == .annual ? selectedPlan.annualPrice : selectedPlan.monthlyPrice
            let label = "SimPass \(selectedPlan.displayName) – \(selectedBilling == .annual ? "Annual" : "Monthly")"

            let payment = try await ApplePayService.shared.presentPaymentSheet(
                amount: price,
                label: label
            )

            let billing = selectedBilling == .annual ? "yearly" : "monthly"
            _ = try await appState.apiService.createSubscriptionApplePay(
                plan: selectedPlan.rawValue,
                billingPeriod: billing,
                paymentToken: payment.tokenBase64,
                paymentNetwork: payment.paymentNetwork
            )
            await appState.loadDashboard()
            isSubscribing = false; dismiss()
        } catch let apError as ApplePayError {
            isSubscribing = false
            switch apError {
            case .cancelled:
                break
            case .notAvailable, .notConfigured, .failedToPresent:
                subscriptionError = apError.localizedDescription
                useApplePay = false
            case .failedToCreate, .paymentFailed:
                subscriptionError = apError.localizedDescription
            }
        } catch {
            subscriptionError = "Payment failed. Please try again."
            isSubscribing = false
        }
    }

    // MARK: - Actions

    private func subscribe() async {
        isSubscribing = true; subscriptionError = nil
        do {
            let billing = selectedBilling == .annual ? "yearly" : "monthly"
            _ = try await appState.apiService.createSubscription(plan: selectedPlan.rawValue, billingPeriod: billing)
            await appState.loadDashboard()
            isSubscribing = false; dismiss()
        } catch {
            subscriptionError = error.localizedDescription
            isSubscribing = false
            #if DEBUG
            print("[Subscription] Create failed: \(error)")
            #endif
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
