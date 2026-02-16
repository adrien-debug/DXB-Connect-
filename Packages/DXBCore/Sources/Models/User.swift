import Foundation

public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public let name: String?
    public let createdAt: Date
    
    public init(id: String, email: String, name: String?, createdAt: Date) {
        self.id = id
        self.email = email
        self.name = name
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, name
        case createdAt = "created_at"
    }
}

public struct AuthResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let user: User
    
    public init(accessToken: String, refreshToken: String, user: User) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
