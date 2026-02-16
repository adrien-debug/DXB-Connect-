import Foundation

public final class MockESIMProvider: ESIMProvider {
    public init() {}
    
    public func fetchPlans() async throws -> [ESIMPlan] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        return [
            ESIMPlan(id: "mock_3d", name: "3 Days - 5GB", dataGB: 5, durationDays: 3, priceUSD: 15, coverage: ["Dubai"]),
            ESIMPlan(id: "mock_7d", name: "7 Days - 10GB", dataGB: 10, durationDays: 7, priceUSD: 29, coverage: ["Dubai"]),
            ESIMPlan(id: "mock_15d", name: "15 Days - 20GB", dataGB: 20, durationDays: 15, priceUSD: 49, coverage: ["Dubai"])
        ]
    }
    
    public func quote(planId: String) async throws -> Decimal {
        return 15.0
    }
    
    public func reserveProfile(planId: String, idempotencyKey: String) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1s
        return "reservation_\(UUID().uuidString)"
    }
    
    public func deliverProfile(reservationId: String, idempotencyKey: String) async throws -> ESIMProfile {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let iccid = "89971234567890123456"
        let activationCode = "LPA:1$smdp.example.com$\(UUID().uuidString)"
        return ESIMProfile(
            id: UUID().uuidString,
            iccid: iccid,
            smdpAddress: "smdp.example.com",
            activationCode: activationCode,
            qrCodeData: activationCode,
            expiresAt: Date().addingTimeInterval(86400 * 3)
        )
    }
    
    public func getUsage(iccid: String) async throws -> ESIMUsage? {
        return ESIMUsage(dataUsedMB: 2048, dataTotalMB: 5120, lastUpdated: Date())
    }
    
    public func cancelProfile(profileId: String, reason: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}
