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
                colors: [AppColors.accent.opacity(0.08), Color.clear],
                center: .center,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.12))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)

                    Circle()
                        .fill(AppColors.accent)
                        .frame(width: 72, height: 72)

                    Text("S")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: AppSpacing.sm) {
                    Text("SimPass")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Travel Connected")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .opacity(logoOpacity)

                ProgressView()
                    .tint(AppColors.accent)
                    .scaleEffect(1.1)
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
