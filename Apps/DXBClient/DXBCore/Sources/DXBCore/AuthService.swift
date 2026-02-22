import Foundation
import Security

// MARK: - Auth Service Protocol

public protocol AuthServiceProtocol: Sendable {
    func isAuthenticated() async -> Bool
    func getAccessToken() async throws -> String?
    func getRefreshToken() async throws -> String?
    func saveTokens(access: String, refresh: String?) async throws
    func clearTokens() async throws
}

// MARK: - Auth Service Implementation

public actor AuthService: AuthServiceProtocol {
    private let keychainService = "com.dxbconnect.app"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    public init() {}
    
    public func isAuthenticated() async -> Bool {
        do {
            guard let token = try await getAccessToken() else { return false }
            return !token.isEmpty
        } catch {
            return false
        }
    }
    
    public func getAccessToken() async throws -> String? {
        return try getKeychainItem(key: accessTokenKey)
    }
    
    public func getRefreshToken() async throws -> String? {
        return try getKeychainItem(key: refreshTokenKey)
    }
    
    public func saveTokens(access: String, refresh: String?) async throws {
        try saveKeychainItem(key: accessTokenKey, value: access)
        if let refresh = refresh {
            try saveKeychainItem(key: refreshTokenKey, value: refresh)
        }
    }
    
    public func clearTokens() async throws {
        try deleteKeychainItem(key: accessTokenKey)
        try deleteKeychainItem(key: refreshTokenKey)
    }
    
    // MARK: - Keychain Helpers
    
    private func saveKeychainItem(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else { throw KeychainError.saveFailed }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
        
        var newItem = query
        newItem[kSecValueData as String] = data
        
        let status = SecItemAdd(newItem as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    private func getKeychainItem(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.readFailed
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    private func deleteKeychainItem(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed
        }
    }
}

public enum KeychainError: LocalizedError {
    case saveFailed
    case readFailed
    case deleteFailed
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed: return "Failed to save credentials"
        case .readFailed: return "Failed to read credentials"
        case .deleteFailed: return "Failed to delete credentials"
        }
    }
}
