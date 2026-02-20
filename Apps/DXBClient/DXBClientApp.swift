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

    // MARK: - Usage Cache (iccid → ESIMUsage)
    @Published var usageCache: [String: ESIMUsage] = [:]
    @Published var isLoadingUsage = false

    // MARK: - Loading States
    @Published var isLoadingESIMs = false
    @Published var isLoadingPlans = false
    @Published var hasLoadedInitialData = false

    private let authService: AuthServiceProtocol
    private let apiService: DXBAPIServiceProtocol

    init() {
        let authService = AuthService()
        let apiClient = APIClient()
        let tokenManager = TokenManager(authService: authService)
        let apiService = DXBAPIService(apiClient: apiClient, authService: authService)

        self.authService = authService
        self.apiService = apiService

        APIConfig.current = .production

        Task {
            await tokenManager.setAPIClient(apiClient)
            await apiClient.setTokenManager(tokenManager)
        }
    }

    // MARK: - Auth

    func checkAuthentication() async {
        isLoading = true
        isAuthenticated = await authService.isAuthenticated()
        if isAuthenticated {
            loadUserFromStorage()
            await loadAllData()
        } else {
            #if DEBUG
            await devAutoLogin()
            #endif
        }
        isLoading = false
    }

    #if DEBUG
    private func devAutoLogin() async {
        let email = "client@test.com"
        let password = "test1234"
        appLog("[DEV] Auto-login attempt", category: .auth)
        do {
            try await signInWithPassword(email: email, password: password)
            appLog("[DEV] Auto-login successful", category: .auth)
        } catch {
            appLogError(error, message: "[DEV] Auto-login failed — showing auth screen", category: .auth)
        }
    }
    #endif

    func onAuthSuccess(email: String? = nil, name: String? = nil) async {
        if let email = email { user.email = email }
        if let name = name { user.name = name }
        saveUserToStorage()
        await loadAllData()
        isAuthenticated = true
    }

    func signOut() async {
        do {
            try await authService.clearTokens()
            isAuthenticated = false
            hasLoadedInitialData = false
            user = UserProfile()
            esimOrders = []
            cartItems = []
            plans = []
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
        applyAppearance(user.appearance)
    }

    private func applyAppearance(_ mode: String) {
        let appearanceMode: AppearanceMode
        switch mode {
        case "Dark": appearanceMode = .dark
        case "System": appearanceMode = .system
        default: appearanceMode = .light
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
        await loadUsageForActiveESIMs()
        hasLoadedInitialData = true
    }

    func loadESIMs() async {
        isLoadingESIMs = true
        do {
            esimOrders = try await apiService.fetchMyESIMs()
            updateUserStats()
        } catch is CancellationError {
        } catch APIError.unauthorized {
            appLogError(APIError.unauthorized, message: "Unauthorized loading eSIMs - signing out", category: .auth)
            await signOut()
        } catch {
            appLogError(error, message: "Error loading eSIMs", category: .data)
        }
        isLoadingESIMs = false
    }

    func loadPlans() async {
        isLoadingPlans = true
        do {
            plans = try await apiService.fetchPlans(locale: "en")
        } catch is CancellationError {
        } catch APIError.unauthorized {
            appLogError(APIError.unauthorized, message: "Unauthorized loading plans - signing out", category: .auth)
            await signOut()
        } catch {
            appLogError(error, message: "Error loading plans", category: .data)
        }
        isLoadingPlans = false
    }

    // MARK: - Usage Loading

    func loadUsageForActiveESIMs() async {
        let activeOrders = esimOrders.filter {
            let s = $0.status.uppercased()
            return s == "RELEASED" || s == "IN_USE" || s == "ENABLED"
        }
        guard !activeOrders.isEmpty else { return }

        isLoadingUsage = true
        for order in activeOrders {
            await loadUsage(for: order)
        }
        isLoadingUsage = false
    }

    func loadUsage(for order: ESIMOrder) async {
        guard !order.iccid.isEmpty else { return }
        do {
            if let usage = try await apiService.fetchUsage(iccid: order.iccid) {
                usageCache[order.iccid] = usage
            }
        } catch {
            appLogError(error, message: "Error loading usage for \(order.iccid)", category: .data)
        }
    }

    func usagePercentage(for order: ESIMOrder) -> Double {
        usageCache[order.iccid]?.usagePercentage ?? 0
    }

    func usageDisplay(for order: ESIMOrder) -> (used: String, total: String, remaining: String)? {
        guard let u = usageCache[order.iccid] else { return nil }
        return (u.usedDisplay, u.totalDisplay, u.remainingDisplay)
    }

    // MARK: - Top-Up

    func fetchTopUpPackages(for order: ESIMOrder) async -> [TopUpPackage] {
        do {
            return try await apiService.fetchTopUpPackages(iccid: order.iccid)
        } catch {
            appLogError(error, message: "Error fetching top-up packages", category: .data)
            return []
        }
    }

    func performTopUp(for order: ESIMOrder, packageCode: String) async -> Bool {
        do {
            let success = try await apiService.topUpESIM(iccid: order.iccid, packageCode: packageCode)
            if success {
                await loadUsage(for: order)
            }
            return success
        } catch {
            appLogError(error, message: "Error topping up eSIM", category: .data)
            return false
        }
    }

    // MARK: - Cancel Order

    func cancelOrder(_ order: ESIMOrder) async -> Bool {
        do {
            let success = try await apiService.cancelOrder(orderNo: order.orderNo)
            if success {
                await loadESIMs()
            }
            return success
        } catch {
            appLogError(error, message: "Error cancelling order", category: .data)
            return false
        }
    }

    // MARK: - Suspend / Resume

    func suspendESIM(_ order: ESIMOrder) async -> Bool {
        do {
            let success = try await apiService.suspendESIM(orderNo: order.orderNo)
            if success {
                await loadESIMs()
            }
            return success
        } catch {
            appLogError(error, message: "Error suspending eSIM", category: .data)
            return false
        }
    }

    func resumeESIM(_ order: ESIMOrder) async -> Bool {
        do {
            let success = try await apiService.resumeESIM(orderNo: order.orderNo)
            if success {
                await loadESIMs()
            }
            return success
        } catch {
            appLogError(error, message: "Error resuming eSIM", category: .data)
            return false
        }
    }

    // MARK: - User Stats

    private func updateUserStats() {
        user.totalESIMs = esimOrders.count
        user.activeESIMs = esimOrders.filter {
            $0.status.uppercased() == "RELEASED" || $0.status.uppercased() == "IN_USE"
        }.count

        let countries = Set(esimOrders.map { extractCountry(from: $0.packageName) })
        user.countriesVisited = countries.count

        let totalSpent = esimOrders.reduce(0.0) { sum, order in
            sum + estimatePrice(for: order)
        }
        user.totalSaved = totalSpent * 0.3
    }

    private func extractCountry(from packageName: String) -> String {
        if let dash = packageName.firstIndex(of: "-") {
            return String(packageName[..<dash]).trimmingCharacters(in: .whitespaces)
        }
        return packageName
    }

    private func estimatePrice(for order: ESIMOrder) -> Double {
        if let plan = plans.first(where: { $0.name == order.packageName }) {
            return plan.priceUSD
        }
        if order.totalVolume.contains("GB") {
            let gbString = order.totalVolume.replacingOccurrences(of: "GB", with: "").trimmingCharacters(in: .whitespaces)
            if let gb = Double(gbString) {
                return gb * 3.0
            }
        }
        return 10.0
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

    // MARK: - Order History

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
    var name: String = "Mickael"
    var email: String = "mickael@dxbconnect.com"
    var phone: String = ""
    var avatarURL: String? = nil
    var isPro: Bool = true

    var totalESIMs: Int = 0
    var activeESIMs: Int = 0
    var countriesVisited: Int = 0
    var totalSaved: Double = 0

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

    var body: some View {
        Group {
            if coordinator.isLoading {
                SplashView()
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

// MARK: - Splash View

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.9
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(AppTheme.accent)
                        .frame(width: 68, height: 68)
                        .overlay(
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundColor(Color(hex: "0F172A"))
                        )

                    Text("DXB CONNECT")
                        .font(.system(size: 14, weight: .bold))
                        .tracking(3)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Spacer()

                ProgressView()
                    .tint(AppTheme.textTertiary)
                    .opacity(logoOpacity)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch coordinator.selectedTab {
                case 0: DashboardView()
                case 1: PlanListView()
                case 2: MyESIMsView()
                case 3: ProfileView()
                default: DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
            AppTheme.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(AppTheme.gray100)
                            )
                    }

                    Spacer()

                    Text("NOTIFICATIONS")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(AppTheme.textSecondary)

                    Spacer()

                    Color.clear
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gray100)
                            .frame(width: 72, height: 72)

                        Image(systemName: "bell.slash")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    VStack(spacing: 6) {
                        Text("No notifications")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("You're all caught up!")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Premium Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var bounceStates: [Bool] = [false, false, false, false]

    private let tabs: [(icon: String, activeIcon: String, label: String)] = [
        ("house", "house.fill", "Home"),
        ("globe", "globe", "Plans"),
        ("simcard", "simcard.fill", "eSIMs"),
        ("person", "person.fill", "Profile")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button {
                        guard selectedTab != index else { return }
                        HapticFeedback.selection()
                        triggerBounce(at: index)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    } label: {
                        VStack(spacing: 5) {
                            ZStack {
                                if selectedTab == index {
                                    Circle()
                                        .fill(AppTheme.accent.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                        .scaleEffect(bounceStates[index] ? 1.2 : 1.0)
                                }

                                Image(systemName: selectedTab == index ? tabs[index].activeIcon : tabs[index].icon)
                                    .font(.system(size: 22, weight: selectedTab == index ? .semibold : .regular))
                                    .foregroundColor(selectedTab == index ? AppTheme.accent : AppTheme.textTertiary)
                                    .scaleEffect(bounceStates[index] ? 1.25 : 1.0)
                                    .shadow(
                                        color: selectedTab == index ? AppTheme.accent.opacity(0.4) : .clear,
                                        radius: 8, x: 0, y: 4
                                    )
                            }
                            .frame(height: 44)

                            Text(tabs[index].label)
                                .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundColor(selectedTab == index ? AppTheme.accent : AppTheme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(tabs[index].label)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(
            ZStack {
                BlurView(style: .systemThinMaterialDark)
                AppTheme.backgroundPrimary.opacity(0.85)
            }
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.border.opacity(0.4), AppTheme.border.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
    }

    private func triggerBounce(at index: Int) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            bounceStates[index] = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                bounceStates[index] = false
            }
        }
    }
}
