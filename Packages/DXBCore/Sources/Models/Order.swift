import Foundation

public enum OrderStatus: String, Codable {
    case pending = "PENDING"
    case paid = "PAID"
    case fulfilling = "FULFILLING"
    case delivered = "DELIVERED"
    case active = "ACTIVE"
    case expired = "EXPIRED"
    case failed = "FAILED"
    case refunded = "REFUNDED"
}

public struct Order: Codable, Identifiable {
    public let id: String
    public let plan: Plan
    public let amount: Decimal
    public let currency: String
    public let status: OrderStatus
    public let createdAt: Date
    public let esim: ESIMInfo?
    
    public init(
        id: String,
        plan: Plan,
        amount: Decimal,
        currency: String = "USD",
        status: OrderStatus,
        createdAt: Date,
        esim: ESIMInfo? = nil
    ) {
        self.id = id
        self.plan = plan
        self.amount = amount
        self.currency = currency
        self.status = status
        self.createdAt = createdAt
        self.esim = esim
    }
    
    enum CodingKeys: String, CodingKey {
        case id, plan, amount, currency, status, esim
        case createdAt = "created_at"
    }
}

public struct ESIMInfo: Codable {
    public let qrCodeURL: String?
    public let activationCode: String?
    public let smdpAddress: String?
    public let usage: ESIMUsage?
    
    public init(
        qrCodeURL: String?,
        activationCode: String?,
        smdpAddress: String?,
        usage: ESIMUsage? = nil
    ) {
        self.qrCodeURL = qrCodeURL
        self.activationCode = activationCode
        self.smdpAddress = smdpAddress
        self.usage = usage
    }
    
    enum CodingKeys: String, CodingKey {
        case usage
        case qrCodeURL = "qr_code_url"
        case activationCode = "activation_code"
        case smdpAddress = "smdp_address"
    }
}

public struct ESIMUsage: Codable {
    public let dataUsedMB: Int
    public let dataTotalMB: Int
    public let lastUpdated: Date
    
    public var usagePercentage: Double {
        guard dataTotalMB > 0 else { return 0 }
        return Double(dataUsedMB) / Double(dataTotalMB)
    }
    
    public init(dataUsedMB: Int, dataTotalMB: Int, lastUpdated: Date) {
        self.dataUsedMB = dataUsedMB
        self.dataTotalMB = dataTotalMB
        self.lastUpdated = lastUpdated
    }
    
    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case dataUsedMB = "data_used_mb"
        case dataTotalMB = "data_total_mb"
    }
}

// Mock data
public extension Order {
    static let mockPending = Order(
        id: "ord_pending",
        plan: .mock3Days,
        amount: 15.00,
        status: .pending,
        createdAt: Date()
    )
    
    static let mockDelivered = Order(
        id: "ord_delivered",
        plan: .mock7Days,
        amount: 29.00,
        status: .delivered,
        createdAt: Date().addingTimeInterval(-86400),
        esim: ESIMInfo(
            qrCodeURL: "https://example.com/qr/abc123",
            activationCode: "LPA:1$smdp.example.com$ABC123",
            smdpAddress: "smdp.example.com",
            usage: ESIMUsage(dataUsedMB: 2048, dataTotalMB: 10240, lastUpdated: Date())
        )
    )
    
    static let mockActive = Order(
        id: "ord_active",
        plan: .mock15Days,
        amount: 49.00,
        status: .active,
        createdAt: Date().addingTimeInterval(-172800),
        esim: ESIMInfo(
            qrCodeURL: "https://example.com/qr/xyz789",
            activationCode: "LPA:1$smdp.example.com$XYZ789",
            smdpAddress: "smdp.example.com",
            usage: ESIMUsage(dataUsedMB: 5120, dataTotalMB: 20480, lastUpdated: Date())
        )
    )
    
    static let mockOrders = [mockDelivered, mockActive, mockPending]
}
