import SwiftUI
import AuthenticationServices
import DXBCore

struct AuthView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 16) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("DXB Connect")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Connected the moment you land")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Auth Options
                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        Task {
                            await viewModel.handleAppleSignIn(result: result, coordinator: coordinator)
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    
                    Button {
                        viewModel.showEmailAuth = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope")
                            Text("Continue with Email")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 32)
                
                // Terms
                Text("By continuing, you agree to our Terms & Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Spacer()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $viewModel.showEmailAuth) {
                EmailAuthView()
                    .environmentObject(coordinator)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
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
                coordinator.isAuthenticated = true
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

// MARK: - Email Auth View

struct EmailAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = EmailAuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if !viewModel.otpSent {
                    // Email input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        
                        TextField("your@email.com", text: $viewModel.email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    Button {
                        Task {
                            await viewModel.sendOTP(coordinator: coordinator)
                        }
                    } label: {
                        Text("Send Code")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(viewModel.email.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.email.isEmpty || viewModel.isLoading)
                } else {
                    // OTP input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter 6-digit code sent to \(viewModel.email)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("000000", text: $viewModel.otp)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.oneTimeCode)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .font(.title2)
                    }
                    
                    Button {
                        Task {
                            await viewModel.verifyOTP(coordinator: coordinator, dismiss: dismiss)
                        }
                    } label: {
                        Text("Verify")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(viewModel.otp.count == 6 ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.otp.count != 6 || viewModel.isLoading)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sign in with Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

@MainActor
final class EmailAuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var otp = ""
    @Published var otpSent = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    func sendOTP(coordinator: AppCoordinator) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await coordinator.currentAPIService.signInWithEmail(email: email)
            otpSent = true
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
            coordinator.isAuthenticated = true
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
