import SwiftUI
import DXBCore

struct ProfileView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showEditProfile = false
    @State private var showPaymentMethods = false
    @State private var showOrderHistory = false
    @State private var showReferFriend = false
    @State private var showLanguage = false
    @State private var showAppearance = false
    @State private var showHelpCenter = false
    @State private var showTerms = false
    @State private var showSubscription = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundSecondary
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.base) {
                        profileHeader
                        myPlanSection
                        statsCard
                        accountSection
                        preferencesSection
                        supportSection
                        signOutButton
                        appInfo
                    }
                    .padding(.horizontal, AppTheme.Spacing.base)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Profile Header

    private var visitedCountryCodes: [String] {
        coordinator.esimOrders.compactMap { order in
            let name = order.packageName.lowercased()
            if name.contains("arab") || name.contains("uae") || name.contains("emirates") { return "AE" }
            if name.contains("turkey") || name.contains("türkiye") { return "TR" }
            if name.contains("europe") { return "FR" }
            if name.contains("usa") || name.contains("united states") { return "US" }
            if name.contains("japan") { return "JP" }
            if name.contains("singapore") { return "SG" }
            if name.contains("uk") || name.contains("kingdom") { return "GB" }
            if name.contains("australia") { return "AU" }
            return nil
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 0) {
            ZStack {
                // Gradient background
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accent, AppTheme.accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)

                    // Avatar with SignalRings
                    ZStack {
                        // Signal rings around avatar
                        SignalRings(color: AppTheme.accent.opacity(0.15), size: 110)

                        Circle()
                            .fill(AppTheme.backgroundPrimary)
                            .frame(width: 88, height: 88)

                        Circle()
                            .fill(AppTheme.accent)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(coordinator.user.name.prefix(1)).uppercased())
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(hex: "0F172A"))
                            )
                            .shadow(color: AppTheme.accent.opacity(0.4), radius: 16, x: 0, y: 8)
                    }
                }
            }
            .padding(.bottom, 16)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(coordinator.user.name)
                        .font(.system(size: 26, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(AppTheme.textPrimary)

                    if coordinator.user.isPro {
                        Text("PRO")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1)
                            .foregroundColor(Color(hex: "0F172A"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(AppTheme.accent)
                            )
                    }
                }

                Text(coordinator.user.email)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .padding(.top, 40)
        .slideIn(delay: 0)
    }

    // MARK: - My Plan Section

    private var myPlanSection: some View {
        Button {
            showSubscription = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.accent.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("My Plan")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(StoreKitManager.shared.activePlanName ?? "No active plan")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                if let plan = StoreKitManager.shared.activePlanName {
                    Text("-\(StoreKitManager.shared.activeDiscountPercent)%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.success)
                } else {
                    Text("Upgrade")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "0F172A"))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(AppTheme.accent))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.backgroundPrimary)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSubscription) {
            SimPassSubscriptionView()
                .environmentObject(coordinator)
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: 12) {
            // Mini world map showing visited countries
            WorldMapView(
                highlightedCodes: visitedCountryCodes,
                showConnections: false,
                accentDots: true,
                connectionCodes: [],
                strokeColor: AppTheme.anthracite,
                strokeOpacity: 0.05,
                dotColor: AppTheme.accent,
                showDubaiPulse: true
            )
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppTheme.backgroundPrimary)
                    .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack(spacing: 10) {
                ProfileStatCard(value: "\(coordinator.user.totalESIMs)", label: "eSIMs", icon: "simcard.fill")
                ProfileStatCard(value: "\(coordinator.user.countriesVisited)", label: "Countries", icon: "globe")
                ProfileStatCard(value: String(format: "$%.0f", coordinator.user.totalSaved), label: "Saved", icon: "dollarsign.circle.fill")
            }
        }
        .slideIn(delay: 0.1)
    }

    // MARK: - Account Section

    private var accountSection: some View {
        SectionCardTech(title: "ACCOUNT") {
            VStack(spacing: 0) {
                SettingsRowTech(icon: "person.fill", title: "Edit Profile") {
                    showEditProfile = true
                }
                SettingsDividerTech()
                SettingsRowTech(icon: "creditcard.fill", title: "Payment Methods") {
                    showPaymentMethods = true
                }
                SettingsDividerTech()
                SettingsRowTech(icon: "clock.arrow.circlepath", title: "Order History") {
                    showOrderHistory = true
                }
                SettingsDividerTech()
                SettingsRowTech(icon: "gift.fill", title: "Refer a Friend", badge: "$10") {
                    showReferFriend = true
                }
            }
        }
        .slideIn(delay: 0.15)
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showPaymentMethods) {
            PaymentMethodsSheet()
        }
        .sheet(isPresented: $showOrderHistory) {
            OrderHistorySheet()
        }
        .sheet(isPresented: $showReferFriend) {
            ReferFriendSheet()
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        SectionCardTech(title: "PREFERENCES") {
            VStack(spacing: 0) {
                SettingsToggleTech(icon: "bell.fill", title: "Notifications", isOn: Binding(
                    get: { coordinator.user.notificationsEnabled },
                    set: { coordinator.user.notificationsEnabled = $0 }
                ))
                SettingsDividerTech()
                SettingsRowTech(icon: "globe", title: "Language", value: coordinator.user.language) {
                    showLanguage = true
                }
                SettingsDividerTech()
                SettingsRowTech(icon: "moon.fill", title: "Appearance", value: coordinator.user.appearance) {
                    showAppearance = true
                }
            }
        }
        .slideIn(delay: 0.2)
        .sheet(isPresented: $showLanguage) {
            LanguageSheet(selectedLanguage: Binding(
                get: { coordinator.user.language },
                set: { coordinator.user.language = $0 }
            ))
            .environmentObject(coordinator)
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAppearance) {
            AppearanceSheet(selectedAppearance: Binding(
                get: { coordinator.user.appearance },
                set: { coordinator.user.appearance = $0 }
            ))
            .presentationDetents([.medium])
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        SectionCardTech(title: "SUPPORT") {
            VStack(spacing: 0) {
                SettingsRowTech(icon: "questionmark.circle.fill", title: "Help Center") {
                    showHelpCenter = true
                }
                SettingsDividerTech()
                SettingsRowTech(icon: "envelope.fill", title: "Contact Us") {
                    if let url = URL(string: "mailto:support@dxbconnect.com") {
                        UIApplication.shared.open(url)
                    }
                }
                SettingsDividerTech()
                SettingsRowTech(icon: "doc.text.fill", title: "Terms & Privacy") {
                    showTerms = true
                }
            }
        }
        .slideIn(delay: 0.25)
        .sheet(isPresented: $showHelpCenter) {
            SupportView()
        }
        .sheet(isPresented: $showTerms) {
            TermsSheet()
        }
    }

    // MARK: - Sign Out

    @State private var showSignOutConfirm = false

    private var signOutButton: some View {
        Button {
            showSignOutConfirm = true
        } label: {
            Text("Sign out")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.error.opacity(0.06))
                )
        }
        .scaleOnPress()
        .slideIn(delay: 0.3)
        .alert("Sign Out", isPresented: $showSignOutConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task {
                    await coordinator.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - App Info

    private var appInfo: some View {
        VStack(spacing: 3) {
            Text("DXB CONNECT")
                .font(AppTheme.Typography.label())
                .tracking(1.5)
                .foregroundColor(AppTheme.textSecondary)

            Text("Version 1.0.0")
                .font(AppTheme.Typography.label())
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(.top, AppTheme.Spacing.sm)
    }
}

// MARK: - Profile Components

struct ProfileStatCard: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.accent)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}

