import Foundation

// MARK: - API Service Protocol

public protocol DXBAPIServiceProtocol: Sendable {
    func signInWithApple(identityToken: String, authorizationCode: String, user: AppleUserInfo) async throws -> AuthResponse
    func signInWithEmail(email: String) async throws
    func verifyOTP(email: String, otp: String) async throws -> AuthResponse
    func fetchPlans(locale: String) async throws -> [Plan]
    func fetchMyESIMs() async throws -> [ESIMOrder]
    func purchasePlan(planId: String) async throws -> ESIMOrder
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

    public func fetchPlans(locale: String) async throws -> [Plan] {
        await AppLogger.shared.logData("Fetching eSIM plans (locale: \(locale))")

        // Load token if available
        if let token = try await authService.getAccessToken() {
            await apiClient.setAccessToken(token)
        }

        let response: PackagesResponse = try await apiClient.request(
            endpoint: "esim/packages",
            requiresAuth: false
        )

        let plans = response.obj?.packageList?.compactMap { pkg in
            Plan(
                id: pkg.packageCode ?? UUID().uuidString,
                name: pkg.name ?? "eSIM Plan",
                description: "\(pkg.locationNetworkList?.first?.locationName ?? pkg.location ?? "Global") - \(pkg.duration ?? 0) days",
                dataGB: Int((pkg.volume ?? 0) / 1_073_741_824), // bytes to GB
                durationDays: pkg.duration ?? 0,
                priceUSD: Double(pkg.price ?? 0) / 10000.0,
                speed: pkg.speed ?? "4G/LTE",
                location: pkg.locationNetworkList?.first?.locationName ?? pkg.location ?? "Global",
                locationCode: pkg.locationCode ?? ""
            )
        } ?? []

        await AppLogger.shared.logData("Fetched \(plans.count) plans")
        return plans
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

        let orders = response.obj?.orderList?.compactMap { order in
            ESIMOrder(
                id: order.orderNo ?? UUID().uuidString,
                orderNo: order.orderNo ?? "",
                iccid: order.esimList?.first?.iccid ?? "",
                lpaCode: order.esimList?.first?.ac ?? "",
                qrCodeUrl: order.esimList?.first?.qrCodeUrl ?? "",
                status: order.esimList?.first?.smdpStatus ?? "UNKNOWN",
                packageName: order.packageList?.first?.packageName ?? "eSIM",
                totalVolume: "\((order.packageList?.first?.totalVolume ?? 0) / 1_073_741_824) GB", // bytes to GB
                expiredTime: order.packageList?.first?.expiredTime ?? "",
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

        return ESIMOrder(
            id: order.orderNo ?? UUID().uuidString,
            orderNo: order.orderNo ?? "",
            iccid: order.esimList?.first?.iccid ?? "",
            lpaCode: order.esimList?.first?.ac ?? "",
            qrCodeUrl: order.esimList?.first?.qrCodeUrl ?? "",
            status: "PENDING",
            packageName: "eSIM",
            totalVolume: "",
            expiredTime: "",
            createdAt: Date()
        )
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
    let volume: Int64?
    let price: Int?
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
    let orderList: [OrderItem]?
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
    let packageName: String?
    let totalVolume: Int?
    let expiredTime: String?
}

struct PurchaseResponse: Codable {
    let obj: OrderItem?
}
