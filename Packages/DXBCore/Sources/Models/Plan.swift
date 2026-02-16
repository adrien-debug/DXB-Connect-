import Foundation

public struct Plan: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let dataGB: Int
    public let durationDays: Int
    public let priceUSD: Decimal
    public let currency: String
    public let coverage: [String]
    public let speed: String
    public let fairUsageGB: Int
    public let active: Bool
    
    public init(
        id: String,
        name: String,
        description: String,
        dataGB: Int,
        durationDays: Int,
        priceUSD: Decimal,
        currency: String = "USD",
        coverage: [String],
        speed: String,
        fairUsageGB: Int,
        active: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.dataGB = dataGB
        self.durationDays = durationDays
        self.priceUSD = priceUSD
        self.currency = currency
        self.coverage = coverage
        self.speed = speed
        self.fairUsageGB = fairUsageGB
        self.active = active
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, currency, coverage, speed, active
        case dataGB = "data_gb"
        case durationDays = "duration_days"
        case priceUSD = "price_usd"
        case fairUsageGB = "fair_usage_gb"
    }
}

// Mock data for previews
public extension Plan {
    static let mock3Days = Plan(
        id: "plan_3d_5gb",
        name: "3 Days - 5GB",
        description: "Perfect for short trips",
        dataGB: 5,
        durationDays: 3,
        priceUSD: 15.00,
        coverage: ["Dubai", "UAE"],
        speed: "4G/5G",
        fairUsageGB: 5
    )
    
    static let mock7Days = Plan(
        id: "plan_7d_10gb",
        name: "7 Days - 10GB",
        description: "Ideal for business travelers",
        dataGB: 10,
        durationDays: 7,
        priceUSD: 29.00,
        coverage: ["Dubai", "UAE"],
        speed: "4G/5G",
        fairUsageGB: 10
    )
    
    static let mock15Days = Plan(
        id: "plan_15d_20gb",
        name: "15 Days - 20GB",
        description: "Extended stay package",
        dataGB: 20,
        durationDays: 15,
        priceUSD: 49.00,
        coverage: ["Dubai", "UAE"],
        speed: "4G/5G",
        fairUsageGB: 20
    )
    
    static let mockPlans = [mock3Days, mock7Days, mock15Days]
}
