import Foundation

public enum AdminRole: String, Codable {
    case admin
    case support
    case finance
    
    public var displayName: String {
        switch self {
        case .admin: return "Administrator"
        case .support: return "Support"
        case .finance: return "Finance"
        }
    }
}

public struct AdminUser: Codable, Identifiable {
    public let id: String
    public let email: String
    public let name: String
    public let role: AdminRole
    public let active: Bool
    public let createdAt: Date
    
    public init(id: String, email: String, name: String, role: AdminRole, active: Bool, createdAt: Date) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.active = active
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, role, active
        case createdAt = "created_at"
    }
}

public extension AdminUser {
    static let mockAdmin = AdminUser(
        id: "admin_1",
        email: "admin@dxbconnect.com",
        name: "Admin User",
        role: .admin,
        active: true,
        createdAt: Date()
    )
}

public struct AuditLog: Codable, Identifiable {
    public let id: String
    public let adminUserId: String
    public let action: String
    public let resourceType: String?
    public let resourceId: String?
    public let ip: String
    public let details: [String: String]?
    public let createdAt: Date
    
    public init(id: String, adminUserId: String, action: String, resourceType: String?, resourceId: String?, ip: String, details: [String: String]?, createdAt: Date) {
        self.id = id
        self.adminUserId = adminUserId
        self.action = action
        self.resourceType = resourceType
        self.resourceId = resourceId
        self.ip = ip
        self.details = details
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, action, ip, details
        case adminUserId = "admin_user_id"
        case resourceType = "resource_type"
        case resourceId = "resource_id"
        case createdAt = "created_at"
    }
}
