import SwiftUI
import DXBCore

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    @State private var showSignOutConfirm = false
    @State private var isSigningOut = false
    @State private var showSupport = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    profileHeader.slideIn(delay: 0)
                    membershipCard.slideIn(delay: 0.05)
                    settingsSections.slideIn(delay: 0.1)
                    signOutButton.slideIn(delay: 0.15)
                    appInfo
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.base)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showSupport) { SupportView() }
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirm) {
            Button("Sign Out", role: .destructive) { Task { await signOut() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.accent)
                    .frame(width: 68, height: 68)
                    .shadow(color: AppColors.accent.opacity(0.2), radius: 12, x: 0, y: 4)

                Text(userInitials)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }

            VStack(spacing: 5) {
                Text(appState.currentUser?.name ?? "User")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(appState.currentUser?.email ?? "")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }

            if let tier = appState.subscription?.plan {
                tierBadge(tier)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .pulseCard(glow: true)
    }

    private var userInitials: String {
        let name = appState.currentUser?.name ?? ""
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else if !name.isEmpty {
            return String(name.prefix(2)).uppercased()
        }
        return "?"
    }

    private func tierBadge(_ tier: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: AppTheme.tierIcon(tier))
                .font(.system(size: 12))
            Text(tier.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.5)
        }
        .foregroundStyle(AppTheme.tierColor(tier))
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(AppTheme.tierColor(tier).opacity(0.12))
                .overlay(Capsule().stroke(AppTheme.tierColor(tier).opacity(0.2), lineWidth: 1))
        )
    }

    // MARK: - Membership

    private var membershipCard: some View {
        NavigationLink { SubscriptionView() } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .fill(AppColors.accent.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(appState.subscription != nil ? "My Subscription" : "Become a Member")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(appState.subscription != nil ? "Manage your plan" : "Up to -30% on eSIMs")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .bentoCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Settings

    private var settingsSections: some View {
        VStack(spacing: AppSpacing.base) {
            settingsGroup(title: "ACCOUNT", items: [
                SettingsItem(icon: "person.fill", title: "Personal Information", color: AppColors.accent, action: .none),
                SettingsItem(icon: "bell.fill", title: "Notifications", color: AppColors.accent, action: .openSettings),
                SettingsItem(icon: "lock.fill", title: "Security", color: AppColors.accent, action: .none),
            ])

            settingsGroup(title: "SUPPORT", items: [
                SettingsItem(icon: "questionmark.circle.fill", title: "Help Center", color: AppColors.accent, action: .showSupport),
                SettingsItem(icon: "envelope.fill", title: "Contact Us", color: AppColors.accent, action: .email("support@simpass.io")),
                SettingsItem(icon: "doc.text.fill", title: "Terms of Service", color: AppColors.textSecondary, action: .openURL("https://simpass.io/terms")),
                SettingsItem(icon: "hand.raised.fill", title: "Privacy Policy", color: AppColors.textSecondary, action: .openURL("https://simpass.io/privacy")),
            ])
        }
    }

    private func settingsGroup(title: String, items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppColors.textTertiary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    settingsRow(item)

                    if index < items.count - 1 {
                        Divider()
                            .background(AppColors.border)
                            .padding(.leading, 56)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 0.5)
                    )
            )
        }
    }

    private func settingsRow(_ item: SettingsItem) -> some View {
        Button {
            handleSettingsAction(item.action)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .fill(item.color.opacity(0.08))
                        .frame(width: 32, height: 32)

                    Image(systemName: item.icon)
                        .font(.system(size: 14))
                        .foregroundStyle(item.color)
                }

                Text(item.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.horizontal, AppSpacing.base)
            .padding(.vertical, 11)
        }
    }

    private func handleSettingsAction(_ action: SettingsAction) {
        switch action {
        case .none:
            break
        case .openURL(let urlString):
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        case .email(let address):
            if let url = URL(string: "mailto:\(address)") {
                UIApplication.shared.open(url)
            }
        case .openSettings:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .showSupport:
            showSupport = true
        }
    }

    // MARK: - Sign Out

    private var signOutButton: some View {
        Button { showSignOutConfirm = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppColors.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.error.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.error.opacity(0.1), lineWidth: 0.5)
                    )
            )
        }
    }

    private var appInfo: some View {
        VStack(spacing: 6) {
            Text("SimPass v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
            Text("Made with ❤️ in Dubai")
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textMuted)
        }
        .padding(.top, 8)
    }

    private func signOut() async {
        isSigningOut = true
        await appState.signOut()
    }
}

enum SettingsAction {
    case none
    case openURL(String)
    case email(String)
    case openSettings
    case showSupport
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    var action: SettingsAction = .none
}

#Preview {
    NavigationStack { ProfileView() }
        .environment(AppState())
        .preferredColorScheme(.dark)
}
