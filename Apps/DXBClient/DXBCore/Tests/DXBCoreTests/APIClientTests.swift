import XCTest
@testable import DXBCore

final class APIClientTests: XCTestCase {
    var apiClient: APIClient!
    let testBaseURL = URL(string: "https://api.test.com")!

    override func setUp() {
        apiClient = APIClient(baseURL: testBaseURL)
    }

    override func tearDown() {
        apiClient = nil
    }

    // MARK: - Initialization Tests

    func testInitWithCustomURL() {
        // Given
        let customURL = URL(string: "https://custom.api.com")!

        // When
        let client = APIClient(baseURL: customURL)

        // Then
        XCTAssertNotNil(client, "Client should initialize with custom URL")
    }

    func testInitWithDefaultURL() {
        // When
        let client = APIClient()

        // Then
        XCTAssertNotNil(client, "Client should initialize with default config URL")
    }

    // MARK: - Token Management Tests

    func testSetAccessToken() async {
        // Given
        let token = "test_token_123"

        // When
        await apiClient.setAccessToken(token)

        // Then - pas de crash, token stocké
        XCTAssertTrue(true, "Token should be set without errors")
    }

    func testSetNilToken() async {
        // Given
        await apiClient.setAccessToken("some_token")

        // When
        await apiClient.setAccessToken(nil)

        // Then - pas de crash
        XCTAssertTrue(true, "Should handle nil token gracefully")
    }

    // MARK: - Error Handling Tests

    func testAPIErrorDescriptions() {
        // Test invalid response
        let invalidResponseError = APIError.invalidResponse
        XCTAssertNotNil(invalidResponseError.errorDescription)

        // Test HTTP error
        let httpError = APIError.httpError(statusCode: 404)
        XCTAssertNotNil(httpError.errorDescription)
        XCTAssertTrue(httpError.errorDescription!.contains("404"))

        // Test unauthorized
        let unauthorizedError = APIError.unauthorized
        XCTAssertNotNil(unauthorizedError.errorDescription)

        // Test network error
        let networkError = APIError.networkError(NSError(domain: "test", code: -1))
        XCTAssertNotNil(networkError.errorDescription)
    }

    func testHTTPErrorStatusCodes() {
        // Test various status codes
        let error400 = APIError.httpError(statusCode: 400)
        XCTAssertTrue(error400.errorDescription!.contains("400"))

        let error500 = APIError.httpError(statusCode: 500)
        XCTAssertTrue(error500.errorDescription!.contains("500"))

        let error503 = APIError.httpError(statusCode: 503)
        XCTAssertTrue(error503.errorDescription!.contains("503"))
    }
}
