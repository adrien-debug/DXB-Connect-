import SwiftUI
import DXBCore

struct ProfileView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.userName ?? "User")
                                .font(.headline)
                            
                            Text(viewModel.userEmail ?? "email@example.com")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Preferences") {
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        Text("English").tag("en")
                        Text("Français").tag("fr")
                    }
                    
                    Toggle("Push Notifications", isOn: $viewModel.pushNotificationsEnabled)
                }
                
                Section("About") {
                    NavigationLink {
                        Text("Terms of Service")
                            .navigationTitle("Terms")
                    } label: {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    NavigationLink {
                        Text("Privacy Policy")
                            .navigationTitle("Privacy")
                    } label: {
                        Label("Privacy Policy", systemImage: "lock.doc")
                    }
                    
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.showDeleteConfirmation = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                    
                    Button {
                        Task {
                            await coordinator.signOut()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteAccount(coordinator: coordinator)
                    }
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var selectedLanguage = "en"
    @Published var pushNotificationsEnabled = true
    @Published var showDeleteConfirmation = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    init() {
        // TODO: Load user data from API
        userName = "John Doe"
        userEmail = "john@example.com"
    }
    
    func deleteAccount(coordinator: AppCoordinator) async {
        // TODO: Call API to delete account
        do {
            try await coordinator.signOut()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppCoordinator())
}
