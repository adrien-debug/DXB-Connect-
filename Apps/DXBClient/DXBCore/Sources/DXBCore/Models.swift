import Foundation

// MARK: - Plan

public struct Plan: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let dataGB: Int
    public let durationDays: Int
    public let priceUSD: Double
    public let speed: String
    public let location: String
    public let locationCode: String
    
    public init(id: String, name: String, description: String, dataGB: Int, durationDays: Int, priceUSD: Double, speed: String, location: String, locationCode: String) {
        self.id = id
        self.name = name
        self.description = description
        self.dataGB = dataGB
        self.durationDays = durationDays
        self.priceUSD = priceUSD
        self.speed = speed
        self.location = location
        self.locationCode = locationCode
    }
}

// MARK: - ESIMOrder

public struct ESIMOrder: Identifiable, Codable, Hashable {
    public let id: String
    public let orderNo: String
    public let iccid: String
    public let lpaCode: String
    public let qrCodeUrl: String
    public let status: String
    public let packageName: String
    public let totalVolume: String
    public let expiredTime: String
    public let createdAt: Date
    
    public init(id: String, orderNo: String, iccid: String, lpaCode: String, qrCodeUrl: String, status: String, packageName: String, totalVolume: String, expiredTime: String, createdAt: Date) {
        self.id = id
        self.orderNo = orderNo
        self.iccid = iccid
        self.lpaCode = lpaCode
        self.qrCodeUrl = qrCodeUrl
        self.status = status
        self.packageName = packageName
        self.totalVolume = totalVolume
        self.expiredTime = expiredTime
        self.createdAt = createdAt
    }
}

// MARK: - Auth

public struct AuthResponse: Codable {
    public let accessToken: String
    public let refreshToken: String?
    public let user: UserInfo
}

public struct UserInfo: Codable {
    public let id: String
    public let email: String?
    public let name: String?
}

public struct AppleUserInfo {
    public let email: String?
    public let name: String?
    
    public init(email: String?, name: String?) {
        self.email = email
        self.name = name
    }
}

// MARK: - Extensions

extension Double {
    public var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}
