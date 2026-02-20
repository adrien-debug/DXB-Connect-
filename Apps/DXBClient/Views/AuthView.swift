import SwiftUI
import DXBCore

struct AuthView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()

    private typealias BankingColors = AppTheme.Banking.Colors
    private typealias BankingTypo = AppTheme.Banking.Typography
    private typealias BankingRadius = AppTheme.Banking.Radius
    private typealias BankingSpacing = AppTheme.Banking.Spacing

    private let connectionCities = ["GB", "US", "JP", "AU", "SG", "FR"]

    var body: some View {
        ZStack {
            BankingColors.backgroundPrimary
                .ignoresSafeArea()

            WorldMapView(
                highlightedCodes: connectionCities,
                showConnections: true,
                accentDots: false,
                connectionCodes: connectionCities,
                strokeColor: BankingColors.textOnDarkMuted,
                strokeOpacity: 0.15,
                dotColor: BankingColors.accent,
                showDubaiPulse: true
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)

                VStack(spacing: BankingSpacing.xxxl) {
                    ZStack {
                        Circle()
                            .fill(BankingColors.accent.opacity(0.08))
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(BankingColors.accent.opacity(0.15))
                            .frame(width: 92, height: 92)

                        RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                            .fill(BankingColors.accent)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(BankingColors.backgroundPrimary)
                            )
                            .pulse(color: BankingColors.accent, radius: 30)
                    }
                    .floating(duration: 3, distance: BankingSpacing.sm)

                    VStack(spacing: BankingSpacing.lg) {
                        Text("Global connectivity\nat your fingertips")
                            .font(BankingTypo.heroAmount())
                            .multilineTextAlignment(.center)
                            .foregroundColor(BankingColors.textOnDarkPrimary)
                            .lineSpacing(BankingSpacing.xs)

                        Text("190+ countries. Instant activation.\nNo physical SIM.")
                            .font(BankingTypo.body())
                            .multilineTextAlignment(.center)
                            .foregroundColor(BankingColors.textOnDarkMuted)
                            .lineSpacing(5)
                    }
                    .padding(.horizontal, BankingSpacing.lg)

                    HStack(spacing: 0) {
                        TrustPill(icon: "bolt.fill", text: "Instant")
                        Spacer()
                        TrustPill(icon: "lock.fill", text: "Secure")
                        Spacer()
                        TrustPill(icon: "globe", text: "190+")
                    }
                    .padding(.horizontal, BankingSpacing.xxl)
                }

                Spacer()

                VStack(spacing: BankingSpacing.lg) {
                    Button {
                        viewModel.showRegisterModal = true
                    } label: {
                        HStack(spacing: BankingSpacing.sm) {
                            Text("Get Started")
                                .font(BankingTypo.button())
                            Image(systemName: "arrow.right")
                                .font(BankingTypo.button())
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .foregroundColor(BankingColors.backgroundPrimary)
                        .background(
                            RoundedRectangle(cornerRadius: CGFloat(BankingRadius.card))
                                .fill(
                                    LinearGradient(
                                        colors: [BankingColors.accent, BankingColors.accentLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    }
                    .pulse(color: AppTheme.accent, radius: AppTheme.Spacing.lg)
                    .scaleOnPress()

                    Button {
                        viewModel.showLoginModal = true
                    } label: {
                        Text("I already have an account")
                            .font(AppTheme.Typography.buttonMedium())
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .fill(AppTheme.surface2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                            .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                                    )
                            )
                    }
                    .scaleOnPress()

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("Terms of Service")
                            .underline()
                            .onTapGesture { viewModel.showTerms = true }
                        Text("&")
                        Text("Privacy Policy")
                            .underline()
                            .onTapGesture { viewModel.showPrivacy = true }
                    }
                    .font(AppTheme.Typography.navTitle())
                    .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                        .fill(AppTheme.surface2.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.xl)
                                .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.8)
                        )
                )
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $viewModel.showLoginModal) {
            LoginModalView()
                .environmentObject(coordinator)
        }
        .sheet(isPresented: $viewModel.showRegisterModal) {
            RegisterModalView()
                .environmentObject(coordinator)
        }
        .sheet(isPresented: $viewModel.showTerms) {
            TermsSheet()
        }
        .sheet(isPresented: $viewModel.showPrivacy) {
            TermsSheet()
        }
    }
}

// MARK: - AuthViewModel

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var showLoginModal = false
    @Published var showRegisterModal = false
    @Published var showTerms = false
    @Published var showPrivacy = false
}

// MARK: - Login Modal

