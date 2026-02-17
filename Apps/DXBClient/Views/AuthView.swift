import SwiftUI
import DXBCore

struct AuthView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.white, Color(hex: "F8F9FA")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(AppTheme.textPrimary)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
                    
                    VStack(spacing: 10) {
                        Text("DXB CONNECT")
                            .font(.system(size: 32, weight: .bold))
                            .tracking(1)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Connected the moment you land")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }
                
                Spacer()
                
                // Auth Buttons
                VStack(spacing: 14) {
                    // Login Button
                    Button {
                        viewModel.showLoginModal = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 17, weight: .semibold))
                            Text("LOGIN")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppTheme.textPrimary)
                        )
                    }
                    
                    // Register Button
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
                                .stroke(AppTheme.border, lineWidth: 1.5)
                        )
                    }
                }
                .padding(.horizontal, 24)
                
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
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Sign in to your account")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("EMAIL")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)
                                
                                TextField("you@example.com", text: $viewModel.email)
                                    .font(.system(size: 16, weight: .medium))
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .email ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                    )
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PASSWORD")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)
                                
                                SecureField("Enter your password", text: $viewModel.password)
                                    .font(.system(size: 16, weight: .medium))
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .password ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                    )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Login Button
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
                                    .fill(viewModel.isFormValid ? AppTheme.textPrimary : AppTheme.gray300)
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
                            .background(Circle().stroke(AppTheme.border, lineWidth: 1.5))
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
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Create Account")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text("Join DXB Connect today")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(spacing: 16) {
                            // Name
                            VStack(alignment: .leading, spacing: 8) {
                                Text("FULL NAME")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)
                                
                                TextField("John Doe", text: $viewModel.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .textContentType(.name)
                                    .focused($focusedField, equals: .name)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .name ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                    )
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("EMAIL")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)
                                
                                TextField("you@example.com", text: $viewModel.email)
                                    .font(.system(size: 16, weight: .medium))
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .email ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                    )
                            }
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PASSWORD")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)
                                
                                SecureField("Min 8 characters", text: $viewModel.password)
                                    .font(.system(size: 16, weight: .medium))
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .password)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .password ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                    )
                            }
                            
                            // Confirm Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CONFIRM PASSWORD")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppTheme.textTertiary)
                                
                                SecureField("Re-enter password", text: $viewModel.confirmPassword)
                                    .font(.system(size: 16, weight: .medium))
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .confirmPassword ? AppTheme.textPrimary : AppTheme.border, lineWidth: 1.5)
                                    )
                                
                                if !viewModel.confirmPassword.isEmpty && viewModel.password != viewModel.confirmPassword {
                                    Text("Passwords don't match")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Register Button
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
                                    .fill(viewModel.isFormValid ? AppTheme.textPrimary : AppTheme.gray300)
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
                            .background(Circle().stroke(AppTheme.border, lineWidth: 1.5))
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
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    AuthView()
        .environmentObject(AppCoordinator())
}
