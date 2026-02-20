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

// MARK: - eSIM Usage

public struct ESIMUsage: Identifiable, Codable {
    public let id: String
    public let iccid: String
    public let totalBytes: Int64
    public let usedBytes: Int64
    public let remainingBytes: Int64
    public let status: String
    public let expiredTime: String

    public var usagePercentage: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    public var totalDisplay: String { formatBytes(totalBytes) }
    public var usedDisplay: String { formatBytes(usedBytes) }
    public var remainingDisplay: String { formatBytes(remainingBytes) }

    private func formatBytes(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        if gb >= 1 { return String(format: "%.1f GB", gb) }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.0f MB", mb)
    }

    public init(id: String, iccid: String, totalBytes: Int64, usedBytes: Int64, remainingBytes: Int64, status: String, expiredTime: String) {
        self.id = id
        self.iccid = iccid
        self.totalBytes = totalBytes
        self.usedBytes = usedBytes
        self.remainingBytes = remainingBytes
        self.status = status
        self.expiredTime = expiredTime
    }
}

// MARK: - TopUp Package

public struct TopUpPackage: Identifiable, Codable, Hashable {
    public let id: String
    public let packageCode: String
    public let name: String
    public let dataGB: Int
    public let durationDays: Int
    public let priceUSD: Double

    public init(id: String, packageCode: String, name: String, dataGB: Int, durationDays: Int, priceUSD: Double) {
        self.id = id
        self.packageCode = packageCode
        self.name = name
        self.dataGB = dataGB
        self.durationDays = durationDays
        self.priceUSD = priceUSD
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