struct LoginModalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundSecondary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        VStack(spacing: AppTheme.Spacing.base) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accent.opacity(0.08))
                                    .frame(width: 88, height: 88)

                                Image(systemName: "person.circle.fill")
                                    .font(AppTheme.Typography.icon(size: 42))
                                    .foregroundColor(AppTheme.accent)
                            }

                            Text("Welcome Back")
                                .font(AppTheme.Typography.sectionTitle())
                                .tracking(-0.3)
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Sign in to your account")
                                .font(AppTheme.Typography.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, AppTheme.Spacing.xxl)

                        VStack(spacing: AppTheme.Spacing.lg) {
                            AuthTextField(
                                label: "EMAIL",
                                placeholder: "you@example.com",
                                text: $viewModel.email,
                                isFocused: focusedField == .email,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress
                            )
                            .focused($focusedField, equals: .email)

                            AuthSecureField(
                                label: "PASSWORD",
                                placeholder: "Enter your password",
                                text: $viewModel.password,
                                isFocused: focusedField == .password
                            )
                            .focused($focusedField, equals: .password)
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        Button {
                            Task {
                                await viewModel.login(coordinator: coordinator, dismiss: dismiss)
                            }
                        } label: {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("LOGIN")
                                        .font(AppTheme.Typography.button())
                                        .tracking(1)
                                    Image(systemName: "arrow.right")
                                        .font(AppTheme.Typography.button())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(AppTheme.anthracite)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .fill(viewModel.isFormValid ? AppTheme.accent : AppTheme.border)
                            )
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        Button {
                            viewModel.showForgotPassword = true
                        } label: {
                            Text("Forgot password?")
                                .font(AppTheme.Typography.tabLabel())
                                .foregroundColor(AppTheme.accent)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(AppTheme.Typography.button())
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.gray100))
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $viewModel.showForgotPassword) {
                ForgotPasswordSheet()
                    .environmentObject(coordinator)
            }
        }
    }
}

// MARK: - Forgot Password Sheet

struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var email = ""
    @State private var isSending = false
    @State private var sent = false
    @State private var showError = false
    @State private var errorMessage = ""

    var isValidEmail: Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(AppTheme.Typography.button())
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.gray100))
                    }
                    Spacer()
                    Text("RESET PASSWORD")
                        .font(AppTheme.Typography.navTitle())
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)

                Spacer()

                if sent {
                    VStack(spacing: AppTheme.Spacing.base) {
                        Image(systemName: "envelope.circle.fill")
                            .font(AppTheme.Typography.display())
                            .foregroundColor(AppTheme.success)
                        Text("Check your email")
                            .font(AppTheme.Typography.sectionTitle())
                            .foregroundColor(AppTheme.textPrimary)
                        Text("We sent a password reset link to\n\(email)")
                            .font(AppTheme.Typography.body())
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(AppTheme.Typography.buttonMedium())
                                .foregroundColor(AppTheme.anthracite)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.accent))
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    }
                } else {
                    VStack(spacing: 24) {
                        VStack(spacing: AppTheme.Spacing.sm) {
                            Text("Forgot your password?")
                                .font(AppTheme.Typography.sectionTitle())
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Enter your email and we'll send\nyou a reset link")
                                .font(AppTheme.Typography.body())
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                        }

                        AuthTextField(
                            label: "EMAIL",
                            placeholder: "you@example.com",
                            text: $email,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )
                        .padding(.horizontal, 24)

                        Button {
                            Task {
                                isSending = true
                                do {
                                    try await coordinator.currentAPIService.requestPasswordReset(email: email)
                                    HapticFeedback.success()
                                    sent = true
                                } catch {
                                    errorMessage = "Unable to send reset link. Please try again."
                                    showError = true
                                    appLogError(error, message: "Password reset request failed", category: .auth)
                                }
                                isSending = false
                            }
                        } label: {
                            HStack {
                                if isSending {
                                    ProgressView().tint(AppTheme.anthracite)
                                } else {
                                    Text("SEND RESET LINK")
                                        .font(AppTheme.Typography.button())
                                        .tracking(1)
                                }
                            }
                            .foregroundColor(AppTheme.anthracite)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .fill(isValidEmail ? AppTheme.accent : AppTheme.border)
                            )
                        }
                        .disabled(!isValidEmail || isSending)
                        .padding(.horizontal, 24)
                    }
                }

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Register Modal