struct ProfileStatTech: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        ProfileStatCard(value: value, label: label, icon: icon)
    }
}

struct SectionCardTech<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(AppTheme.textTertiary)
                .padding(.leading, 4)

            content()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.backgroundPrimary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                )
        }
    }
}

struct SettingsRowTech: View {
    let icon: String
    let title: String
    var value: String? = nil
    var badge: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            HapticFeedback.light()
            action?()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppTheme.accent.opacity(0.1)))
                }

                if let value = value {
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppTheme.textTertiary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct SettingsToggleTech: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.textSecondary)
                .frame(width: 24)

            Text(title)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(AppTheme.accent)

        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

struct SettingsDividerTech: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.border.opacity(0.5))
            .frame(height: 0.5)
            .padding(.leading, 54)
    }
}

// MARK: - Legacy Compatibility

struct ProfileStatItem: View {
    let value: String; let label: String; let icon: String
    var body: some View { ProfileStatTech(value: value, label: label.uppercased(), icon: icon) }
}
struct SectionCard<Content: View>: View {
    let title: String; @ViewBuilder let content: () -> Content
    var body: some View { SectionCardTech(title: title.uppercased(), content: content) }
}
struct SettingsRow: View {
    let icon: String; let title: String; let color: Color; var value: String? = nil; var badge: String? = nil
    var body: some View { SettingsRowTech(icon: icon, title: title, value: value, badge: badge) }
}
struct SettingsToggle: View {
    let icon: String; let title: String; let color: Color; @Binding var isOn: Bool
    var body: some View { SettingsToggleTech(icon: icon, title: title, isOn: $isOn) }
}
struct SettingsDivider: View { var body: some View { SettingsDividerTech() } }
struct StatItem: View {
    let value: String; let label: String
    var body: some View { ProfileStatItem(value: value, label: label, icon: "circle.fill") }
}
struct MenuRow: View {
    let icon: String; let title: String; let color: Color; var value: String? = nil; var badge: String? = nil
    var body: some View { SettingsRow(icon: icon, title: title, color: color, value: value, badge: badge) }
}
struct ToggleRow: View {
    let icon: String; let title: String; let color: Color; @Binding var isOn: Bool
    var body: some View { SettingsToggle(icon: icon, title: title, color: color, isOn: $isOn) }
}
struct ProfileStat: View {
    let value: String; let label: String; let icon: String
    var body: some View { ProfileStatItem(value: value, label: label, icon: icon) }
}
struct ProfileMenuItem: View {
    let icon: String; let title: String; let color: Color; var value: String? = nil; var badge: String? = nil
    var body: some View { SettingsRow(icon: icon, title: title, color: color, value: value, badge: badge) }
}
struct ProfileToggleItem: View {
    let icon: String; let title: String; let color: Color; @Binding var isOn: Bool
    var body: some View { SettingsToggle(icon: icon, title: title, color: color, isOn: $isOn) }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var isSaving = false

