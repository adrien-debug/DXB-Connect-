import SwiftUI
import DXBCore

// MARK: - App State

@Observable
@MainActor
final class AppState {

    // MARK: Auth

    var isAuthenticated = false
    var currentUser: UserInfo?
    var isCheckingAuth = true

    // MARK: Dashboard data

    var activeESIMs: [ESIMOrder] = []
    var subscription: SubscriptionResponse?
    var rewardsSummary: RewardsSummaryResponse?
    var partnerOffers: [PartnerOfferResponse] = []

    var isDashboardLoading = false
    var dashboardError: String?

    // MARK: Location

    let locationManager = LocationManager()

    // MARK: Services (DI)

    let authService: AuthService
    let apiClient: APIClient
    let apiService: DXBAPIService
    let tokenManager: TokenManager

    // MARK: Init

    init() {
        let auth = AuthService()
        let client = APIClient()
        let tm = TokenManager(authService: auth)
        let api = DXBAPIService(apiClient: client, authService: auth)

        self.authService = auth
        self.apiClient = client
        self.tokenManager = tm
        self.apiService = api
    }

    // MARK: - Auth Flow

    func checkAuth() async {
        isCheckingAuth = true
        defer { isCheckingAuth = false }

        await apiClient.setTokenManager(tokenManager)
        await tokenManager.setAPIClient(apiClient)

        locationManager.requestIfNeeded()

        let authenticated = await authService.isAuthenticated()
        isAuthenticated = authenticated

        if authenticated {
            await loadDashboard()
        }
    }

    func didSignIn(response: AuthResponse) {
        currentUser = response.user
        isAuthenticated = true
        Task { await loadDashboard() }
    }

    func signOut() async {
        do {
            try await authService.clearTokens()
        } catch {
            appLog("Sign out failed: \(error.localizedDescription)", level: .error, category: .auth)
        }
        isAuthenticated = false
        currentUser = nil
        activeESIMs = []
        subscription = nil
        rewardsSummary = nil
        partnerOffers = []
    }

    // MARK: - Dashboard Loading

    func loadDashboard() async {
        isDashboardLoading = true
        dashboardError = nil

        async let _esims: Void = loadESIMs()
        async let _sub: Void = loadSubscription()
        async let _rewards: Void = loadRewards()
        async let _offers: Void = loadOffers()

        _ = await (_esims, _sub, _rewards, _offers)

        isDashboardLoading = false
    }

    private func loadESIMs() async {
        do {
            activeESIMs = try await apiService.fetchMyESIMs()
        } catch {
            if handleAuthError(error) { return }
            dashboardError = "Failed to load eSIMs"
            appLog("Failed to load eSIMs: \(error.localizedDescription)", level: .error, category: .data)
        }
    }

    private func loadSubscription() async {
        do {
            subscription = try await apiService.fetchMySubscription()
        } catch {
            if handleAuthError(error) { return }
            appLog("Failed to load subscription: \(error.localizedDescription)", level: .error, category: .data)
        }
    }

    private func loadRewards() async {
        do {
            rewardsSummary = try await apiService.fetchRewardsSummary()
        } catch {
            if handleAuthError(error) { return }
            appLog("Failed to load rewards: \(error.localizedDescription)", level: .error, category: .data)
        }
    }

    private func loadOffers() async {
        do {
            let country = locationManager.detectedCountryCode
            let tier = subscription?.plan
            partnerOffers = try await apiService.fetchOffers(country: country, category: nil, tier: tier)
        } catch {
            if handleAuthError(error) { return }
            appLog("Failed to load offers: \(error.localizedDescription)", level: .error, category: .data)
        }
    }

    private var isSigningOutFromAuth = false

    @discardableResult
    private func handleAuthError(_ error: Error) -> Bool {
        if case APIError.unauthorized = error {
            guard !isSigningOutFromAuth else { return true }
            isSigningOutFromAuth = true
            appLog("Unauthorized - signing out", level: .warning, category: .auth)
            Task {
                await signOut()
                isSigningOutFromAuth = false
            }
            return true
        }
        return false
    }
}
