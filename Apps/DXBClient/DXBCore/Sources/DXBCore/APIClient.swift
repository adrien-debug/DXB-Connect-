import Foundation

// MARK: - API Client

public actor APIClient {
    private let baseURL: URL
    private let session: URLSession
    private var accessToken: String?
    private var tokenManager: TokenManager?

    /// Initialise avec URL custom (pour tests)
    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// Initialise avec la configuration par défaut
    public init(session: URLSession = .shared) {
        self.baseURL = APIConfig.baseURL
        self.session = session
    }

    public func setAccessToken(_ token: String?) {
        self.accessToken = token
    }

    /// Configure le gestionnaire de tokens pour le refresh automatique
    public func setTokenManager(_ manager: TokenManager) {
        self.tokenManager = manager
    }

    /// Requête avec endpoint string (compatibilité)
    public func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        return try await performRequest(url: url, method: method, body: body, requiresAuth: requiresAuth)
    }

    /// Requête avec APIEndpoint (recommandé)
    public func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: String = "GET",
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        return try await performRequest(url: endpoint.url, method: method, body: body, requiresAuth: requiresAuth)
    }

    private func performRequest<T: Decodable>(
        url: URL,
        method: String,
        body: [String: Any]?,
        requiresAuth: Bool
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30 // Timeout de 30 secondes

        // Headers communs
        for (key, value) in APIConfig.commonHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Auth header si requis
        if requiresAuth {
            // Essayer d'obtenir un token valide (avec refresh automatique)
            let token: String?
            if let tokenManager = tokenManager {
                token = try await tokenManager.getValidToken()
            } else {
                token = accessToken
            }

            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        // Body
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Log la requête API
        Task {
            await AppLogger.shared.logAPIRequest(
                method: method,
                url: url.path,
                statusCode: httpResponse.statusCode
            )
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - API Error

public enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case unauthorized
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "Server error (\(statusCode))"
        case .unauthorized:
            return "Please sign in again"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}
