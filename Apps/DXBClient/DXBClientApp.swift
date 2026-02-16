import SwiftUI
import DXBCore

@main
struct DXBClientApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: appCoordinator)
                .environmentObject(appCoordinator)
        }
    }
}

// MARK: - App Coordinator

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    
    private let authService: AuthServiceProtocol
    private let apiService: DXBAPIServiceProtocol
    
    init() {
        let authService = AuthService()
        let apiClient = APIClient(
            baseURL: URL(string: "https://api.dxbconnect.com/v1")!
        )
        let apiService = DXBAPIService(apiClient: apiClient, authService: authService)
        
        self.authService = authService
        self.apiService = apiService
    }
    
    func checkAuthentication() async {
        isLoading = true
        isAuthenticated = await authService.isAuthenticated()
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await authService.clearTokens()
            isAuthenticated = false
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    var currentAPIService: DXBAPIServiceProtocol {
        apiService
    }
}

// MARK: - Coordinator View

struct CoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        Group {
            if coordinator.isLoading {
                ProgressView("Loading...")
            } else if coordinator.isAuthenticated {
                MainTabView()
                    .environmentObject(coordinator)
            } else {
                AuthView()
                    .environmentObject(coordinator)
            }
        }
        .task {
            await coordinator.checkAuthentication()
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabView {
            PlanListView()
                .tabItem {
                    Label("Plans", systemImage: "list.bullet")
                }
            
            MyESIMsView()
                .tabItem {
                    Label("My eSIMs", systemImage: "simcard")
                }
            
            SupportView()
                .tabItem {
                    Label("Support", systemImage: "questionmark.circle")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
