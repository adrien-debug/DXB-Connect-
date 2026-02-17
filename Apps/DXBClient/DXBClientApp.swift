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
    // MARK: - Auth State
    @Published var isAuthenticated = false
    @Published var isLoading = true

    // MARK: - Navigation
    @Published var selectedTab = 0
    @Published var showNotifications = false

    // MARK: - User Data (shared across all views)
    @Published var user: UserProfile = UserProfile()
    @Published var esimOrders: [ESIMOrder] = []
    @Published var plans: [Plan] = []
    @Published var notifications: [AppNotification] = []

    // MARK: - Cart
    @Published var cartItems: [CartItem] = []

    // MARK: - Loading States
    @Published var isLoadingESIMs = false
    @Published var isLoadingPlans = false

    private let authService: AuthServiceProtocol
    private let apiService: DXBAPIServiceProtocol

    init() {
        let authService = AuthService()
        // Utilise APIConfig.baseURL (configurable via APIConfig.current)
        let apiClient = APIClient()
        let apiService = DXBAPIService(apiClient: apiClient, authService: authService)

        self.authService = authService
        self.apiService = apiService

        // Toujours utiliser Railway en attendant que le backend local soit prêt
        APIConfig.current = .production
        // #if DEBUG
        // APIConfig.current = .development  // localhost:4000
        // #endif
    }

    // MARK: - Auth

    func checkAuthentication() async {
        isLoading = true
        
        #if DEBUG
        // DEV MODE: Bypass login, auto-authenticate
        isAuthenticated = true
        user.name = "Dev User"
        user.email = "dev@dxbconnect.com"
        await loadAllData()
        isLoading = false
        return
        #endif
        
        isAuthenticated = await authService.isAuthenticated()
        if isAuthenticated {
            loadUserFromStorage()
            await loadAllData()
        }
        isLoading = false
    }

    func onAuthSuccess(email: String? = nil, name: String? = nil) async {
        // Update user info if provided
        if let email = email {
            user.email = email
        }
        if let name = name {
            user.name = name
        }

        // Save to UserDefaults
        saveUserToStorage()

        // Load data
        await loadAllData()

        // Set authenticated
        isAuthenticated = true
    }

    func signOut() async {
        do {
            try await authService.clearTokens()
            isAuthenticated = false
            // Clear user data
            user = UserProfile()
            esimOrders = []
            cartItems = []
            // Clear storage
            UserDefaults.standard.removeObject(forKey: "user_profile")
            appLog("User signed out successfully", category: .auth)
        } catch {
            appLogError(error, message: "Sign out failed", category: .auth)
        }
    }
    
    // MARK: - Email/Password Auth
    
    func signInWithPassword(email: String, password: String) async throws {
        appLog("Signing in with email: \(email)", category: .auth)
        let response = try await apiService.signInWithPassword(email: email, password: password)
        user.email = email
        user.name = response.user.name ?? ""
        saveUserToStorage()
        await loadAllData()
        isAuthenticated = true
        appLog("Sign in successful", category: .auth)
    }
    
    func signUpWithPassword(email: String, password: String, name: String) async throws {
        appLog("Signing up with email: \(email)", category: .auth)
        _ = try await apiService.signUpWithPassword(email: email, password: password, name: name)
        user.email = email
        user.name = name
        saveUserToStorage()
        await loadAllData()
        isAuthenticated = true
        appLog("Sign up successful", category: .auth)
    }

    // MARK: - Persistence

    private func saveUserToStorage() {
        let data: [String: Any] = [
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "isPro": user.isPro,
            "notificationsEnabled": user.notificationsEnabled,
            "language": user.language,
            "appearance": user.appearance
        ]
        UserDefaults.standard.set(data, forKey: "user_profile")
    }

    private func loadUserFromStorage() {
        guard let data = UserDefaults.standard.dictionary(forKey: "user_profile") else { return }
        user.name = data["name"] as? String ?? "User"
        user.email = data["email"] as? String ?? ""
        user.phone = data["phone"] as? String ?? ""
        user.isPro = data["isPro"] as? Bool ?? false
        user.notificationsEnabled = data["notificationsEnabled"] as? Bool ?? true
        user.language = data["language"] as? String ?? "English"
        user.appearance = data["appearance"] as? String ?? "Light"

        // Apply saved appearance
        applyAppearance(user.appearance)
    }

    private func applyAppearance(_ mode: String) {
        let appearanceMode: AppearanceMode
        switch mode {
        case "Dark":
            appearanceMode = .dark
        case "System":
            appearanceMode = .system
        default:
            appearanceMode = .light
        }
        AppTheme.setAppearance(appearanceMode)
    }

    func savePreferences() {
        saveUserToStorage()
    }

    // MARK: - Data Loading

    func loadAllData() async {
        async let esims: () = loadESIMs()
        async let plansData: () = loadPlans()
        _ = await (esims, plansData)
    }

    func loadESIMs() async {
        isLoadingESIMs = true
        do {
            esimOrders = try await apiService.fetchMyESIMs()
            updateUserStats()
        } catch {
            appLogError(error, message: "Error loading eSIMs", category: .data)
        }
        isLoadingESIMs = false
    }

    func loadPlans() async {
        isLoadingPlans = true
        do {
            plans = try await apiService.fetchPlans(locale: "en")
        } catch {
            appLogError(error, message: "Error loading plans", category: .data)
        }
        isLoadingPlans = false
    }

    // MARK: - User Stats (computed from eSIMs)

    private func updateUserStats() {
        user.totalESIMs = esimOrders.count
        user.activeESIMs = esimOrders.filter {
            $0.status.uppercased() == "RELEASED" || $0.status.uppercased() == "IN_USE"
        }.count

        // Count unique countries from package names
        let countries = Set(esimOrders.map { extractCountry(from: $0.packageName) })
        user.countriesVisited = countries.count

        // Calculate savings (estimate: 30% vs roaming)
        let totalSpent = esimOrders.reduce(0.0) { sum, order in
            // Extract price from package if available, otherwise estimate
            sum + estimatePrice(for: order)
        }
        user.totalSaved = totalSpent * 0.3 // 30% savings estimate
    }

    private func extractCountry(from packageName: String) -> String {
        // Extract country from package name like "UAE - 5GB" -> "UAE"
        if let dash = packageName.firstIndex(of: "-") {
            return String(packageName[..<dash]).trimmingCharacters(in: .whitespaces)
        }
        return packageName
    }

    private func estimatePrice(for order: ESIMOrder) -> Double {
        // Try to match with a plan to get actual price
        if let plan = plans.first(where: { $0.name == order.packageName }) {
            return plan.priceUSD
        }
        // Estimate based on data volume
        if order.totalVolume.contains("GB") {
            let gbString = order.totalVolume.replacingOccurrences(of: "GB", with: "").trimmingCharacters(in: .whitespaces)
            if let gb = Double(gbString) {
                return gb * 3.0 // ~$3 per GB estimate
            }
        }
        return 10.0 // Default estimate
    }

    // MARK: - Cart Management

    func addToCart(plan: Plan, quantity: Int = 1) {
        if let index = cartItems.firstIndex(where: { $0.plan.id == plan.id }) {
            cartItems[index].quantity += quantity
        } else {
            cartItems.append(CartItem(plan: plan, quantity: quantity))
        }
    }

    func removeFromCart(plan: Plan) {
        cartItems.removeAll { $0.plan.id == plan.id }
    }

    func clearCart() {
        cartItems = []
    }

    var cartTotal: Double {
        cartItems.reduce(0) { $0 + ($1.plan.priceUSD * Double($1.quantity)) }
    }

    var cartItemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Order History (derived from eSIMs)

    var orderHistory: [OrderHistoryItem] {
        esimOrders.map { order in
            OrderHistoryItem(
                id: order.id,
                name: order.packageName,
                date: formatOrderDate(order.createdAt),
                price: estimatePrice(for: order),
                status: order.status.uppercased() == "RELEASED" || order.status.uppercased() == "IN_USE" ? "Active" : "Expired"
            )
        }
    }

    private func formatOrderDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    var currentAPIService: DXBAPIServiceProtocol {
        apiService
    }
}

