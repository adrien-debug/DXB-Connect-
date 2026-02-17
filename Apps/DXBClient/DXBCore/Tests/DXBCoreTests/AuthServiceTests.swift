import XCTest
@testable import DXBCore

final class AuthServiceTests: XCTestCase {
    var authService: AuthService!

    override func setUp() async throws {
        authService = AuthService()
        // Nettoyer le keychain avant chaque test
        try? await authService.clearTokens()
    }

    override func tearDown() async throws {
        // Nettoyer après chaque test
        try? await authService.clearTokens()
        authService = nil
    }

    // MARK: - Token Storage Tests

    func testSaveAndRetrieveAccessToken() async throws {
        // Given
        let testToken = "test_access_token_123"

        // When
        try await authService.saveTokens(access: testToken, refresh: nil)
        let retrievedToken = try await authService.getAccessToken()

        // Then
        XCTAssertEqual(retrievedToken, testToken, "Retrieved token should match saved token")
    }

    func testSaveAndRetrieveBothTokens() async throws {
        // Given
        let accessToken = "test_access_token"
        let refreshToken = "test_refresh_token"

        // When
        try await authService.saveTokens(access: accessToken, refresh: refreshToken)
        let retrievedAccess = try await authService.getAccessToken()
        let retrievedRefresh = try await authService.getRefreshToken()

        // Then
        XCTAssertEqual(retrievedAccess, accessToken)
        XCTAssertEqual(retrievedRefresh, refreshToken)
    }

    func testClearTokens() async throws {
        // Given
        try await authService.saveTokens(access: "test_token", refresh: "refresh_token")

        // When
        try await authService.clearTokens()
        let accessToken = try await authService.getAccessToken()
        let refreshToken = try await authService.getRefreshToken()

        // Then
        XCTAssertNil(accessToken, "Access token should be nil after clearing")
        XCTAssertNil(refreshToken, "Refresh token should be nil after clearing")
    }

    // MARK: - Authentication State Tests

    func testIsAuthenticatedWithToken() async throws {
        // Given
        try await authService.saveTokens(access: "valid_token", refresh: nil)

        // When
        let isAuthenticated = await authService.isAuthenticated()

        // Then
        XCTAssertTrue(isAuthenticated, "Should be authenticated with valid token")
    }

    func testIsAuthenticatedWithoutToken() async throws {
        // Given - no token saved

        // When
        let isAuthenticated = await authService.isAuthenticated()

        // Then
        XCTAssertFalse(isAuthenticated, "Should not be authenticated without token")
    }

    func testIsAuthenticatedAfterClear() async throws {
        // Given
        try await authService.saveTokens(access: "token", refresh: nil)
        try await authService.clearTokens()

        // When
        let isAuthenticated = await authService.isAuthenticated()

        // Then
        XCTAssertFalse(isAuthenticated, "Should not be authenticated after clearing tokens")
    }

    // MARK: - Edge Cases

    func testSaveEmptyToken() async throws {
        // Given
        let emptyToken = ""

        // When
        try await authService.saveTokens(access: emptyToken, refresh: nil)
        let isAuthenticated = await authService.isAuthenticated()

        // Then
        XCTAssertFalse(isAuthenticated, "Should not be authenticated with empty token")
    }

    func testOverwriteExistingToken() async throws {
        // Given
        try await authService.saveTokens(access: "old_token", refresh: nil)

        // When
        try await authService.saveTokens(access: "new_token", refresh: nil)
        let retrievedToken = try await authService.getAccessToken()

        // Then
        XCTAssertEqual(retrievedToken, "new_token", "Should overwrite with new token")
    }

    func testSaveAccessTokenWithoutRefresh() async throws {
        // Given
        let accessToken = "access_only"

        // When
        try await authService.saveTokens(access: accessToken, refresh: nil)
        let retrievedAccess = try await authService.getAccessToken()
        let retrievedRefresh = try await authService.getRefreshToken()

        // Then
        XCTAssertEqual(retrievedAccess, accessToken)
        XCTAssertNil(retrievedRefresh, "Refresh token should be nil when not provided")
    }
}
