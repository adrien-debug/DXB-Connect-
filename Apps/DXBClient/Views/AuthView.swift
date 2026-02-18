import SwiftUI
import DXBCore

struct AuthView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            // Subtle radial accent glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.accent.opacity(0.06), Color.clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 300
                    )
                )
                .frame(width: 600, height: 600)
                .offset(y: -100)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.08))
                            .frame(width: 140, height: 140)

                        RoundedRectangle(cornerRadius: 30)
                            .fill(AppTheme.textPrimary)
                            .frame(width: 100, height: 100)
                            .shadow(color: AppTheme.textPrimary.opacity(0.15), radius: 24, y: 12)

                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }

                    VStack(spacing: 10) {
                        Text("DXB CONNECT")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Connected the moment you land")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        viewModel.showLoginModal = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("LOGIN")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.accent)
                        )
                    }
                    .scaleOnPress()

                    Button {
                        viewModel.showRegisterModal = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 17, weight: .semibold))
                            Text("CREATE ACCOUNT")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(AppTheme.textPrimary)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.surfaceLight)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.border, lineWidth: 1.5)
                                )
                        )
                    }
                    .scaleOnPress()
                }
                .padding(.horizontal, 24)

                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .foregroundColor(AppTheme.textTertiary)

                    HStack(spacing: 4) {
                        Button("Terms of Service") {}
                            .foregroundColor(AppTheme.accent)
                        Text("&")
                            .foregroundColor(AppTheme.textTertiary)
                        Button("Privacy Policy") {}
                            .foregroundColor(AppTheme.accent)
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .padding(.top, 28)
                .padding(.bottom, 48)
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
    }
}

// MARK: - AuthViewModel

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var showLoginModal = false
    @Published var showRegisterModal = false
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
                AppTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentSoft)
                                    .frame(width: 80, height: 80)

                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40, weight: .medium))
                                    .foregroundColor(AppTheme.accent)
                            }

                            Text("Welcome Back")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Sign in to your account")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 20) {
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
                        .padding(.horizontal, 24)

                        Button {
                            Task {
                                await viewModel.login(coordinator: coordinator, dismiss: dismiss)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("LOGIN")
                                        .font(.system(size: 14, weight: .bold))
                                        .tracking(1)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(viewModel.isFormValid ? AppTheme.accent : AppTheme.gray300)
                            )
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.horizontal, 24)

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
                            .background(Circle().fill(AppTheme.surfaceHeavy))
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
                AppTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.accentSoft)
                                    .frame(width: 80, height: 80)

                                Image(systemName: "person.badge.plus.fill")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(AppTheme.accent)
                            }

                            Text("Create Account")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("Join DXB Connect today")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .padding(.top, 24)

                        VStack(spacing: 16) {
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

                            VStack(alignment: .leading, spacing: 8) {
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
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.error)
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        Button {
                            Task {
                                await viewModel.register(coordinator: coordinator, dismiss: dismiss)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("CREATE ACCOUNT")
                                        .font(.system(size: 14, weight: .bold))
                                        .tracking(1)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(viewModel.isFormValid ? AppTheme.accent : AppTheme.gray300)
                            )
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                        .padding(.horizontal, 24)

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
                            .background(Circle().fill(AppTheme.surfaceHeavy))
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
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundColor(AppTheme.textTertiary)

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)
                .textContentType(textContentType)
                .autocapitalization(.none)
                .keyboardType(keyboardType)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isFocused ? AppTheme.accentSoft : AppTheme.surfaceLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundColor(AppTheme.textTertiary)

            SecureField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium))
                .textContentType(isNew ? .newPassword : .password)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isFocused ? AppTheme.accentSoft : AppTheme.surfaceLight)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isFocused ? AppTheme.accent : AppTheme.border, lineWidth: isFocused ? 2 : 1)
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
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