// MARK: - User Profile Model

struct UserProfile {
    var id: String = UUID().uuidString
    var name: String = "User"
    var email: String = "user@dxbconnect.com"
    var phone: String = ""
    var avatarURL: String? = nil
    var isPro: Bool = true

    // Stats
    var totalESIMs: Int = 0
    var activeESIMs: Int = 0
    var countriesVisited: Int = 0
    var totalSaved: Double = 0

    // Preferences
    var notificationsEnabled: Bool = true
    var language: String = "English"
    var appearance: String = "Light"
}

// MARK: - Cart Item Model

struct CartItem: Identifiable {
    let id = UUID()
    let plan: Plan
    var quantity: Int
}

// MARK: - Order History Item

struct OrderHistoryItem: Identifiable {
    let id: String
    let name: String
    let date: String
    let price: Double
    let status: String
}

// MARK: - App Notification

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
    let isRead: Bool
    let type: NotificationType

    enum NotificationType {
        case esimActivated
        case dataLow
        case esimExpiring
        case promo
    }
}

// MARK: - Coordinator View

struct CoordinatorView: View {
    @ObservedObject var coordinator: AppCoordinator

    // Set to false to require auth, true to bypass for testing
    #if DEBUG
    private let bypassAuthForTesting = true
    #else
    private let bypassAuthForTesting = false
    #endif

