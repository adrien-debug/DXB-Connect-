import Foundation

public protocol DXBAPIServiceProtocol {
    // Auth
    func signInWithApple(identityToken: String, authorizationCode: String, user: AppleUserInfo?) async throws -> AuthResponse
    func signInWithEmail(email: String) async throws
    func verifyOTP(email: String, otp: String) async throws -> AuthResponse
    func refreshToken(refreshToken: String) async throws -> String
    
    // Catalog
    func fetchPlans(locale: String) async throws -> [Plan]
    func fetchPlan(id: String) async throws -> Plan
    
    // Checkout
    func createPaymentIntent(planId: String, promoCode: String?, idempotencyKey: String) async throws -> CheckoutResponse
    
    // Orders
    func fetchOrders(status: OrderStatus?, limit: Int, offset: Int) async throws -> OrdersResponse
    func fetchOrder(id: String) async throws -> Order
    func resendQR(orderId: String) async throws
    
    // eSIM
    func fetchUsage(orderId: String) async throws -> ESIMUsage?
    
    // Support
    func createTicket(subject: String, message: String, orderId: String?) async throws -> Ticket
    func fetchTickets() async throws -> [Ticket]
}

public struct AppleUserInfo: Codable {
    public let email: String?
    public let name: String?
    
    public init(email: String?, name: String?) {
        self.email = email
        self.name = name
    }
}

public struct CheckoutResponse: Codable {
    public let orderId: String
    public let stripeCheckoutURL: String
    public let amount: Decimal
    public let currency: String
    
    enum CodingKeys: String, CodingKey {
        case amount, currency
        case orderId = "order_id"
        case stripeCheckoutURL = "stripe_checkout_url"
    }
}

public struct OrdersResponse: Codable {
    public let orders: [Order]
    public let total: Int
    public let limit: Int
    public let offset: Int
}

public struct Ticket: Codable, Identifiable {
    public let id: String
    public let subject: String
    public let status: String
    public let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, subject, status
        case createdAt = "created_at"
    }
}

public final class DXBAPIService: DXBAPIServiceProtocol {
    private let apiClient: APIClientProtocol
    private let authService: AuthServiceProtocol
    
    public init(apiClient: APIClientProtocol, authService: AuthServiceProtocol) {
        self.apiClient = apiClient
        self.authService = authService
    }
    
    private func authorizedHeaders() async throws -> [String: String] {
        guard let token = try await authService.getAccessToken() else {
            throw APIError.unauthorized
        }
        return ["Authorization": "Bearer \(token)"]
    }
    
    // MARK: - Auth
    
    public func signInWithApple(
        identityToken: String,
        authorizationCode: String,
        user: AppleUserInfo?
    ) async throws -> AuthResponse {
        struct Request: Encodable {
            let identityToken: String
            let authorizationCode: String
            let user: AppleUserInfo?
        }
        
        let response: AuthResponse = try await apiClient.request(
            endpoint: "/auth/signin/apple",
            method: .post,
            body: Request(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                user: user
            ),
            headers: nil
        )
        
        try await authService.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        return response
    }
    
