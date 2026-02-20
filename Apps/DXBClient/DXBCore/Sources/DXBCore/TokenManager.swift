import Foundation

// MARK: - Token Manager

/// Gestionnaire de tokens avec refresh automatique
public actor TokenManager {
    private let authService: AuthServiceProtocol
    private var apiClient: APIClient?
    private var tokenExpiryDate: Date?
    private let refreshThreshold: TimeInterval = 300
    private var isRefreshing = false

    public init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    public func setAPIClient(_ client: APIClient) {
        self.apiClient = client
    }

    public func getValidToken() async throws -> String? {
        guard let token = try await authService.getAccessToken() else {
            return nil
        }

        if let expiryDate = getTokenExpiry(from: token) {
            tokenExpiryDate = expiryDate

            if Date().addingTimeInterval(refreshThreshold) > expiryDate {
                return try await refreshToken()
            }
        }

        return token
    }

    private func refreshToken() async throws -> String? {
        guard !isRefreshing else {
            return try await authService.getAccessToken()
        }

        guard let refreshTokenValue = try await authService.getRefreshToken() else {
            throw TokenError.noRefreshToken
        }

        guard let client = apiClient else {
            throw TokenError.refreshFailed
        }

        isRefreshing = true
        defer { isRefreshing = false }

        let body: [String: Any] = ["refreshToken": refreshTokenValue]

        do {
            let response: AuthResponse = try await client.request(
                endpoint: "auth/refresh",
                method: "POST",
                body: body,
                requiresAuth: false
            )

            try await authService.saveTokens(access: response.accessToken, refresh: response.refreshToken)
            await client.setAccessToken(response.accessToken)

            return response.accessToken
        } catch {
            throw TokenError.refreshFailed
        }
    }

    /// Extrait la date d'expiration d'un JWT
    private func getTokenExpiry(from token: String) -> Date? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }

        // Décoder la partie payload (base64)
        guard let payloadData = base64UrlDecode(parts[1]),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            return nil
        }

        return Date(timeIntervalSince1970: exp)
    }

    /// Décode une chaîne base64 URL-safe
    private func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Ajouter le padding si nécessaire
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        return Data(base64Encoded: base64)
    }
}

// MARK: - Token Error

public enum TokenError: LocalizedError {
    case noRefreshToken
    case refreshFailed
    case invalidToken

    public var errorDescription: String? {
        switch self {
        case .noRefreshToken:
            return "No refresh token available"
        case .refreshFailed:
            return "Failed to refresh access token"
        case .invalidToken:
            return "Invalid token format"
        }
    }
}