    var body: some View {
        Group {
            if coordinator.isLoading && !bypassAuthForTesting {
                // Splash screen
                SplashView()
            } else if coordinator.isAuthenticated || bypassAuthForTesting {
                MainTabView()
                    .environmentObject(coordinator)
            } else {
                AuthView()
                    .environmentObject(coordinator)
            }
        }
        .task {
            if !bypassAuthForTesting {
                await coordinator.checkAuthentication()
            }
        }
    }
}

// MARK: - Splash View

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppTheme.textPrimary)
                        .frame(width: 80, height: 80)

                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                }

                ProgressView()
                    .tint(AppTheme.textPrimary)
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch coordinator.selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    PlanListView()
                case 2:
                    MyESIMsView()
                case 3:
                    ProfileView()
                default:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar - Fixed at bottom
            VStack(spacing: 0) {
                Spacer()
                CustomTabBar(selectedTab: $coordinator.selectedTab)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $coordinator.showNotifications) {
            NotificationsSheet()
        }
    }
}

// MARK: - Notifications Sheet

struct NotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss

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

                    Text("NOTIFICATIONS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textTertiary)

                    Spacer()

                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // Empty state
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gray100)
                            .frame(width: 80, height: 80)

                        Image(systemName: "bell.slash")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(AppTheme.textTertiary)
                    }

                    VStack(spacing: 8) {
                        Text("No notifications")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("You're all caught up!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Tech Minimal Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    private let tabs: [(icon: String, activeIcon: String, title: String)] = [
        ("house", "house.fill", "Home"),
        ("globe", "globe.americas.fill", "Explore"),
        ("simcard", "simcard.fill", "eSIMs"),
        ("person", "person.fill", "Profile")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabBarItem(
                    icon: selectedTab == index ? tabs[index].activeIcon : tabs[index].icon,
                    title: tabs[index].title,
                    isSelected: selectedTab == index,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 36)
        .background(
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1.5),
            alignment: .top
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(AppTheme.textPrimary)
                            .frame(width: 52, height: 52)
                            .matchedGeometryEffect(id: "tab_bg", in: animation)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? .white : AppTheme.textTertiary)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                }
                .frame(height: 52)

                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        isPressed = false
                    }
                }
        )
    }
}

