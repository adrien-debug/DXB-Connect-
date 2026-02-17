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

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        profileHeader
                        statsCard
                        accountSection
                        preferencesSection
                        supportSection
                        signOutButton
                        appInfo
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 140)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 20) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppTheme.textPrimary)
                    .frame(width: 88, height: 88)

                Text(String(coordinator.user.name.prefix(1)).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 10) {
                Text(coordinator.user.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(coordinator.user.email)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)

                // Pro badge - monochrome version
                if coordinator.user.isPro {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text("PRO")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(AppTheme.textPrimary)
                    )
                }
            }
        }
        .padding(.top, 64)
        .slideIn(delay: 0)
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        HStack(spacing: 0) {
            ProfileStatTech(value: "\(coordinator.user.totalESIMs)", label: "ESIMS", icon: "simcard.fill")

            Rectangle()
                .fill(AppTheme.border)
                .frame(width: 1, height: 44)

            ProfileStatTech(value: "\(coordinator.user.countriesVisited)", label: "COUNTRIES", icon: "globe")

            Rectangle()
                .fill(AppTheme.border)
                .frame(width: 1, height: 44)

            ProfileStatTech(value: String(format: "$%.0f", coordinator.user.totalSaved), label: "SAVED", icon: "dollarsign.circle.fill")
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.border, lineWidth: 1.5)
                )
        )
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
        .slideIn(delay: 0.2)
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
        .slideIn(delay: 0.3)
        .sheet(isPresented: $showLanguage) {
            LanguageSheet(selectedLanguage: Binding(
                get: { coordinator.user.language },
                set: { coordinator.user.language = $0 }
            ))
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
        .slideIn(delay: 0.4)
        .sheet(isPresented: $showHelpCenter) {
            SupportView()
        }
        .sheet(isPresented: $showTerms) {
            TermsSheet()
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button {
            Task {
                await coordinator.signOut()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.right.square")
                    .font(.system(size: 16, weight: .semibold))
                Text("Sign Out")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(AppTheme.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.border, lineWidth: 1.5)
                    )
            )
        }
        .scaleOnPress()
        .slideIn(delay: 0.5)
    }

    // MARK: - App Info

    private var appInfo: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "simcard.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("DXB CONNECT")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1)
            }
            .foregroundColor(AppTheme.textTertiary)

            Text("Version 1.0.0")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
        }
        .padding(.top, 12)
    }
}

// MARK: - Tech Components

struct ProfileStatTech: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .tracking(-0.5)
                .foregroundColor(AppTheme.textPrimary)

            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SectionCardTech<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
                .foregroundColor(AppTheme.textTertiary)

            content()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.border, lineWidth: 1.5)
                        )
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
            action?()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppTheme.gray100)
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(AppTheme.textPrimary)
                        )
                }

                if let value = value {
                    Text(value)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(16)
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
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppTheme.gray100)
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(AppTheme.textPrimary)
        }
        .padding(16)
    }
}

struct SettingsDividerTech: View {
    var body: some View {
        Divider()
            .padding(.leading, 68)
    }
}

// MARK: - Legacy Components (compatibility)

struct ProfileStatItem: View {
    let value: String
    let label: String
    let icon: String
    var body: some View { ProfileStatTech(value: value, label: label.uppercased(), icon: icon) }
}

struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View { SectionCardTech(title: title.uppercased(), content: content) }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    var value: String? = nil
    var badge: String? = nil
    var body: some View { SettingsRowTech(icon: icon, title: title, value: value, badge: badge) }
}

struct SettingsToggle: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isOn: Bool
    var body: some View { SettingsToggleTech(icon: icon, title: title, isOn: $isOn) }
}

struct SettingsDivider: View {
    var body: some View { SettingsDividerTech() }
}

