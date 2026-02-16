import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case unauthorized
    case serverError(statusCode: Int, message: String?)
    case decodingError(Error)
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        }
    }
}

public protocol APIClientProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable?,
        headers: [String: String]?
    ) async throws -> T
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public final class APIClient: APIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    public init(
        baseURL: URL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    public func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        
        // Retry logic with exponential backoff
        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                // Handle status codes
                switch httpResponse.statusCode {
                case 200...299:
                    guard !data.isEmpty else {
                        throw APIError.noData
                    }
                    do {
                        return try decoder.decode(T.self, from: data)
                    } catch {
                        throw APIError.decodingError(error)
                    }
                    
                case 401:
                    throw APIError.unauthorized
                    
                case 400...499:
                    let message = try? JSONDecoder().decode([String: String].self, from: data)["message"]
                    throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
                    
                case 500...599:
                    let message = try? JSONDecoder().decode([String: String].self, from: data)["message"]
                    throw APIError.serverError(statusCode: httpResponse.statusCode, message: message)
                    
                default:
                    throw APIError.invalidResponse
                }
            } catch {
                lastError = error
                
                // Don't retry on client errors or unauthorized
                if case APIError.unauthorized = error {
                    throw error
                }
                if case APIError.serverError(let code, _) = error, code < 500 {
                    throw error
                }
                
                // Exponential backoff: 0.5s, 1s, 2s
                if attempt < 2 {
                    let delay = pow(2.0, Double(attempt)) * 0.5
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? APIError.networkError(NSError(domain: "Unknown", code: -1))
    }
}

// Empty response for endpoints that return no data
public struct EmptyResponse: Codable {}