    private var isFormValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let validEmail = trimmedEmail.range(of: emailRegex, options: .regularExpression) != nil
        return !trimmedName.isEmpty && validEmail
    }

    private var validationError: String? {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty { return "Name is required" }
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if trimmedEmail.range(of: emailRegex, options: .regularExpression) == nil {
            return "Invalid email address"
        }
        return nil
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "EDIT PROFILE", dismiss: dismiss)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent)
                                .frame(width: 88, height: 88)

                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(Color(hex: "0F172A"))

                            Button {} label: {
                                Circle()
                                    .fill(AppTheme.backgroundPrimary)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(AppTheme.gray900)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 4)
                            }
                            .offset(x: 32, y: 32)
                        }
                        .padding(.top, AppTheme.Spacing.base)

                        VStack(spacing: AppTheme.Spacing.md) {
                            ProfileTextField(label: "FULL NAME", text: $name, icon: "person.fill")
                            ProfileTextField(label: "EMAIL", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            ProfileTextField(label: "PHONE", text: $phone, icon: "phone.fill", keyboardType: .phonePad)
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                    }
                    .padding(.bottom, 100)
                }

                VStack(spacing: AppTheme.Spacing.sm) {
                    if let validationError = validationError {
                        Text(validationError)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppTheme.error)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    Button {
                        isSaving = true
                        coordinator.user.name = name.trimmingCharacters(in: .whitespaces)
                        coordinator.user.email = email.trimmingCharacters(in: .whitespaces)
                        coordinator.user.phone = phone.trimmingCharacters(in: .whitespaces)
                        coordinator.savePreferences()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isSaving = false
                            HapticFeedback.success()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView().tint(.black)
                            } else {
                                Text("SAVE CHANGES")
                                    .font(AppTheme.Typography.caption())
                                    .tracking(1.2)
                            }
                        }
                        .foregroundColor(Color(hex: "0F172A"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: AppTheme.Radius.lg).fill(isFormValid ? AppTheme.accent : AppTheme.border))
                    }
                    .disabled(isSaving || !isFormValid)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
                .background(
                    AppTheme.backgroundSecondary
                        .shadow(color: .black.opacity(0.04), radius: 8, y: -2)
                )
            }
        }
        .onAppear {
            name = coordinator.user.name
            email = coordinator.user.email
            phone = coordinator.user.phone
        }
    }
}

