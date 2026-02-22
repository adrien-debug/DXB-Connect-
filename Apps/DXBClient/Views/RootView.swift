import SwiftUI
import DXBCore

struct RootView: View {
    @State private var appState = AppState()
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    var body: some View {
        Group {
            if appState.isCheckingAuth {
                splashView
            } else if appState.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .environment(appState)
        .preferredColorScheme(.dark)
        .task {
            await appState.checkAuth()
        }
    }

    private var splashView: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            RadialGradient(
                colors: [AppColors.accent.opacity(0.05), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.08))
                        .frame(width: 110, height: 110)
                        .blur(radius: 25)

                    Circle()
                        .fill(AppColors.accent)
                        .frame(width: 76, height: 76)
                        .shadow(color: AppColors.accent.opacity(0.3), radius: 20, x: 0, y: 8)

                    Text("S")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("SimPass")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Travel Connected")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .opacity(logoOpacity)

                ProgressView()
                    .tint(AppColors.accent)
                    .scaleEffect(1.0)
                    .padding(.top, AppSpacing.lg)
                    .opacity(logoOpacity)
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    RootView()
}
