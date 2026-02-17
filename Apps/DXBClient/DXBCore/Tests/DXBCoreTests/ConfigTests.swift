import XCTest
@testable import DXBCore

final class ConfigTests: XCTestCase {

    // MARK: - Environment Tests

    func testDevelopmentEnvironment() {
        // Given
        APIConfig.current = .development

        // When
        let url = APIConfig.baseURL

        // Then
        XCTAssertTrue(url.absoluteString.contains("localhost"), "Development should use localhost")
        XCTAssertTrue(url.absoluteString.contains("4000"), "Development should use port 4000")
    }

    func testStagingEnvironment() {
        // Given
        APIConfig.current = .staging

        // When
        let url = APIConfig.baseURL

        // Then
        XCTAssertTrue(url.absoluteString.contains("staging") || url.absoluteString.contains("vercel"),
                     "Staging should use staging or vercel URL")
    }

    func testProductionEnvironment() {
        // Given
        APIConfig.current = .production

        // When
        let url = APIConfig.baseURL

        // Then
        XCTAssertFalse(url.absoluteString.contains("localhost"), "Production should not use localhost")
        XCTAssertTrue(url.absoluteString.hasPrefix("https://"), "Production should use HTTPS")
    }

    // MARK: - Common Headers Tests

    func testCommonHeaders() {
        // When
        let headers = APIConfig.commonHeaders

        // Then
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(headers["Accept"], "application/json")
        XCTAssertEqual(headers["X-Client-Platform"], "iOS")
        XCTAssertNotNil(headers["X-Client-Version"])
    }

    func testClientVersionHeader() {
        // When
        let headers = APIConfig.commonHeaders
        let version = headers["X-Client-Version"]

        // Then
        XCTAssertNotNil(version, "Client version should be present")
        XCTAssertFalse(version!.isEmpty, "Client version should not be empty")
    }

    // MARK: - Endpoint Tests

    func testAuthEndpoints() {
        XCTAssertEqual(APIEndpoint.authApple.path, "auth/apple")
        XCTAssertEqual(APIEndpoint.authEmailSendOTP.path, "auth/email/send-otp")
        XCTAssertEqual(APIEndpoint.authEmailVerify.path, "auth/email/verify")
    }

    func testESIMEndpoints() {
        XCTAssertEqual(APIEndpoint.esimPackages.path, "esim/packages")
        XCTAssertEqual(APIEndpoint.esimOrders.path, "esim/orders")
        XCTAssertEqual(APIEndpoint.esimPurchase.path, "esim/purchase")
        XCTAssertEqual(APIEndpoint.esimBalance.path, "esim/balance")
    }

    func testCheckoutEndpoints() {
        XCTAssertEqual(APIEndpoint.checkout.path, "checkout")
        XCTAssertEqual(APIEndpoint.checkoutConfirm.path, "checkout/confirm")
    }

    func testEndpointURLGeneration() {
        // Given
        APIConfig.current = .development

        // When
        let packagesURL = APIEndpoint.esimPackages.url

        // Then
        XCTAssertTrue(packagesURL.absoluteString.contains("esim/packages"))
        XCTAssertTrue(packagesURL.absoluteString.contains("localhost:4000"))
    }
}