// MARK: - Payment Methods Sheet

struct PaymentMethodsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddCard = false

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "PAYMENT METHODS", dismiss: dismiss)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.md) {
                        PaymentCardRow(brand: "visa", last4: "4242", expiry: "12/27", isDefault: true)

                        Button {
                            showAddCard = true
                        } label: {
                            HStack(spacing: AppTheme.Spacing.md) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.xs)
                                        .stroke(AppTheme.border, style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                        .frame(width: 48, height: 32)

                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.accent)
                                }

                                Text("Add New Card")
                                    .font(AppTheme.Typography.body())
                                    .foregroundColor(AppTheme.textPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .stroke(AppTheme.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.lg)
                }
            }
        }
        .sheet(isPresented: $showAddCard) { AddCardSheet() }
    }
}

struct PaymentCardRow: View {
    let brand: String; let last4: String; let expiry: String; let isDefault: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.xs)
                    .fill(AppTheme.gray100)
                    .frame(width: 48, height: 32)
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    Text("•••• \(last4)")
                        .font(AppTheme.Typography.body())
                        .foregroundColor(AppTheme.textPrimary)
                    if isDefault {
                        Text("DEFAULT")
                            .font(AppTheme.Typography.label())
                            .tracking(0.5)
                            .foregroundColor(Color(hex: "0F172A"))
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppTheme.accent))
                    }
                }
                Text("Expires \(expiry)")
                    .font(AppTheme.Typography.small())
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            Button {} label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.backgroundPrimary)
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.lg).stroke(AppTheme.border, lineWidth: 1))
        )
    }
}

