import XCTest
@testable import DXBCore

final class TokenManagerTests: XCTestCase {
    var authService: AuthService!
    var tokenManager: TokenManager!

    override func setUp() async throws {
        authService = AuthService()
        tokenManager = TokenManager(authService: authService)
        try? await authService.clearTokens()
    }

    override func tearDown() async throws {
        try? await authService.clearTokens()
        authService = nil
        tokenManager = nil
    }

    // MARK: - Token Retrieval Tests

    func testGetValidTokenWhenNoToken() async throws {
        // Given - no token saved

        // When
        let token = try await tokenManager.getValidToken()

        // Then
        XCTAssertNil(token, "Should return nil when no token exists")
    }

    func testGetValidTokenWithExistingToken() async throws {
        // Given
        let testToken = "test_token_123"
        try await authService.saveTokens(access: testToken, refresh: nil)

        // When
        let token = try await tokenManager.getValidToken()

        // Then
        XCTAssertEqual(token, testToken, "Should return existing token")
    }

    // MARK: - Token Error Tests

    func testTokenErrorDescriptions() {
        let noRefreshError = TokenError.noRefreshToken
        XCTAssertNotNil(noRefreshError.errorDescription)

        let refreshFailedError = TokenError.refreshFailed
        XCTAssertNotNil(refreshFailedError.errorDescription)

        let invalidTokenError = TokenError.invalidToken
        XCTAssertNotNil(invalidTokenError.errorDescription)
    }

    // MARK: - JWT Decoding Tests (Integration)

    func testJWTExpiryExtraction() async throws {
        // Note: Ce test nécessiterait un vrai JWT pour être complet
        // Pour l'instant, on teste juste que la fonction ne crash pas

        // Given
        let fakeJWT = "header.payload.signature"
        try await authService.saveTokens(access: fakeJWT, refresh: nil)

        // When
        let token = try await tokenManager.getValidToken()

        // Then
        XCTAssertNotNil(token, "Should handle invalid JWT gracefully")
    }
}