// Compatibility
struct StatItem: View {
    let value: String
    let label: String
    var body: some View { ProfileStatItem(value: value, label: label, icon: "circle.fill") }
}
struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    var value: String? = nil
    var badge: String? = nil
    var body: some View { SettingsRow(icon: icon, title: title, color: color, value: value, badge: badge) }
}
struct ToggleRow: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isOn: Bool
    var body: some View { SettingsToggle(icon: icon, title: title, color: color, isOn: $isOn) }
}
struct ProfileStat: View {
    let value: String
    let label: String
    let icon: String
    var body: some View { ProfileStatItem(value: value, label: label, icon: icon) }
}
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    var value: String? = nil
    var badge: String? = nil
    var body: some View { SettingsRow(icon: icon, title: title, color: color, value: value, badge: badge) }
}
struct ProfileToggleItem: View {
    let icon: String
    let title: String
    let color: Color
    @Binding var isOn: Bool
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

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ProfileSheetHeader(title: "EDIT PROFILE", dismiss: dismiss)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(AppTheme.textPrimary)
                                .frame(width: 100, height: 100)

                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)

                            Button {
                                // Photo picker
                            } label: {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 4)
                            }
                            .offset(x: 36, y: 36)
                        }
                        .padding(.top, 20)

                        VStack(spacing: 16) {
                            ProfileTextField(label: "FULL NAME", text: $name, icon: "person.fill")
                            ProfileTextField(label: "EMAIL", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                            ProfileTextField(label: "PHONE", text: $phone, icon: "phone.fill", keyboardType: .phonePad)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 120)
                }

                // Save Button
                VStack {
                    Button {
                        isSaving = true
                        // Update coordinator data
                        coordinator.user.name = name
                        coordinator.user.email = email
                        coordinator.user.phone = phone

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("SAVE CHANGES")
                                    .font(.system(size: 13, weight: .bold))
                                    .tracking(1.2)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.textPrimary))
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(Color.white.shadow(color: .black.opacity(0.05), radius: 10, y: -5))
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
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "PAYMENT METHODS", dismiss: dismiss)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Existing card
                        PaymentCardRow(
                            brand: "visa",
                            last4: "4242",
                            expiry: "12/27",
                            isDefault: true
                        )

                        // Add new card
                        Button {
                            showAddCard = true
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(AppTheme.border, style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                        .frame(width: 50, height: 34)

                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.textTertiary)
                                }

                                Text("Add New Card")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
            }
        }
        .sheet(isPresented: $showAddCard) {
            AddCardSheet()
        }
    }
}

struct PaymentCardRow: View {
    let brand: String
    let last4: String
    let expiry: String
    let isDefault: Bool

    var body: some View {
        HStack(spacing: 14) {
            // Card icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.gray100)
                    .frame(width: 50, height: 34)

                Image(systemName: brand == "visa" ? "creditcard.fill" : "creditcard")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text("•••• \(last4)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)

                    if isDefault {
                        Text("DEFAULT")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppTheme.textPrimary))
                    }
                }

