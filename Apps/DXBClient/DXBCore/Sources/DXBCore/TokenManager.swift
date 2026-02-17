import Foundation

// MARK: - Token Manager

/// Gestionnaire de tokens avec refresh automatique
public actor TokenManager {
    private let authService: AuthServiceProtocol
    private var tokenExpiryDate: Date?
    private let refreshThreshold: TimeInterval = 300 // 5 minutes

    public init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    /// Récupère un token valide, le rafraîchit si nécessaire
    public func getValidToken() async throws -> String? {
        guard let token = try await authService.getAccessToken() else {
            return nil
        }

        // Vérifier si le token expire bientôt
        if let expiryDate = getTokenExpiry(from: token) {
            tokenExpiryDate = expiryDate

            // Si le token expire dans moins de 5 minutes, le rafraîchir
            if Date().addingTimeInterval(refreshThreshold) > expiryDate {
                print("[TokenManager] Token expires soon, refreshing...")
                return try await refreshToken()
            }
        }

        return token
    }

    /// Rafraîchit le token d'accès
    private func refreshToken() async throws -> String? {
        guard let refreshToken = try await authService.getRefreshToken() else {
            throw TokenError.noRefreshToken
        }

        // TODO: Appeler l'endpoint /api/auth/refresh
        // Pour l'instant, retourner le token actuel
        // À implémenter quand l'endpoint sera créé

        print("[TokenManager] Refresh token endpoint not yet implemented")
        return try await authService.getAccessToken()
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
