import Foundation

// MARK: - API Service Protocol

public protocol DXBAPIServiceProtocol: Sendable {
    func signInWithApple(identityToken: String, authorizationCode: String, user: AppleUserInfo) async throws -> AuthResponse
    func signInWithEmail(email: String) async throws
    func verifyOTP(email: String, otp: String) async throws -> AuthResponse
    func signInWithPassword(email: String, password: String) async throws -> AuthResponse
    func signUpWithPassword(email: String, password: String, name: String) async throws -> AuthResponse
    func fetchPlans(locale: String) async throws -> [Plan]
    func fetchStock() async throws -> [ESIMOrder]
    func fetchMyESIMs() async throws -> [ESIMOrder]
    func purchasePlan(planId: String) async throws -> ESIMOrder
    func processApplePayPayment(planId: String, paymentToken: String, paymentNetwork: String) async throws -> ESIMOrder
    func fetchUsage(iccid: String) async throws -> ESIMUsage?
    func fetchTopUpPackages(iccid: String) async throws -> [TopUpPackage]
    func topUpESIM(iccid: String, packageCode: String) async throws -> Bool
    func cancelOrder(orderNo: String) async throws -> Bool
    func suspendESIM(orderNo: String) async throws -> Bool
    func resumeESIM(orderNo: String) async throws -> Bool
    func refreshAccessToken() async throws -> AuthResponse
    func requestPasswordReset(email: String) async throws

    // MARK: - Offers (SimPass)
    func fetchOffers(country: String?, category: String?) async throws -> [PartnerOfferResponse]
    func trackOfferClick(offerId: String, country: String?) async throws -> OfferClickResponse

    // MARK: - Subscriptions (SimPass)
    func fetchMySubscription() async throws -> SubscriptionResponse?
    func createSubscription(plan: String, billingPeriod: String) async throws -> SubscriptionResponse

    // MARK: - Rewards (SimPass)
    func fetchRewardsSummary() async throws -> RewardsSummaryResponse
    func dailyCheckin() async throws -> CheckinResponse

    // MARK: - Crypto Payments
    func createCryptoInvoice(amountUSD: Double, asset: String) async throws -> CryptoInvoiceResponse
    func pollCryptoInvoice(invoiceId: String) async throws -> CryptoInvoiceResponse
}

// MARK: - API Service Implementation