    public func signInWithEmail(email: String) async throws {
        struct Request: Encodable {
            let email: String
        }
        
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/auth/signin/email",
            method: .post,
            body: Request(email: email),
            headers: nil
        )
    }
    
    public func verifyOTP(email: String, otp: String) async throws -> AuthResponse {
        struct Request: Encodable {
            let email: String
            let otp: String
        }
        
        let response: AuthResponse = try await apiClient.request(
            endpoint: "/auth/verify-otp",
            method: .post,
            body: Request(email: email, otp: otp),
            headers: nil
        )
        
        try await authService.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
        
        return response
    }
    
    public func refreshToken(refreshToken: String) async throws -> String {
        struct Request: Encodable {
            let refreshToken: String
        }
        
        struct Response: Decodable {
            let accessToken: String
        }
        
        let response: Response = try await apiClient.request(
            endpoint: "/auth/refresh",
            method: .post,
            body: Request(refreshToken: refreshToken),
            headers: nil
        )
        
        return response.accessToken
    }
    
    // MARK: - Catalog
    
    public func fetchPlans(locale: String = "en") async throws -> [Plan] {
        struct Response: Decodable {
            let plans: [Plan]
        }
        
        let response: Response = try await apiClient.request(
            endpoint: "/catalog/plans?locale=\(locale)",
            method: .get,
            body: nil as EmptyResponse?,
            headers: nil
        )
        
        return response.plans
    }
    
    public func fetchPlan(id: String) async throws -> Plan {
        return try await apiClient.request(
            endpoint: "/catalog/plans/\(id)",
            method: .get,
            body: nil as EmptyResponse?,
            headers: nil
        )
    }
    
    // MARK: - Checkout
    
    public func createPaymentIntent(
        planId: String,
        promoCode: String?,
        idempotencyKey: String
    ) async throws -> CheckoutResponse {
        struct Request: Encodable {
            let planId: String
            let promoCode: String?
            let idempotencyKey: String
        }
        
        let headers = try await authorizedHeaders()
        
        return try await apiClient.request(
            endpoint: "/checkout/create-payment-intent",
            method: .post,
            body: Request(
                planId: planId,
                promoCode: promoCode,
                idempotencyKey: idempotencyKey
            ),
            headers: headers
        )
    }
    
    // MARK: - Orders
    
    public func fetchOrders(
        status: OrderStatus? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) async throws -> OrdersResponse {
        var endpoint = "/orders?limit=\(limit)&offset=\(offset)"
        if let status = status {
            endpoint += "&status=\(status.rawValue.lowercased())"
        }
        
        let headers = try await authorizedHeaders()
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: .get,
            body: nil as EmptyResponse?,
            headers: headers
        )
    }
    
    public func fetchOrder(id: String) async throws -> Order {
        let headers = try await authorizedHeaders()
        
        return try await apiClient.request(
            endpoint: "/orders/\(id)",
            method: .get,
            body: nil as EmptyResponse?,
            headers: headers
        )
    }
    
    public func resendQR(orderId: String) async throws {
        let headers = try await authorizedHeaders()
        
        let _: EmptyResponse = try await apiClient.request(
            endpoint: "/orders/\(orderId)/resend-qr",
            method: .post,
            body: nil as EmptyResponse?,
            headers: headers
        )
    }
    
    // MARK: - eSIM
    
    public func fetchUsage(orderId: String) async throws -> ESIMUsage? {
        let headers = try await authorizedHeaders()
        
        struct Response: Decodable {
            let available: Bool?
            let dataUsedMB: Int?
            let dataTotalMB: Int?
            let lastUpdated: Date?
            
            var usage: ESIMUsage? {
                guard available == true,
                      let dataUsedMB = dataUsedMB,
                      let dataTotalMB = dataTotalMB,
                      let lastUpdated = lastUpdated else {
                    return nil
                }
                return ESIMUsage(
                    dataUsedMB: dataUsedMB,
                    dataTotalMB: dataTotalMB,
                    lastUpdated: lastUpdated
                )
            }
        }
        
        let response: Response = try await apiClient.request(
            endpoint: "/esim/\(orderId)/usage",
            method: .get,
            body: nil as EmptyResponse?,
            headers: headers
        )
        
        return response.usage
    }
    
    // MARK: - Support
    
    public func createTicket(
        subject: String,
        message: String,
        orderId: String?
    ) async throws -> Ticket {
        struct Request: Encodable {
            let subject: String
            let message: String
            let orderId: String?
        }
        
        let headers = try await authorizedHeaders()
        
        return try await apiClient.request(
            endpoint: "/support/tickets",
            method: .post,
            body: Request(subject: subject, message: message, orderId: orderId),
            headers: headers
        )
    }
    
    public func fetchTickets() async throws -> [Ticket] {
        struct Response: Decodable {
            let tickets: [Ticket]
        }
        
        let headers = try await authorizedHeaders()
        
        let response: Response = try await apiClient.request(
            endpoint: "/support/tickets",
            method: .get,
            body: nil as EmptyResponse?,
            headers: headers
        )
        
        return response.tickets
    }
}
