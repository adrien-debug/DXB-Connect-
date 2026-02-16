import Foundation
import Security

public protocol AuthServiceProtocol {
    func saveTokens(accessToken: String, refreshToken: String) async throws
    func getAccessToken() async throws -> String?
    func getRefreshToken() async throws -> String?
    func clearTokens() async throws
    func isAuthenticated() async -> Bool
}

public final class AuthService: AuthServiceProtocol {
    private let keychainService = "com.dxbconnect.app"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    public init() {}
    
    public func saveTokens(accessToken: String, refreshToken: String) async throws {
        try saveToKeychain(key: accessTokenKey, value: accessToken)
        try saveToKeychain(key: refreshTokenKey, value: refreshToken)
    }
    
    public func getAccessToken() async throws -> String? {
        return try readFromKeychain(key: accessTokenKey)
    }
    
    public func getRefreshToken() async throws -> String? {
        return try readFromKeychain(key: refreshTokenKey)
    }
    
    public func clearTokens() async throws {
        try deleteFromKeychain(key: accessTokenKey)
        try deleteFromKeychain(key: refreshTokenKey)
    }
    
    public func isAuthenticated() async -> Bool {
        guard let token = try? await getAccessToken(), !token.isEmpty else {
            return false
        }
        
        // TODO: Validate JWT expiry
        return true
    }
    
    // MARK: - Keychain Helpers
    
    private func saveToKeychain(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.encodingError
        }
        
        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)
        
        // Add new item
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }
    
    private func readFromKeychain(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.readFailed(status: status)
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingError
        }
        
        return string
    }
    
    private func deleteFromKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }
}

public enum KeychainError: Error, LocalizedError {
    case encodingError
    case decodingError
    case saveFailed(status: OSStatus)
    case readFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .encodingError:
            return "Failed to encode data"
        case .decodingError:
            return "Failed to decode data"
        case .saveFailed(let status):
            return "Failed to save to keychain (status: \(status))"
        case .readFailed(let status):
            return "Failed to read from keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from keychain (status: \(status))"
        }
    }
}
