import SwiftUI
import AuthenticationServices
import DXBCore

struct AuthView: View {
    @Environment(AppState.self) private var appState

    @State private var authMode: AuthMode = .landing
    @State private var email = ""
    @State private var otpCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    enum AuthMode {
        case landing, emailInput, otpVerify
    }

    var body: some View {
        ZStack {
            Image("LoginBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.55)
                .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        logoSection
                            .padding(.top, 100)

                        Spacer(minLength: 50)

                        authContent
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                    }
                    .frame(minHeight: proxy.size.height)
                }
            }

            if isLoading {
                LoadingOverlay(message: loadingMessage)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 24) {
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
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Travel Connected")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .opacity(logoOpacity)
        }
    }

    // MARK: - Auth Content

    @ViewBuilder
    private var authContent: some View {
        switch authMode {
        case .landing:   landingContent
        case .emailInput: emailInputContent
        case .otpVerify: otpVerifyContent
        }
    }

    // MARK: - Landing

    private var landingContent: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Welcome")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Sign in to access your premium eSIMs")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, AppSpacing.sm)

            appleSignInButton

            dividerOr

            Button {
                withAnimation(.spring(response: 0.4)) {
                    authMode = .emailInput
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 15))
                    Text("Continue with Email")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    Capsule()
                        .fill(AppColors.surface)
                        .overlay(
                            Capsule()
                                .stroke(AppColors.borderLight, lineWidth: 0.5)
                        )
                )
            }

            termsText
        }
        .slideIn(delay: 0.1)
    }

    private var appleSignInButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            handleAppleSignIn(result)
        }
        .signInWithAppleButtonStyle(.white)
        .frame(height: 52)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(AppColors.border, lineWidth: 0.5)
        )
    }

    private var dividerOr: some View {
        HStack(spacing: AppSpacing.base) {
            Rectangle().fill(AppColors.border).frame(height: 1)
            Text("or")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
            Rectangle().fill(AppColors.border).frame(height: 1)
        }
    }

    // MARK: - Email Input

    private var emailInputContent: some View {
        VStack(spacing: 24) {
            backButton

            VStack(spacing: 8) {
                Text("Email Sign In")
                    .font(AppFonts.sectionTitle())
                    .foregroundStyle(AppColors.textPrimary)

                Text("We'll send you a verification code")
                    .font(AppFonts.body())
                    .foregroundStyle(AppColors.textSecondary)
            }

            pulseTextField(
                label: "EMAIL",
                placeholder: "your@email.com",
                text: $email,
                keyboardType: .emailAddress,
                contentType: .emailAddress
            )

            if let error = errorMessage { errorBanner(error) }

            Button { Task { await sendOTP() } } label: {
                Text("Send Code")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(email.isEmpty || !email.contains("@"))
            .opacity(email.isEmpty || !email.contains("@") ? 0.5 : 1)
        }
        .slideIn(delay: 0)
    }

    // MARK: - OTP Verify

    private var otpVerifyContent: some View {
        VStack(spacing: 24) {
            backButton

            VStack(spacing: 8) {
                Text("Verification")
                    .font(AppFonts.sectionTitle())
                    .foregroundStyle(AppColors.textPrimary)

                Text("Code sent to \(email)")
                    .font(AppFonts.body())
                    .foregroundStyle(AppColors.textSecondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("VERIFICATION CODE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(AppColors.textTertiary)

                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        let char = index < otpCode.count
                            ? String(otpCode[otpCode.index(otpCode.startIndex, offsetBy: index)])
                            : ""

                        Text(char)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                    .fill(AppColors.surface)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                                    .stroke(
                                        index == otpCode.count ? AppColors.accent : AppColors.border,
                                        lineWidth: index == otpCode.count ? 2 : 1
                                    )
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .overlay(
                    TextField("", text: $otpCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .opacity(0.01)
                        .onChange(of: otpCode) { _, newValue in
                            if newValue.count > 6 {
                                otpCode = String(newValue.prefix(6))
                            }
                        }
                )
            }

            if let error = errorMessage { errorBanner(error) }

            Button { Task { await verifyOTP() } } label: {
                Text("Verify")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(otpCode.count < 6)
            .opacity(otpCode.count < 6 ? 0.5 : 1)

            Button { Task { await sendOTP() } } label: {
                Text("Resend code")
                    .font(AppFonts.tabLabel())
                    .foregroundStyle(AppColors.accent)
            }
        }
        .slideIn(delay: 0)
    }

    // MARK: - Components

    private func pulseTextField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, contentType: UITextContentType? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppColors.textTertiary)

            TextField("", text: text, prompt: Text(placeholder).foregroundColor(AppColors.textTertiary))
                .font(AppFonts.body())
                .foregroundStyle(AppColors.textPrimary)
                .keyboardType(keyboardType)
                .textContentType(contentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(AppSpacing.base)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .fill(AppColors.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        }
    }

    private var backButton: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.4)) {
                    if authMode == .otpVerify {
                        authMode = .emailInput
                        otpCode = ""
                    } else {
                        authMode = .landing
                        email = ""
                    }
                    errorMessage = nil
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColors.error)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(AppSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                .fill(AppColors.error.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous)
                        .stroke(AppColors.error.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var termsText: some View {
        Text("By continuing, you agree to our [Terms of Service](https://simpass.io/terms) and [Privacy Policy](https://simpass.io/privacy)")
            .font(.system(size: 11))
            .foregroundStyle(AppColors.textTertiary)
            .multilineTextAlignment(.center)
            .tint(AppColors.accent)
            .padding(.top, 8)
    }

    private var loadingMessage: String {
        switch authMode {
        case .landing: return "Signing in..."
        case .emailInput: return "Sending code..."
        case .otpVerify: return "Verifying..."
        }
    }

    // MARK: - Actions

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let identityToken = credential.identityToken,
                  let tokenString = String(data: identityToken, encoding: .utf8),
                  let authCodeData = credential.authorizationCode,
                  let authCode = String(data: authCodeData, encoding: .utf8) else {
                errorMessage = "Unable to retrieve Apple credentials"
                return
            }
            let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
                .compactMap { $0 }.joined(separator: " ")
            Task {
                await signInWithApple(identityToken: tokenString, authorizationCode: authCode, email: credential.email, name: fullName.isEmpty ? nil : fullName)
            }
        case .failure(let error):
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                return
            }
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
        }
    }

    private func signInWithApple(identityToken: String, authorizationCode: String, email: String?, name: String?) async {
        isLoading = true
        errorMessage = nil
        do {
            let userInfo = AppleUserInfo(email: email, name: name)
            let response = try await appState.apiService.signInWithApple(identityToken: identityToken, authorizationCode: authorizationCode, user: userInfo)
            isLoading = false
            appState.didSignIn(response: response)
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func sendOTP() async {
        isLoading = true
        errorMessage = nil
        do {
            try await appState.apiService.signInWithEmail(email: email)
            isLoading = false
            withAnimation(.spring(response: 0.4)) { authMode = .otpVerify }
        } catch {
            errorMessage = "Unable to send verification code"
            isLoading = false
        }
    }

    private func verifyOTP() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await appState.apiService.verifyOTP(email: email, otp: otpCode)
            isLoading = false
            appState.didSignIn(response: response)
        } catch {
            errorMessage = "Invalid or expired code"
            isLoading = false
        }
    }
}

#Preview {
    AuthView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
