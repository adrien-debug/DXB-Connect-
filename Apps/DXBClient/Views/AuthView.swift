import SwiftUI
import AuthenticationServices
import DXBCore

struct AuthView: View {
    @Environment(AppState.self) private var appState

    @State private var authMode: AuthMode = .landing
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var isRegistering = false

    enum AuthMode {
        case landing, emailAuth
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
        case .emailAuth: emailAuthContent
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
                    isRegistering = false
                    authMode = .emailAuth
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

    // MARK: - Email Auth (Login / Register)

    private var emailAuthContent: some View {
        VStack(spacing: 24) {
            backButton

            VStack(spacing: 8) {
                Text(isRegistering ? "Create Account" : "Sign In")
                    .font(AppFonts.sectionTitle())
                    .foregroundStyle(AppColors.textPrimary)

                Text(isRegistering ? "Enter your details to get started" : "Enter your credentials")
                    .font(AppFonts.body())
                    .foregroundStyle(AppColors.textSecondary)
            }

            if isRegistering {
                pulseTextField(
                    label: "NAME",
                    placeholder: "Your name",
                    text: $name,
                    keyboardType: .default,
                    contentType: .name,
                    isSecure: false
                )
            }

            pulseTextField(
                label: "EMAIL",
                placeholder: "your@email.com",
                text: $email,
                keyboardType: .emailAddress,
                contentType: .emailAddress,
                isSecure: false
            )

            pulseTextField(
                label: "PASSWORD",
                placeholder: "Min. 8 characters",
                text: $password,
                keyboardType: .default,
                contentType: isRegistering ? .newPassword : .password,
                isSecure: true
            )

            if let error = errorMessage { errorBanner(error) }

            Button { Task { await submitAuth() } } label: {
                Text(isRegistering ? "Create Account" : "Sign In")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)

            Button {
                withAnimation(.spring(response: 0.3)) {
                    isRegistering.toggle()
                    errorMessage = nil
                }
            } label: {
                HStack(spacing: 4) {
                    Text(isRegistering ? "Already have an account?" : "Don't have an account?")
                        .foregroundStyle(AppColors.textSecondary)
                    Text(isRegistering ? "Sign In" : "Sign Up")
                        .foregroundStyle(AppColors.accent)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 14))
            }
        }
        .slideIn(delay: 0)
    }

    private var isFormValid: Bool {
        let emailOk = !email.isEmpty && email.contains("@")
        let passwordOk = password.count >= 8
        if isRegistering {
            return emailOk && passwordOk && !name.isEmpty
        }
        return emailOk && passwordOk
    }

    // MARK: - Components

    private func pulseTextField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, contentType: UITextContentType? = nil, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundStyle(AppColors.textTertiary)

            Group {
                if isSecure {
                    SecureField("", text: text, prompt: Text(placeholder).foregroundColor(AppColors.textTertiary))
                } else {
                    TextField("", text: text, prompt: Text(placeholder).foregroundColor(AppColors.textTertiary))
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .font(AppFonts.body())
            .foregroundStyle(AppColors.textPrimary)
            .textContentType(contentType)
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
                    authMode = .landing
                    email = ""
                    password = ""
                    name = ""
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
        case .emailAuth: return isRegistering ? "Creating account..." : "Signing in..."
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

    private func submitAuth() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: AuthResponse
            if isRegistering {
                response = try await appState.apiService.signUpWithPassword(email: email, password: password, name: name)
            } else {
                response = try await appState.apiService.signInWithPassword(email: email, password: password)
            }
            isLoading = false
            appState.didSignIn(response: response)
        } catch let apiError as APIError {
            switch apiError {
            case .serverError(_, let message):
                errorMessage = message
            case .unauthorized:
                errorMessage = "Invalid email or password"
            default:
                errorMessage = apiError.localizedDescription
            }
            isLoading = false
        } catch {
            errorMessage = isRegistering ? "Registration failed. Please try again." : "Invalid email or password."
            isLoading = false
        }
    }
}

#Preview {
    AuthView()
        .environment(AppState())
        .preferredColorScheme(.dark)
}