                Text("Expires \(expiry)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            Button {
                // Edit card
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1.5))
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
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "ADD CARD", dismiss: dismiss)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ProfileTextField(label: "CARD NUMBER", text: $cardNumber, icon: "creditcard.fill", keyboardType: .numberPad)

                        HStack(spacing: 12) {
                            ProfileTextField(label: "EXPIRY", text: $expiry, icon: "calendar")
                            ProfileTextField(label: "CVC", text: $cvc, icon: "lock.fill", keyboardType: .numberPad)
                        }

                        ProfileTextField(label: "NAME ON CARD", text: $name, icon: "person.fill")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }

                VStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("ADD CARD")
                            .font(.system(size: 13, weight: .bold))
                            .tracking(1.2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.textPrimary))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(Color.white.shadow(color: .black.opacity(0.05), radius: 10, y: -5))
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
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "ORDER HISTORY", dismiss: dismiss)

                if coordinator.orderHistory.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(AppTheme.gray100)
                                .frame(width: 80, height: 80)

                            Image(systemName: "bag")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(AppTheme.textTertiary)
                        }

                        VStack(spacing: 8) {
                            Text("No orders yet")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Your purchase history will appear here")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }

                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
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
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

struct OrderRow: View {
    let name: String
    let date: String
    let price: String
    let status: String

    var statusColor: Color {
        status == "Active" ? AppTheme.textPrimary : AppTheme.textTertiary
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.gray100)
                    .frame(width: 48, height: 48)

                Image(systemName: "simcard.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(date)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(price)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text(status)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(statusColor)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 1.5))
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
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "REFER A FRIEND", dismiss: dismiss)

                VStack(spacing: 32) {
                    Spacer()

                    // Icon
                    ZStack {
                        Circle()
                            .fill(AppTheme.gray100)
                            .frame(width: 100, height: 100)

                        Image(systemName: "gift.fill")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: 12) {
                        Text("Give $10, Get $10")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Share your code with friends.\nThey get $10 off, you earn $10 credit!")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                            .multilineTextAlignment(.center)
                    }

                    // Code
                    VStack(spacing: 12) {
                        Text("YOUR CODE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(AppTheme.textTertiary)

                        Button {
                            UIPasteboard.general.string = referralCode
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copied = false
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text(referralCode)
                                    .font(.system(size: 22, weight: .bold))
                                    .tracking(2)
                                    .foregroundColor(AppTheme.textPrimary)

                                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(copied ? .green : AppTheme.textTertiary)
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(AppTheme.border, style: StrokeStyle(lineWidth: 2, dash: [8]))
                            )
                        }
                    }

                    Spacer()

                    // Share button
                    Button {
                        let text = "Use my code \(referralCode) to get $10 off your first DXB Connect eSIM!"
                        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController?.present(av, animated: true)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                            Text("SHARE CODE")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(1.2)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.textPrimary))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Language Sheet

struct LanguageSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLanguage: String

    let languages = ["English", "Français", "العربية", "Español", "Deutsch", "中文", "日本語"]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "LANGUAGE", dismiss: dismiss)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(languages, id: \.self) { language in
                            Button {
                                selectedLanguage = language
                                dismiss()
                            } label: {
                                HStack {
                                    Text(language)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Spacer()

                                    if selectedLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimary)
                                    }
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedLanguage == language ? AppTheme.gray100 : Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(selectedLanguage == language ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
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
            AppTheme.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "APPEARANCE", dismiss: dismiss)

                VStack(spacing: 16) {
                    ForEach(appearances, id: \.0) { appearance in
                        Button {
                            selectedAppearance = appearance.0
                            applyAppearance(appearance.0)
                            coordinator.savePreferences()
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppTheme.gray100)
                                        .frame(width: 48, height: 48)

                                    Image(systemName: appearance.1)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                }

                                Text(appearance.0)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppTheme.textPrimary)

                                Spacer()

                                if selectedAppearance == appearance.0 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                } else {
                                    Circle()
                                        .stroke(AppTheme.border, lineWidth: 2)
                                        .frame(width: 22, height: 22)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedAppearance == appearance.0 ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()
            }
        }
    }

    private func applyAppearance(_ mode: String) {
        let appearanceMode: AppearanceMode
        switch mode {
        case "Dark":
            appearanceMode = .dark
        case "System":
            appearanceMode = .system
        default:
            appearanceMode = .light
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
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileSheetHeader(title: "LEGAL", dismiss: dismiss)

                // Tabs
                HStack(spacing: 0) {
                    ForEach(["Terms", "Privacy"], id: \.self) { tab in
                        let index = tab == "Terms" ? 0 : 1
                        Button {
                            withAnimation { selectedTab = index }
                        } label: {
                            Text(tab)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedTab == index ? AppTheme.textPrimary : AppTheme.textTertiary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    VStack {
                                        Spacer()
                                        Rectangle()
                                            .fill(selectedTab == index ? AppTheme.textPrimary : Color.clear)
                                            .frame(height: 2)
                                    }
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)

                Divider()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if selectedTab == 0 {
                            termsContent
                        } else {
                            privacyContent
                        }
                    }
                    .padding(24)
                }
            }
        }
    }

    private var termsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Terms of Service")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Last updated: February 2026")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)

            Group {
                legalSection(title: "1. Acceptance of Terms", content: "By accessing and using DXB Connect services, you accept and agree to be bound by the terms and conditions of this agreement.")

                legalSection(title: "2. Service Description", content: "DXB Connect provides eSIM services for mobile connectivity. Our eSIMs are designed for travelers and provide data connectivity in supported regions.")

                legalSection(title: "3. User Responsibilities", content: "You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.")

                legalSection(title: "4. Refund Policy", content: "Refunds are available within 24 hours of purchase if the eSIM has not been activated. Once activated, refunds are not available.")
            }
        }
    }

    private var privacyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("Last updated: February 2026")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textTertiary)

            Group {
                legalSection(title: "Information We Collect", content: "We collect information you provide directly, such as name, email, and payment information when you create an account or make a purchase.")

                legalSection(title: "How We Use Information", content: "We use the information to provide and improve our services, process transactions, and communicate with you about your account.")

                legalSection(title: "Data Security", content: "We implement industry-standard security measures to protect your personal information from unauthorized access.")

                legalSection(title: "Your Rights", content: "You have the right to access, correct, or delete your personal information. Contact us at privacy@dxbconnect.com for requests.")
            }
        }
    }

    private func legalSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Text(content)
                .font(.system(size: 14, weight: .regular))
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().stroke(AppTheme.border, lineWidth: 1.5))
            }
            .accessibilityLabel("Fermer")

            Spacer()

            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(1.5)
                .foregroundColor(AppTheme.textTertiary)

            Spacer()

            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

struct ProfileTextField: View {
    let label: String
    @Binding var text: String
    var icon: String = "pencil"
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundColor(AppTheme.textTertiary)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(width: 24)

                TextField("", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.border, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppCoordinator())
}
