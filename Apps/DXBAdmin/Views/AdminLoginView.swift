import SwiftUI
import DXBCore

struct AdminLoginView: View {
    @EnvironmentObject private var coordinator: AdminAppCoordinator
    @StateObject private var viewModel = AdminLoginViewModel()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("DXB Connect Admin")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300)
                
                Button {
                    Task {
                        await viewModel.signIn(coordinator: coordinator)
                    }
                } label: {
                    Text("Sign In")
                        .frame(width: 300)
                        .frame(height: 40)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isValid || viewModel.isLoading)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
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

@MainActor
final class AdminLoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    var isValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func signIn(coordinator: AdminAppCoordinator) async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement admin login API call
        // For now, mock successful login
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        coordinator.isAuthenticated = true
        coordinator.currentAdminUser = .mockAdmin
    }
}

#Preview {
    AdminLoginView()
        .environmentObject(AdminAppCoordinator())
}
