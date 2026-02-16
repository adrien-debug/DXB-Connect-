import Foundation

public enum ESIMProviderError: Error, LocalizedError {
    case networkError(Error)
    case invalidResponse
    case insufficientStock
    case providerError(code: String, message: String)
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from provider"
        case .insufficientStock:
            return "Insufficient eSIM stock"
        case .providerError(let code, let message):
            return "Provider error (\(code)): \(message)"
        case .timeout:
            return "Request timeout"
        }
    }
}

public struct ESIMPlan: Codable {
    public let id: String
    public let name: String
    public let dataGB: Int
    public let durationDays: Int
    public let priceUSD: Decimal
    public let coverage: [String]
    
    public init(id: String, name: String, dataGB: Int, durationDays: Int, priceUSD: Decimal, coverage: [String]) {
        self.id = id
        self.name = name
        self.dataGB = dataGB
        self.durationDays = durationDays
        self.priceUSD = priceUSD
        self.coverage = coverage
    }
}

public struct ESIMProfile: Codable {
    public let id: String
    public let iccid: String
    public let smdpAddress: String
    public let activationCode: String
    public let qrCodeData: String
    public let expiresAt: Date?
    
    public init(id: String, iccid: String, smdpAddress: String, activationCode: String, qrCodeData: String, expiresAt: Date?) {
        self.id = id
        self.iccid = iccid
        self.smdpAddress = smdpAddress
        self.activationCode = activationCode
        self.qrCodeData = qrCodeData
        self.expiresAt = expiresAt
    }
}

public protocol ESIMProvider {
    /// Fetch available plans from supplier
    func fetchPlans() async throws -> [ESIMPlan]
    
    /// Get quote for a plan (optional, if pricing dynamic)
    func quote(planId: String) async throws -> Decimal
    
    /// Reserve a profile (pre-allocation before payment)
    func reserveProfile(planId: String, idempotencyKey: String) async throws -> String
    
    /// Deliver profile (after payment confirmed)
    func deliverProfile(reservationId: String, idempotencyKey: String) async throws -> ESIMProfile
    
    /// Get usage data (if supported)
    func getUsage(iccid: String) async throws -> ESIMUsage?
    
    /// Cancel/refund (if supported)
    func cancelProfile(profileId: String, reason: String) async throws
}