struct AddCardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cardNumber = ""
    @State private var expiry = ""
    @State private var cvc = ""
    @State private var name = ""

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()
            VStack(spacing: 0) {
                ProfileSheetHeader(title: "ADD CARD", dismiss: dismiss)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.md) {
                        ProfileTextField(label: "CARD NUMBER", text: $cardNumber, icon: "creditcard.fill", keyboardType: .numberPad)
                        HStack(spacing: AppTheme.Spacing.md) {
                            ProfileTextField(label: "EXPIRY", text: $expiry, icon: "calendar")
                            ProfileTextField(label: "CVC", text: $cvc, icon: "lock.fill", keyboardType: .numberPad)
                        }
                        ProfileTextField(label: "NAME ON CARD", text: $name, icon: "person.fill")
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.lg)
                }
                VStack {
                    Button { dismiss() } label: {
                        Text("ADD CARD")
                            .font(AppTheme.Typography.caption())
                            .tracking(1.2)
                            .foregroundColor(Color(hex: "0F172A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(RoundedRectangle(cornerRadius: AppTheme.Radius.lg).fill(AppTheme.accent))
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
                .background(AppTheme.backgroundSecondary.shadow(color: .black.opacity(0.04), radius: 8, y: -2))
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Order History Sheet

struct OrderHistorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "ORDER HISTORY", dismiss: dismiss)

                if coordinator.orderHistory.isEmpty {
                    VStack(spacing: AppTheme.Spacing.base) {
                        Spacer()
                        ZStack {
                            Circle().fill(AppTheme.gray100).frame(width: 72, height: 72)
                            Image(systemName: "bag")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        VStack(spacing: 6) {
                            Text("No orders yet")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Your purchase history will appear here")
                                .font(AppTheme.Typography.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            ForEach(Array(coordinator.orderHistory.enumerated()), id: \.element.id) { index, order in
                                OrderRow(
                                    name: order.name,
                                    date: order.date,
                                    price: String(format: "$%.2f", order.price),
                                    status: order.status
                                )
                                .slideIn(delay: 0.03 * Double(index))
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)
                        .padding(.top, AppTheme.Spacing.base)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

struct OrderRow: View {
    let name: String; let date: String; let price: String; let status: String

    var statusColor: Color {
        status == "Active" ? AppTheme.success : AppTheme.textSecondary
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                    .fill(AppTheme.accent.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "simcard.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(AppTheme.Typography.button())
                    .foregroundColor(AppTheme.textPrimary)
                Text(date)
                    .font(AppTheme.Typography.small())
                    .foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(price)
                    .font(AppTheme.Typography.button())
                    .foregroundColor(AppTheme.textPrimary)
                Text(status)
                    .font(AppTheme.Typography.label())
                    .tracking(0.5)
                    .foregroundColor(statusColor)
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                .fill(AppTheme.backgroundPrimary)
                .overlay(RoundedRectangle(cornerRadius: AppTheme.Radius.lg).stroke(AppTheme.border, lineWidth: 1))
        )
    }
}

// MARK: - Refer Friend Sheet

struct ReferFriendSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false
    let referralCode = "DXBFRIEND10"

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "REFER A FRIEND", dismiss: dismiss)

                VStack(spacing: 28) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.1))
                            .frame(width: 88, height: 88)
                        Image(systemName: "gift.fill")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }

                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("Give $10, Get $10")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Share your code with friends.\nThey get $10 off, you earn $10 credit!")
                            .font(AppTheme.Typography.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("YOUR CODE")
                            .font(AppTheme.Typography.label())
                            .tracking(1.5)
                            .foregroundColor(AppTheme.textSecondary)

                        Button {
                            UIPasteboard.general.string = referralCode
                            HapticFeedback.success()
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                        } label: {
                            HStack(spacing: AppTheme.Spacing.md) {
                                Text(referralCode)
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppTheme.accent)
                                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(copied ? AppTheme.success : AppTheme.textSecondary)
                            }
                            .padding(.horizontal, AppTheme.Spacing.xl)
                            .padding(.vertical, AppTheme.Spacing.base)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                    .fill(AppTheme.accent.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                            .stroke(AppTheme.accent.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                                    )
                            )
                        }
                    }

                    Spacer()

                    Button {
                        let text = "Use my code \(referralCode) to get $10 off your first DXB Connect eSIM!"
                        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController?.present(av, animated: true)
                        }
                    } label: {
                        HStack(spacing: AppTheme.Spacing.sm) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                            Text("SHARE CODE")
                                .font(AppTheme.Typography.caption())
                                .tracking(1.2)
                        }
                        .foregroundColor(Color(hex: "0F172A"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: AppTheme.Radius.lg).fill(AppTheme.accent))
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Language Sheet

struct LanguageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @Binding var selectedLanguage: String
    let languages = ["English", "Français", "العربية", "Español", "Deutsch", "中文", "日本語"]

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()
            VStack(spacing: 0) {
                ProfileSheetHeader(title: "LANGUAGE", dismiss: dismiss)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(languages, id: \.self) { language in
                            Button {
                                HapticFeedback.selection()
                                selectedLanguage = language
                                coordinator.savePreferences()
                                dismiss()
                            } label: {
                                HStack {
                                    Text(language)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    if selectedLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(AppTheme.accent)
                                    }
                                }
                                .padding(AppTheme.Spacing.base)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .fill(selectedLanguage == language ? AppTheme.accent.opacity(0.1) : AppTheme.backgroundPrimary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                                .stroke(selectedLanguage == language ? AppTheme.accent.opacity(0.4) : AppTheme.border, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.top, AppTheme.Spacing.base)
                }
            }
        }
    }
}

// MARK: - Appearance Sheet

struct AppearanceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @Binding var selectedAppearance: String

    let appearances = [
        ("Light", "sun.max.fill"),
        ("Dark", "moon.fill"),
        ("System", "gear")
    ]

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()
            VStack(spacing: 0) {
                ProfileSheetHeader(title: "APPEARANCE", dismiss: dismiss)
                VStack(spacing: AppTheme.Spacing.md) {
                    ForEach(appearances, id: \.0) { appearance in
                        Button {
                            HapticFeedback.selection()
                            selectedAppearance = appearance.0
                            applyAppearance(appearance.0)
                            coordinator.savePreferences()
                            dismiss()
                        } label: {
                            HStack(spacing: AppTheme.Spacing.md) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.sm)
                                        .fill(AppTheme.accent.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: appearance.1)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.accent)
                                }

                                Text(appearance.0)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary)

                                Spacer()

                                if selectedAppearance == appearance.0 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(AppTheme.accent)
                                } else {
                                    Circle()
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding(AppTheme.Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .fill(AppTheme.backgroundPrimary)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                            .stroke(selectedAppearance == appearance.0 ? AppTheme.accent.opacity(0.4) : AppTheme.border, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.base)
                Spacer()
            }
        }
    }

    private func applyAppearance(_ mode: String) {
        let appearanceMode: AppearanceMode
        switch mode {
        case "Dark": appearanceMode = .dark
        case "System": appearanceMode = .system
        default: appearanceMode = .light
        }
        AppTheme.setAppearance(appearanceMode)
    }
}

