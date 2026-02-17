import SwiftUI
import AuthenticationServices
import DXBCore

struct AuthView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            // Pure white background
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo & Title
                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(AppTheme.textPrimary)
                            .frame(width: 100, height: 100)

                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .slideIn(delay: 0)

                    VStack(spacing: 10) {
                        Text("DXB CONNECT")
                            .font(.system(size: 32, weight: .bold))
                            .tracking(1)
                            .foregroundColor(AppTheme.textPrimary)

                        Text("Connected the moment you land")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .slideIn(delay: 0.1)
                }

                Spacer()

                // Auth Options
                VStack(spacing: 14) {
                    // Apple Sign In
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        Task {
                            await viewModel.handleAppleSignIn(result: result, coordinator: coordinator)
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 56)
                    .cornerRadius(16)

                    // Email Sign In
                    Button {
                        viewModel.showEmailAuth = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 17, weight: .semibold))
                            Text("CONTINUE WITH EMAIL")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(AppTheme.textPrimary)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.border, lineWidth: 1.5)
                        )
                    }
                    .scaleOnPress()
                }
                .padding(.horizontal, 24)
                .slideIn(delay: 0.2)

                // Terms
                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .foregroundColor(AppTheme.textTertiary)

                    HStack(spacing: 4) {
                        Button("Terms of Service") {}
                            .foregroundColor(AppTheme.textPrimary)
                        Text("&")
                            .foregroundColor(AppTheme.textTertiary)
                        Button("Privacy Policy") {}
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                .font(.system(size: 12, weight: .medium))
                .padding(.top, 28)
                .padding(.bottom, 48)
                .slideIn(delay: 0.3)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .sheet(isPresented: $viewModel.showEmailAuth) {
            EmailAuthSheet()
                .environmentObject(coordinator)
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.3)
                        Text("Signing in...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppTheme.textPrimary)
                    )
                }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showEmailAuth = false

    func handleAppleSignIn(result: Result<ASAuthorization, Error>, coordinator: AppCoordinator) async {
        isLoading = true
        defer { isLoading = false }

        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                showErrorAlert("Invalid credentials")
                return
            }

            guard let identityToken = appleIDCredential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8),
                  let authCode = appleIDCredential.authorizationCode,
                  let authCodeString = String(data: authCode, encoding: .utf8) else {
                showErrorAlert("Failed to get authentication data")
                return
            }

            let userInfo = AppleUserInfo(
                email: appleIDCredential.email,
                name: appleIDCredential.fullName?.givenName
            )

            do {
                _ = try await coordinator.currentAPIService.signInWithApple(
                    identityToken: tokenString,
                    authorizationCode: authCodeString,
                    user: userInfo
                )
                await coordinator.onAuthSuccess(
                    email: appleIDCredential.email,
                    name: appleIDCredential.fullName?.givenName
                )
            } catch {
                showErrorAlert(error.localizedDescription)
            }

        case .failure(let error):
            showErrorAlert(error.localizedDescription)
        }
    }

    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Email Auth Sheet

struct EmailAuthSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = EmailAuthViewModel()
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isOTPFocused: Bool

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .stroke(AppTheme.border, lineWidth: 1.5)
                            )
                    }

                    Spacer()

                    if viewModel.otpSent {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.otpSent = false
                                viewModel.otp = ""
                            }
                        } label: {
                            Text("CHANGE EMAIL")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.5)
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Title
                VStack(spacing: 10) {
                    Text(viewModel.otpSent ? "VERIFY CODE" : "SIGN IN")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.8)
                        .foregroundColor(AppTheme.textTertiary)

                    Text(viewModel.otpSent ? "Enter verification code" : "Enter your email")
                        .font(.system(size: 28, weight: .bold))
                        .tracking(-0.5)
                        .foregroundColor(AppTheme.textPrimary)

                    if viewModel.otpSent {
                        Text("Code sent to \(viewModel.email)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
                .padding(.top, 32)
                .padding(.bottom, 40)

                if !viewModel.otpSent {
                    // Email Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("EMAIL")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundColor(AppTheme.textTertiary)

                        TextField("you@example.com", text: $viewModel.email)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .focused($isEmailFocused)
                            .padding(18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isEmailFocused ? AppTheme.textPrimary : AppTheme.border, lineWidth: isEmailFocused ? 2 : 1.5)
                            )
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Send Button
                    Button {
                        Task {
                            await viewModel.sendOTP(coordinator: coordinator)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("SEND CODE")
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
                                .fill(viewModel.isValidEmail ? AppTheme.textPrimary : AppTheme.gray300)
                        )
                    }
                    .disabled(!viewModel.isValidEmail || viewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)

                } else {
                    // OTP Input
                    VStack(spacing: 24) {
                        HStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                OTPDigitBox(
                                    digit: viewModel.otpDigit(at: index),
                                    isFocused: isOTPFocused && index == viewModel.otp.count
                                )
                            }
                        }
                        .onTapGesture {
                            isOTPFocused = true
                        }

                        // Hidden text field for OTP input
                        TextField("", text: $viewModel.otp)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .focused($isOTPFocused)
                            .frame(width: 1, height: 1)
                            .opacity(0)
                            .onChange(of: viewModel.otp) { oldValue, newValue in
                                viewModel.otp = String(newValue.prefix(6).filter { $0.isNumber })
                            }

                        Button {
                            Task {
                                await viewModel.sendOTP(coordinator: coordinator)
                            }
                        } label: {
                            Text("Resend code")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Verify Button
                    Button {
                        Task {
                            await viewModel.verifyOTP(coordinator: coordinator, dismiss: dismiss)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("VERIFY")
                                    .font(.system(size: 14, weight: .bold))
                                    .tracking(1)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.otp.count == 6 ? AppTheme.textPrimary : AppTheme.gray300)
                        )
                    }
                    .disabled(viewModel.otp.count != 6 || viewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isEmailFocused = true
            }
        }
    }
}

// MARK: - OTP Digit Box

struct OTPDigitBox: View {
    let digit: String
    let isFocused: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .stroke(isFocused ? AppTheme.textPrimary : AppTheme.border, lineWidth: isFocused ? 2 : 1.5)
                .frame(width: 48, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(digit.isEmpty ? Color.white : AppTheme.gray50)
                )

            Text(digit)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

// Compatibility alias
struct EmailAuthView: View {
    var body: some View { EmailAuthSheet() }
}

@MainActor
final class EmailAuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var otp = ""
    @Published var otpSent = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    var isValidEmail: Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: emailRegex, options: .regularExpression) != nil
    }

    func otpDigit(at index: Int) -> String {
        guard index < otp.count else { return "" }
        let idx = otp.index(otp.startIndex, offsetBy: index)
        return String(otp[idx])
    }

    func sendOTP(coordinator: AppCoordinator) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await coordinator.currentAPIService.signInWithEmail(email: email)
            withAnimation(.spring(response: 0.4)) {
                otpSent = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    func verifyOTP(coordinator: AppCoordinator, dismiss: DismissAction) async {
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await coordinator.currentAPIService.verifyOTP(email: email, otp: otp)
            await coordinator.onAuthSuccess(email: email)
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
