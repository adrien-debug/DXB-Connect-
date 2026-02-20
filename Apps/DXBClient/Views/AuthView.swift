import SwiftUI
import DXBCore

struct AuthView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()

    private let connectionCities = ["GB", "US", "JP", "AU", "SG", "FR"]

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            // Background world map with connections
            WorldMapView(
                highlightedCodes: connectionCities,
                showConnections: true,
                accentDots: false,
                connectionCodes: connectionCities,
                strokeColor: AppTheme.anthracite,
                strokeOpacity: 0.05,
                dotColor: AppTheme.accent,
                showDubaiPulse: true
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)

                VStack(spacing: 44) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.08))
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(AppTheme.accent.opacity(0.12))
                            .frame(width: 92, height: 92)

                        RoundedRectangle(cornerRadius: 24)
                            .fill(AppTheme.accent)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(Color(hex: "0F172A"))
                            )
                            .pulse(color: AppTheme.accent, radius: 30)
                    }
                    .floating(duration: 3, distance: 8)

                    VStack(spacing: 18) {
                        Text("Global connectivity\nat your fingertips")
                            .font(.system(size: 34, weight: .bold))
                            .tracking(-1)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineSpacing(4)

                        Text("190+ countries. Instant activation.\nNo physical SIM.")
                            .font(.system(size: 15, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineSpacing(5)
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 0) {
                        TrustPill(icon: "bolt.fill", text: "Instant")
                        Spacer()
                        TrustPill(icon: "lock.fill", text: "Secure")
                        Spacer()
                        TrustPill(icon: "globe", text: "190+")
                    }
                    .padding(.horizontal, 32)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        viewModel.showRegisterModal = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Get Started")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .foregroundColor(Color(hex: "0F172A"))
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(AppTheme.accent)
                        )
                    }
                    .pulse(color: AppTheme.accent, radius: 20)
                    .scaleOnPress()

                    Button {
                        viewModel.showLoginModal = true
                    } label: {
                        Text("I already have an account")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.backgroundTertiary)
                            )
                    }
                    .scaleOnPress()
                }
                .padding(.horizontal, 24)

                HStack(spacing: 4) {
                    Text("Terms of Service")
                        .underline()
                        .onTapGesture { viewModel.showTerms = true }
                    Text("&")
                    Text("Privacy Policy")
                        .underline()
                        .onTapGesture { viewModel.showPrivacy = true }
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppTheme.textMuted)
                .padding(.top, 20)
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
                                    .font(.system(size: 42, weight: .medium))
                                    .foregroundColor(AppTheme.accent)
                            }

                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
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
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(Color(hex: "0F172A"))
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
                                .font(.system(size: 14, weight: .medium))
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
                            .font(.system(size: 14, weight: .semibold))
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
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppTheme.gray100))
                    }
                    Spacer()
                    Text("RESET PASSWORD")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                if sent {
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundColor(AppTheme.success)
                        Text("Check your email")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Text("We sent a password reset link to\n\(email)")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.textSecondary)
                            .multilineTextAlignment(.center)
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "0F172A"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.accent))
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    }
                } else {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Forgot your password?")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Enter your email and we'll send\nyou a reset link")
                                .font(.system(size: 15))
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
                                    ProgressView().tint(Color(hex: "0F172A"))
                                } else {
                                    Text("SEND RESET LINK")
                                        .font(.system(size: 14, weight: .bold))
                                        .tracking(1)
                                }
                            }
                            .foregroundColor(Color(hex: "0F172A"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
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
                                    .font(.system(size: 38, weight: .medium))
                                    .foregroundColor(AppTheme.accent)
                            }

                            Text("Create Account")
                                .font(.system(size: 28, weight: .bold))
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
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(Color(hex: "0F172A"))
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
                            .font(.system(size: 14, weight: .semibold))
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
                .font(.system(size: 16, weight: .medium))
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
                .font(.system(size: 16, weight: .medium))
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
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.accent)

            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(AppTheme.backgroundTertiary)
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
