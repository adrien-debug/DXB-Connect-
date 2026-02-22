import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab: Tab = .home

    enum Tab: String, CaseIterable {
        case home, esims, rewards, profile

        var icon: String {
            switch self {
            case .home:    return "house.fill"
            case .esims:   return "simcard.fill"
            case .rewards: return "star.fill"
            case .profile: return "person.fill"
            }
        }

        var label: String {
            switch self {
            case .home:    return "Home"
            case .esims:   return "eSIMs"
            case .rewards: return "Rewards"
            case .profile: return "Profile"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    NavigationStack { DashboardView() }
                case .esims:
                    NavigationStack { MyESIMsView() }
                case .rewards:
                    NavigationStack { RewardsHubView() }
                case .profile:
                    NavigationStack { ProfileView() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 46)
            }

            floatingTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    private var floatingTabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppColors.border)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            if selectedTab != tab {
                                HapticFeedback.light()
                                selectedTab = tab
                            }
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? AppColors.accent : AppColors.textTertiary)

                            Text(tab.label)
                                .font(.system(size: 9, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? AppColors.accent : AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .accessibilityLabel(tab.label)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .environment(\.colorScheme, .dark)
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
