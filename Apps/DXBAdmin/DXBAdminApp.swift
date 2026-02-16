import SwiftUI
import DXBCore
import DXBAdminKit

@main
struct DXBAdminApp: App {
    @StateObject private var appCoordinator = AdminAppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            AdminCoordinatorView(coordinator: appCoordinator)
                .environmentObject(appCoordinator)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

// MARK: - Admin App Coordinator

@MainActor
final class AdminAppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentAdminUser: AdminUser?
    
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
        
        if isAuthenticated {
            // TODO: Fetch admin user info
            currentAdminUser = AdminUser.mockAdmin
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await authService.clearTokens()
            isAuthenticated = false
            currentAdminUser = nil
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    var currentAPIService: DXBAPIServiceProtocol {
        apiService
    }
}

// MARK: - Coordinator View

struct AdminCoordinatorView: View {
    @ObservedObject var coordinator: AdminAppCoordinator
    
    var body: some View {
        Group {
            if coordinator.isLoading {
                ProgressView("Loading...")
            } else if coordinator.isAuthenticated {
                AdminMainView()
                    .environmentObject(coordinator)
            } else {
                AdminLoginView()
                    .environmentObject(coordinator)
            }
        }
        .task {
            await coordinator.checkAuthentication()
        }
    }
}

// MARK: - Main View

struct AdminMainView: View {
    @EnvironmentObject private var coordinator: AdminAppCoordinator
    @State private var selectedTab: AdminTab = .dashboard
    
    var body: some View {
        NavigationSplitView {
            List(AdminTab.allCases, selection: $selectedTab) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationTitle("DXB Connect Admin")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Text(coordinator.currentAdminUser?.email ?? "Admin")
                        
                        Divider()
                        
                        Button {
                            Task {
                                await coordinator.signOut()
                            }
                        } label: {
                            Label("Sign Out", systemImage: "arrow.right.square")
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
        } detail: {
            selectedTab.view
        }
    }
}

// MARK: - Admin Tabs

enum AdminTab: String, CaseIterable, Identifiable {
    case dashboard
    case orders
    case plans
    case inventory
    case tickets
    case finance
    case auditLogs
    case settings
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .orders: return "Orders"
        case .plans: return "Plans"
        case .inventory: return "Inventory"
        case .tickets: return "Support Tickets"
        case .finance: return "Finance"
        case .auditLogs: return "Audit Logs"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .dashboard: return "chart.bar"
        case .orders: return "list.bullet.rectangle"
        case .plans: return "sim"
        case .inventory: return "shippingbox"
        case .tickets: return "questionmark.circle"
        case .finance: return "dollarsign.circle"
        case .auditLogs: return "doc.text.magnifyingglass"
        case .settings: return "gear"
        }
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .dashboard:
            AdminDashboardView()
        case .orders:
            AdminOrdersView()
        case .plans:
            AdminPlansView()
        case .inventory:
            AdminInventoryView()
        case .tickets:
            AdminTicketsView()
        case .finance:
            AdminFinanceView()
        case .auditLogs:
            AdminAuditLogsView()
        case .settings:
            AdminSettingsView()
        }
    }
}