public actor DXBAPIService: DXBAPIServiceProtocol {
    private let apiClient: APIClient
    private let authService: AuthServiceProtocol

    public init(apiClient: APIClient, authService: AuthServiceProtocol) {
        self.apiClient = apiClient
        self.authService = authService
    }

    public func signInWithApple(identityToken: String, authorizationCode: String, user: AppleUserInfo) async throws -> AuthResponse {
        let body: [String: Any] = [
            "identityToken": identityToken,
            "authorizationCode": authorizationCode,
            "email": user.email ?? "",
            "name": user.name ?? ""
        ]

        let response: AuthResponse = try await apiClient.request(
            endpoint: "auth/apple",
            method: "POST",
            body: body,
            requiresAuth: false
        )

        try await authService.saveTokens(access: response.accessToken, refresh: response.refreshToken)
        await apiClient.setAccessToken(response.accessToken)

        return response
    }

    public func signInWithEmail(email: String) async throws {
        let body: [String: Any] = ["email": email]

        let _: EmptyResponse = try await apiClient.request(
            endpoint: "auth/email/send-otp",
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }

    public func verifyOTP(email: String, otp: String) async throws -> AuthResponse {
        let body: [String: Any] = ["email": email, "otp": otp]

        let response: AuthResponse = try await apiClient.request(
            endpoint: "auth/email/verify",
            method: "POST",
            body: body,
            requiresAuth: false
        )

        try await authService.saveTokens(access: response.accessToken, refresh: response.refreshToken)
        await apiClient.setAccessToken(response.accessToken)

        return response
    }
    
    public func signInWithPassword(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = ["email": email, "password": password]

        let response: AuthResponse = try await apiClient.request(
            endpoint: "auth/login",
            method: "POST",
            body: body,
            requiresAuth: false
        )

        try await authService.saveTokens(access: response.accessToken, refresh: response.refreshToken)
        await apiClient.setAccessToken(response.accessToken)

        return response
    }
    
    public func signUpWithPassword(email: String, password: String, name: String) async throws -> AuthResponse {
        let body: [String: Any] = ["email": email, "password": password, "name": name]

        let response: AuthResponse = try await apiClient.request(
            endpoint: "auth/register",
            method: "POST",
            body: body,
            requiresAuth: false
        )

        try await authService.saveTokens(access: response.accessToken, refresh: response.refreshToken)
        await apiClient.setAccessToken(response.accessToken)

        return response
    }

    public func requestPasswordReset(email: String) async throws {
        let body: [String: Any] = ["email": email]
        let _: [String: String] = try await apiClient.request(
            endpoint: APIEndpoint.authResetPassword.path,
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }

    public func fetchPlans(locale: String) async throws -> [Plan] {
        await AppLogger.shared.logData("Fetching eSIM plans (locale: \(locale))")

        // Charger le token dans le client avant la requête
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: PackagesResponse = try await apiClient.request(
            endpoint: "esim/packages",
            requiresAuth: true
        )

        let plans: [Plan] = response.obj?.packageList?.compactMap { pkg -> Plan? in
            // L'API retourne volume en MB et price en dollars directement
            let volumeMB = pkg.volume ?? 0
            let volumeGB = volumeMB >= 1024 ? volumeMB / 1024 : 0
            let dataDisplay = volumeGB > 0 ? volumeGB : max(1, volumeMB)
            
            return Plan(
                id: pkg.packageCode ?? UUID().uuidString,
                name: pkg.name ?? "eSIM Plan",
                description: "\(pkg.locationNetworkList?.first?.locationName ?? pkg.location ?? "Global") - \(pkg.duration ?? 0) days",
                dataGB: dataDisplay,
                durationDays: pkg.duration ?? 0,
                priceUSD: pkg.price ?? 0.0,
                speed: pkg.speed ?? "4G/LTE",
                location: pkg.locationNetworkList?.first?.locationName ?? pkg.location ?? "Global",
                locationCode: pkg.locationCode ?? ""
            )
        } ?? []

        await AppLogger.shared.logData("Fetched \(plans.count) plans")
        return plans
    }

    public func fetchStock() async throws -> [ESIMOrder] {
        await AppLogger.shared.logData("Fetching eSIM stock (available for sale)")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: StockResponse = try await apiClient.request(
            endpoint: "esim/stock",
            requiresAuth: true
        )

        let orders = response.obj?.esimList?.compactMap { esim -> ESIMOrder? in
            let volumeBytes = esim.totalVolume ?? esim.packageList?.first?.volume ?? 0
            let volumeGB = volumeBytes / 1_073_741_824
            let volumeDisplay = volumeGB > 0 ? "\(volumeGB) GB" : "\(volumeBytes / 1_048_576) MB"
            
            return ESIMOrder(
                id: esim.iccid ?? esim.orderNo ?? UUID().uuidString,
                orderNo: esim.orderNo ?? esim.esimTranNo ?? "",
                iccid: esim.iccid ?? "",
                lpaCode: esim.ac ?? "",
                qrCodeUrl: esim.qrCodeUrl ?? "",
                status: esim.smdpStatus ?? "UNKNOWN",
                packageName: esim.packageList?.first?.packageName ?? "eSIM",
                totalVolume: volumeDisplay,
                expiredTime: esim.expiredTime ?? "",
                createdAt: Date()
            )
        } ?? []

        await AppLogger.shared.logData("Fetched \(orders.count) eSIMs in stock")
        return orders
    }

    public func fetchMyESIMs() async throws -> [ESIMOrder] {
        await AppLogger.shared.logData("Fetching user eSIMs")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: OrdersResponse = try await apiClient.request(
            endpoint: "esim/orders",
            requiresAuth: true
        )

        // L'API retourne esimList (structure plate) avec toutes les infos par eSIM
        let orders = response.obj?.esimList?.compactMap { esim -> ESIMOrder? in
            let volumeBytes = esim.totalVolume ?? esim.packageList?.first?.totalVolume ?? 0
            let volumeGB = volumeBytes / 1_073_741_824
            let volumeDisplay = volumeGB > 0 ? "\(volumeGB) GB" : "\(volumeBytes / 1_048_576) MB"
            
            return ESIMOrder(
                id: esim.iccid ?? esim.orderNo ?? UUID().uuidString,
                orderNo: esim.orderNo ?? esim.esimTranNo ?? "",
                iccid: esim.iccid ?? "",
                lpaCode: esim.ac ?? "",
                qrCodeUrl: esim.qrCodeUrl ?? "",
                status: esim.smdpStatus ?? "UNKNOWN",
                packageName: esim.packageList?.first?.packageName ?? "eSIM",
                totalVolume: volumeDisplay,
                expiredTime: esim.expiredTime ?? esim.packageList?.first?.expiredTime ?? "",
                createdAt: Date()
            )
        } ?? []

        await AppLogger.shared.logData("Fetched \(orders.count) eSIMs")
        return orders
    }

    public func purchasePlan(planId: String) async throws -> ESIMOrder {
        let body: [String: Any] = ["packageCode": planId]

        let response: PurchaseResponse = try await apiClient.request(
            endpoint: "esim/purchase",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        guard let order = response.obj else {
            throw APIError.invalidResponse
        }

        // Utiliser le statut réel de l'API, fallback "PENDING" si non disponible
        let realStatus = order.esimList?.first?.smdpStatus ?? "PENDING"
        
        return ESIMOrder(
            id: order.orderNo ?? UUID().uuidString,
            orderNo: order.orderNo ?? "",
            iccid: order.esimList?.first?.iccid ?? "",
            lpaCode: order.esimList?.first?.ac ?? "",
            qrCodeUrl: order.esimList?.first?.qrCodeUrl ?? "",
            status: realStatus,
            packageName: order.packageList?.first?.packageName ?? "eSIM",
            totalVolume: "",
            expiredTime: order.packageList?.first?.expiredTime ?? "",
            createdAt: Date()
        )
    }
    
    public func processApplePayPayment(planId: String, paymentToken: String, paymentNetwork: String) async throws -> ESIMOrder {
        await AppLogger.shared.logData("Processing Apple Pay payment for plan: \(planId)")
        
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }
        
        let body: [String: Any] = [
            "packageCode": planId,
            "paymentMethod": "apple_pay",
            "paymentToken": paymentToken,
            "paymentNetwork": paymentNetwork
        ]

        let response: PurchaseResponse = try await apiClient.request(
            endpoint: "esim/purchase/apple-pay",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        guard let order = response.obj else {
            throw APIError.invalidResponse
        }

        // Utiliser le statut réel de l'API, fallback "PENDING" si non disponible
        let realStatus = order.esimList?.first?.smdpStatus ?? "PENDING"
        
        await AppLogger.shared.logData("Apple Pay purchase successful: \(order.orderNo ?? "unknown"), status: \(realStatus)")
        
        return ESIMOrder(
            id: order.orderNo ?? UUID().uuidString,
            orderNo: order.orderNo ?? "",
            iccid: order.esimList?.first?.iccid ?? "",
            lpaCode: order.esimList?.first?.ac ?? "",
            qrCodeUrl: order.esimList?.first?.qrCodeUrl ?? "",
            status: realStatus,
            packageName: order.packageList?.first?.packageName ?? "eSIM",
            totalVolume: "",
            expiredTime: order.packageList?.first?.expiredTime ?? "",
            createdAt: Date()
        )
    }
    // MARK: - Usage

    public func fetchUsage(iccid: String) async throws -> ESIMUsage? {
        await AppLogger.shared.logData("Fetching usage for iccid: \(iccid)")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: UsageAPIResponse = try await apiClient.request(
            endpoint: "esim/usage?iccid=\(iccid)",
            requiresAuth: true
        )

        guard response.success == true, let d = response.data else { return nil }

        return ESIMUsage(
            id: d.iccid ?? iccid,
            iccid: d.iccid ?? iccid,
            totalBytes: Int64(d.totalVolume ?? 0),
            usedBytes: Int64(d.orderUsage ?? 0),
            remainingBytes: Int64(d.remainingData ?? 0),
            status: d.smdpStatus ?? "UNKNOWN",
            expiredTime: d.expiredTime ?? ""
        )
    }

    // MARK: - Top-Up

    public func fetchTopUpPackages(iccid: String) async throws -> [TopUpPackage] {
        await AppLogger.shared.logData("Fetching topup packages for iccid: \(iccid)")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: TopUpPackagesResponse = try await apiClient.request(
            endpoint: "esim/topup?iccid=\(iccid)",
            requiresAuth: true
        )

        return response.obj?.packageList?.compactMap { pkg -> TopUpPackage? in
            let volumeMB = pkg.volume ?? 0
            let volumeGB = volumeMB >= 1024 ? volumeMB / 1024 : max(1, volumeMB)

            return TopUpPackage(
                id: pkg.packageCode ?? UUID().uuidString,
                packageCode: pkg.packageCode ?? "",
                name: pkg.name ?? "Top-Up",
                dataGB: volumeGB,
                durationDays: pkg.duration ?? 0,
                priceUSD: pkg.price ?? 0
            )
        } ?? []
    }

    public func topUpESIM(iccid: String, packageCode: String) async throws -> Bool {
        await AppLogger.shared.logData("Topping up eSIM \(iccid) with package \(packageCode)")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let body: [String: Any] = [
            "iccid": iccid,
            "packageCode": packageCode,
            "transactionId": "dxb_topup_\(Int(Date().timeIntervalSince1970))"
        ]

        let response: SimpleResponse = try await apiClient.request(
            endpoint: "esim/topup",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        return response.success ?? false
    }

    // MARK: - Cancel Order

    public func cancelOrder(orderNo: String) async throws -> Bool {
        await AppLogger.shared.logData("Cancelling order: \(orderNo)")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let body: [String: Any] = ["orderNo": orderNo]

        let response: SimpleResponse = try await apiClient.request(
            endpoint: "esim/cancel",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        return response.success ?? false
    }

    // MARK: - Suspend / Resume

    public func suspendESIM(orderNo: String) async throws -> Bool {
        await AppLogger.shared.logData("Suspending eSIM: \(orderNo)")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let body: [String: Any] = ["orderNo": orderNo, "action": "suspend"]

        let response: SimpleResponse = try await apiClient.request(
            endpoint: "esim/suspend",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        return response.success ?? false
    }

    public func resumeESIM(orderNo: String) async throws -> Bool {
        await AppLogger.shared.logData("Resuming eSIM: \(orderNo)")

        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let body: [String: Any] = ["orderNo": orderNo, "action": "resume"]

        let response: SimpleResponse = try await apiClient.request(
            endpoint: "esim/suspend",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        return response.success ?? false
    }

    // MARK: - Offers (SimPass)

    public func fetchOffers(country: String? = nil, category: String? = nil) async throws -> [PartnerOfferResponse] {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        var endpoint = "offers?"
        if let c = country { endpoint += "country=\(c)&" }
        if let cat = category { endpoint += "category=\(cat)&" }

        let response: OffersListResponse = try await apiClient.request(
            endpoint: endpoint,
            requiresAuth: false
        )

        return response.data ?? []
    }

    public func trackOfferClick(offerId: String, country: String? = nil) async throws -> OfferClickResponse {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let body: [String: Any] = [
            "country": country ?? "",
            "source": "app",
        ]

        return try await apiClient.request(
            endpoint: "offers/\(offerId)/click",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }

    // MARK: - Subscriptions (SimPass)

    public func fetchMySubscription() async throws -> SubscriptionResponse? {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: SubscriptionWrapper = try await apiClient.request(
            endpoint: "subscriptions/me",
            requiresAuth: true
        )

        return response.data
    }

    public func createSubscription(plan: String, billingPeriod: String) async throws -> SubscriptionResponse {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let body: [String: Any] = [
            "plan": plan,
            "billing_period": billingPeriod,
        ]

        let response: SubscriptionWrapper = try await apiClient.request(
            endpoint: "subscriptions/create",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    // MARK: - Rewards (SimPass)

    public func fetchRewardsSummary() async throws -> RewardsSummaryResponse {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: RewardsSummaryWrapper = try await apiClient.request(
            endpoint: "rewards/summary",
            requiresAuth: true
        )

        guard let data = response.data else { throw APIError.invalidResponse }
        return data
    }

    public func dailyCheckin() async throws -> CheckinResponse {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        return try await apiClient.request(
            endpoint: "rewards/checkin",
            method: "POST",
            body: [:],
            requiresAuth: true
        )
    }

    // MARK: - Crypto Payments

    public func createCryptoInvoice(amountUSD: Double, asset: String) async throws -> CryptoInvoiceResponse {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let body: [String: Any] = [
            "amount_usd": amountUSD,
            "asset": asset
        ]

        let wrapper: CryptoInvoiceWrapper = try await apiClient.request(
            endpoint: "checkout/crypto",
            method: "POST",
            body: body,
            requiresAuth: true
        )

        guard let data = wrapper.data else { throw APIError.invalidResponse }
        return data
    }

    public func pollCryptoInvoice(invoiceId: String) async throws -> CryptoInvoiceResponse {
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let wrapper: CryptoInvoiceWrapper = try await apiClient.request(
            endpoint: "checkout/crypto/\(invoiceId)",
            method: "GET",
            requiresAuth: true
        )

        guard let data = wrapper.data else { throw APIError.invalidResponse }
        return data
    }

    // MARK: - Token Refresh

    public func refreshAccessToken() async throws -> AuthResponse {
        guard let refreshToken = try await authService.getRefreshToken() else {
            throw TokenError.noRefreshToken
        }

        let body: [String: Any] = ["refreshToken": refreshToken]

        let response: AuthResponse = try await apiClient.request(
            endpoint: "auth/refresh",
            method: "POST",
            body: body,
            requiresAuth: false
        )

        try await authService.saveTokens(access: response.accessToken, refresh: response.refreshToken)
        await apiClient.setAccessToken(response.accessToken)

        return response
    }
}

// MARK: - API Response Types

struct EmptyResponse: Codable {}

struct PackagesResponse: Codable {
    let obj: PackageList?
}

struct PackageList: Codable {
    let packageList: [PackageItem]?
}

struct PackageItem: Codable {
    let packageCode: String?
    let name: String?
    let location: String?
    let locationCode: String?
    let duration: Int?
    let volume: Int?
    let volumeDisplay: String?
    let price: Double?
    let costPrice: Double?
    let currencyCode: String?
    let speed: String?
    let locationNetworkList: [LocationNetwork]?
}

struct LocationNetwork: Codable {
    let locationName: String?
}

struct OrdersResponse: Codable {
    let obj: OrderList?
}

struct OrderList: Codable {
    let esimList: [EsimOrderItem]?
    let orderList: [OrderItem]?
}

struct EsimOrderItem: Codable {
    let esimTranNo: String?
    let orderNo: String?
    let iccid: String?
    let ac: String?
    let qrCodeUrl: String?
    let smdpStatus: String?
    let totalVolume: Int?
    let totalDuration: Int?
    let durationUnit: String?
    let expiredTime: String?
    let packageList: [PackageStatus]?
}

struct OrderItem: Codable {
    let orderNo: String?
    let esimList: [EsimItem]?
    let packageList: [PackageStatus]?
}

struct EsimItem: Codable {
    let iccid: String?
    let ac: String?
    let qrCodeUrl: String?
    let smdpStatus: String?
}

struct PackageStatus: Codable {
    let packageCode: String?
    let packageName: String?
    let totalVolume: Int?
    let expiredTime: String?
}

struct PurchaseResponse: Codable {
    let obj: OrderItem?
}

struct StockResponse: Codable {
    let obj: StockData?
}

struct StockData: Codable {
    let stats: StockStats?
    let byPackage: [PackageGroup]?
    let esimList: [StockEsimItem]?
}

struct StockStats: Codable {
    let total: Int?
    let available: Int?
    let inUse: Int?
    let expired: Int?
}

struct PackageGroup: Codable {
    let name: String?
    let count: Int?
    let volume: Int?
}

struct StockEsimItem: Codable {
    let esimTranNo: String?
    let orderNo: String?
    let iccid: String?
    let ac: String?
    let qrCodeUrl: String?
    let smdpStatus: String?
    let totalVolume: Int?
    let totalDuration: Int?
    let durationUnit: String?
    let expiredTime: String?
    let packageList: [StockPackage]?
}

struct StockPackage: Codable {
    let packageName: String?
    let packageCode: String?
    let slug: String?
    let duration: Int?
    let volume: Int?
    let locationCode: String?
}

// MARK: - Usage Response Types

struct UsageAPIResponse: Codable {
    let success: Bool?
    let data: UsageDataItem?
}

struct UsageDataItem: Codable {
    let iccid: String?
    let orderNo: String?
    let packageName: String?
    let status: String?
    let smdpStatus: String?
    let totalVolume: Int?
    let orderUsage: Int?
    let remainingData: Int?
    let usagePercent: Int?
    let expiredTime: String?
    let totalDuration: Int?
    let durationUnit: String?
}

// MARK: - TopUp Response Types

struct TopUpPackagesResponse: Codable {
    let obj: TopUpData?
}

struct TopUpData: Codable {
    let packageList: [TopUpPackageItem]?
}

struct TopUpPackageItem: Codable {
    let packageCode: String?
    let name: String?
    let volume: Int?
    let duration: Int?
    let price: Double?
}

// MARK: - Simple Response

struct SimpleResponse: Codable {
    let success: Bool?
    let message: String?
}

// MARK: - SimPass Response Types (Offers, Subscriptions, Rewards)

public struct PartnerOfferResponse: Codable, Identifiable {
    public let id: String
    public let partner_name: String?
    public let partner_slug: String?
    public let category: String?
    public let title: String?
    public let description: String?
    public let image_url: String?
    public let discount_percent: Int?
    public let discount_type: String?
    public let country_codes: [String]?
    public let city: String?
    public let is_global: Bool?
    public let tier_required: String?
}

struct OffersListResponse: Codable {
    let success: Bool?
    let data: [PartnerOfferResponse]?
}

public struct OfferClickResponse: Codable {
    public let success: Bool?
    public let data: OfferClickData?
}

public struct OfferClickData: Codable {
    public let redirectUrl: String?
}

public struct SubscriptionResponse: Codable {
    public let id: String?
    public let plan: String?
    public let status: String?
    public let billing_period: String?
    public let discount_percent: Int?
    public let current_period_end: String?
    public let cancel_at_period_end: Bool?
    public let discounts_remaining: Int?
}

struct SubscriptionWrapper: Codable {
    let success: Bool?
    let data: SubscriptionResponse?
}

public struct RewardsSummaryResponse: Codable {
    public let wallet: WalletData?
    public let missions: [MissionData]?
    public let raffles: [RaffleData]?
    public let recent_transactions: [TransactionData]?
}

public struct WalletData: Codable {
    public let xp_total: Int?
    public let level: Int?
    public let points_balance: Int?
    public let points_earned_total: Int?
    public let tickets_balance: Int?
    public let tier: String?
    public let streak_days: Int?
    public let last_checkin: String?
}

public struct MissionData: Codable, Identifiable {
    public let id: String
    public let type: String?
    public let title: String?
    public let description: String?
    public let xp_reward: Int?
    public let points_reward: Int?
    public let condition_value: Int?
    public let user_progress: Int?
    public let user_completed: Bool?
}

public struct RaffleData: Codable, Identifiable {
    public let id: String
    public let title: String?
    public let prize_description: String?
    public let draw_date: String?
    public let image_url: String?
}

public struct TransactionData: Codable, Identifiable {
    public let id: String
    public let type: String?
    public let delta: Int?
    public let reason: String?
    public let description: String?
}

struct RewardsSummaryWrapper: Codable {
    let success: Bool?
    let data: RewardsSummaryResponse?
}

public struct CheckinResponse: Codable {
    public let success: Bool?
    public let data: CheckinData?
}

public struct CheckinData: Codable {
    public let streak_days: Int?
    public let date: String?
}

public struct CryptoInvoiceResponse: Codable {
    public let id: String?
    public let status: String?
    public let amount_usd: Double?
    public let asset: String?
    public let deposit_address: String?
    public let expires_at: String?
    public let payments: [CryptoPaymentEntry]?
}

public struct CryptoPaymentEntry: Codable {
    public let tx_hash: String?
    public let amount: String?
    public let status: String?
}

struct CryptoInvoiceWrapper: Codable {
    let success: Bool?
    let data: CryptoInvoiceResponse?
}