// MARK: - Terms Sheet

struct TermsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()
            VStack(spacing: 0) {
                ProfileSheetHeader(title: "LEGAL", dismiss: dismiss)

                HStack(spacing: 0) {
                    ForEach(["Terms", "Privacy"], id: \.self) { tab in
                        let index = tab == "Terms" ? 0 : 1
                        Button {
                            withAnimation { selectedTab = index }
                        } label: {
                            Text(tab)
                                .font(AppTheme.Typography.button())
                                .foregroundColor(selectedTab == index ? AppTheme.accent : AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.md)
                                .background(
                                    VStack {
                                        Spacer()
                                        Rectangle()
                                            .fill(selectedTab == index ? AppTheme.accent : Color.clear)
                                            .frame(height: 2)
                                    }
                                )
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.xl)

                Divider()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                        if selectedTab == 0 { termsContent } else { privacyContent }
                    }
                    .padding(AppTheme.Spacing.xl)
                }
            }
        }
    }

    private var termsContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.base) {
            Text("Terms of Service")
                .font(AppTheme.Typography.sectionTitle())
                .foregroundColor(AppTheme.textPrimary)

            Text("Last updated: February 2026")
                .font(AppTheme.Typography.small())
                .foregroundColor(AppTheme.textSecondary)

            Group {
                legalSection(title: "1. Acceptance of Terms", content: "By accessing and using DXB Connect services, you accept and agree to be bound by the terms and conditions of this agreement.")
                legalSection(title: "2. Service Description", content: "DXB Connect provides eSIM services for mobile connectivity. Our eSIMs are designed for travelers and provide data connectivity in supported regions.")
                legalSection(title: "3. User Responsibilities", content: "You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.")
                legalSection(title: "4. Refund Policy", content: "Refunds are available within 24 hours of purchase if the eSIM has not been activated. Once activated, refunds are not available.")
            }
        }
    }

    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.base) {
            Text("Privacy Policy")
                .font(AppTheme.Typography.sectionTitle())
                .foregroundColor(AppTheme.textPrimary)

            Text("Last updated: February 2026")
                .font(AppTheme.Typography.small())
                .foregroundColor(AppTheme.textSecondary)

            Group {
                legalSection(title: "Information We Collect", content: "We collect information you provide directly, such as name, email, and payment information when you create an account or make a purchase.")
                legalSection(title: "How We Use Information", content: "We use the information to provide and improve our services, process transactions, and communicate with you about your account.")
                legalSection(title: "Data Security", content: "We implement industry-standard security measures to protect your personal information from unauthorized access.")
                legalSection(title: "Your Rights", content: "You have the right to access, correct, or delete your personal information. Contact us at privacy@dxbconnect.com for requests.")
            }
        }
    }

    private func legalSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.textPrimary)
            Text(content)
                .font(AppTheme.Typography.body())
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - Shared Components

struct ProfileSheetHeader: View {
    let title: String
    let dismiss: DismissAction

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(AppTheme.gray100))
            }
            .accessibilityLabel("Fermer")

            Spacer()

            Text(title)
                .font(AppTheme.Typography.navTitle())
                .tracking(1.5)
                .foregroundColor(AppTheme.textSecondary)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
        .padding(.top, AppTheme.Spacing.lg)
    }
}

struct ProfileTextField: View {
    let label: String
    @Binding var text: String
    var icon: String = "pencil"
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.label())
                .tracking(1.2)
                .foregroundColor(AppTheme.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(AppTheme.Typography.body())
                    .foregroundColor(AppTheme.accent)
                    .frame(width: 24)

                TextField("", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.primary)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(AppTheme.backgroundPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppCoordinator())
}