struct RegisterModalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = RegisterViewModel()
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, confirmPassword }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundSecondary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppTheme.Spacing.xxl) {
                        VStack(spacing: AppTheme.Spacing.base) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accent.opacity(0.08))
                                    .frame(width: 88, height: 88)

                                Image(systemName: "person.badge.plus.fill")
                                    .font(AppTheme.Typography.icon(size: 38))
                                    .foregroundColor(AppTheme.accent)
                            }

                            Text("Create Account")
                                .font(AppTheme.Typography.sectionTitle())
                                .tracking(-0.3)
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Join DXB Connect today")
                                .font(AppTheme.Typography.body())
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.top, AppTheme.Spacing.xxl)

                        VStack(spacing: AppTheme.Spacing.base) {
                            AuthTextField(
                                label: "FULL NAME",
                                placeholder: "John Doe",
                                text: $viewModel.name,
                                isFocused: focusedField == .name,
                                textContentType: .name
                            )
                            .focused($focusedField, equals: .name)

                            AuthTextField(
                                label: "EMAIL",
                                placeholder: "you@example.com",
                                text: $viewModel.email,
                                isFocused: focusedField == .email,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress
                            )
                            .focused($focusedField, equals: .email)

                            AuthSecureField(
                                label: "PASSWORD",
                                placeholder: "Min 8 characters",
                                text: $viewModel.password,
                                isFocused: focusedField == .password,
                                isNew: true
                            )
                            .focused($focusedField, equals: .password)

                            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                                AuthSecureField(
                                    label: "CONFIRM PASSWORD",
                                    placeholder: "Re-enter password",
                                    text: $viewModel.confirmPassword,
                                    isFocused: focusedField == .confirmPassword,
                                    isNew: true
                                )
                                .focused($focusedField, equals: .confirmPassword)

                                if !viewModel.confirmPassword.isEmpty && viewModel.password != viewModel.confirmPassword {
                                    Text("Passwords don't match")
                                        .font(AppTheme.Typography.small())
                                        .foregroundColor(AppTheme.error)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        Button {
                            Task {
                                await viewModel.register(coordinator: coordinator, dismiss: dismiss)
                            }
                        } label: {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("CREATE ACCOUNT")
                                        .font(AppTheme.Typography.button())
                                        .tracking(1)
                                    Image(systemName: "arrow.right")
                                        .font(AppTheme.Typography.button())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(AppTheme.anthracite)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                    .fill(viewModel.isFormValid ? AppTheme.accent : AppTheme.border)
                            )
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.horizontal, AppTheme.Spacing.xl)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(AppTheme.Typography.button())
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.gray100))
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Reusable Auth Fields

struct AuthTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.small())
                .tracking(1.2)
                .foregroundColor(AppTheme.textSecondary)

            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.bodyMedium())
                .foregroundColor(AppTheme.textPrimary)
                .textContentType(textContentType)
                .autocapitalization(.none)
                .keyboardType(keyboardType)
                .padding(AppTheme.Spacing.base)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .fill(isFocused ? AppTheme.accentSoft : AppTheme.backgroundTertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(isFocused ? AppTheme.accent : AppTheme.border, lineWidth: isFocused ? 2 : 1)
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

struct AuthSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isFocused: Bool = false
    var isNew: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.small())
                .tracking(1.2)
                .foregroundColor(AppTheme.textSecondary)

            SecureField(placeholder, text: $text)
                .font(AppTheme.Typography.bodyMedium())
                .foregroundColor(AppTheme.textPrimary)
                .textContentType(isNew ? .newPassword : .password)
                .padding(AppTheme.Spacing.base)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                        .fill(isFocused ? AppTheme.accentSoft : AppTheme.backgroundTertiary)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .stroke(isFocused ? AppTheme.accent : AppTheme.border, lineWidth: isFocused ? 2 : 1)
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Trust Pill

struct TrustPill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(AppTheme.Typography.label())
                .foregroundColor(AppTheme.accent)

            Text(text)
                .font(AppTheme.Typography.navTitle())
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(
            Capsule()
                .fill(AppTheme.surface2.opacity(0.9))
                .overlay(
                    Capsule()
                        .stroke(AppTheme.border.opacity(0.5), lineWidth: 0.6)
                )
        )
    }
}

// MARK: - Login ViewModel

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showForgotPassword = false

    var isFormValid: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let isValidEmail = email.range(of: emailRegex, options: .regularExpression) != nil
        return isValidEmail && password.count >= 6
    }

    func login(coordinator: AppCoordinator, dismiss: DismissAction) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await coordinator.signInWithPassword(email: email, password: password)
            HapticFeedback.success()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Register ViewModel

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    var isFormValid: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let isValidEmail = email.range(of: emailRegex, options: .regularExpression) != nil
        return !name.isEmpty && isValidEmail && password.count >= 8 && password == confirmPassword
    }

    func register(coordinator: AppCoordinator, dismiss: DismissAction) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await coordinator.signUpWithPassword(email: email, password: password, name: name)
            HapticFeedback.success()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AppCoordinator())
}
