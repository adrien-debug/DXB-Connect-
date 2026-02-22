import Foundation
import PassKit

// MARK: - Apple Pay Configuration

public enum ApplePayConfig {
    /// Merchant ID configuré dans Apple Developer Portal
    public static let merchantIdentifier = "merchant.com.dxbconnect.app"
    
    /// Réseaux de cartes supportés
    public static let supportedNetworks: [PKPaymentNetwork] = [
        .visa, .masterCard, .amex, .discover
    ]
    
    /// Capacités requises
    public static let merchantCapabilities: PKMerchantCapability = [
        .threeDSecure, .debit, .credit
    ]
    
    /// Code pays
    public static let countryCode = "AE"
    
    /// Devise
    public static let currencyCode = "USD"
}

// MARK: - Apple Pay Service

public final class ApplePayService: NSObject, @unchecked Sendable {
    
    public static let shared = ApplePayService()
    
    private var paymentCompletion: ((Result<PKPayment, Error>) -> Void)?
    private var authorizationController: PKPaymentAuthorizationController?
    
    private override init() {
        super.init()
    }
    
    /// Vérifie si Apple Pay est disponible sur cet appareil
    public static var isAvailable: Bool {
        PKPaymentAuthorizationController.canMakePayments()
    }
    
    /// Vérifie si l'utilisateur a des cartes configurées
    public static var canMakePayments: Bool {
        PKPaymentAuthorizationController.canMakePayments(
            usingNetworks: ApplePayConfig.supportedNetworks,
            capabilities: ApplePayConfig.merchantCapabilities
        )
    }
    
    /// Présente la sheet Apple Pay
    /// - Parameters:
    ///   - amount: Montant en USD
    ///   - label: Description de l'achat (ex: "eSIM Dubai 5GB")
    /// - Returns: PKPayment contenant le token de paiement
    @MainActor
    public func presentPaymentSheet(
        amount: Double,
        label: String
    ) async throws -> PKPayment {
        
        guard ApplePayService.isAvailable else {
            throw ApplePayError.notAvailable
        }
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePayConfig.merchantIdentifier
        request.supportedNetworks = ApplePayConfig.supportedNetworks
        request.merchantCapabilities = ApplePayConfig.merchantCapabilities
        request.countryCode = ApplePayConfig.countryCode
        request.currencyCode = ApplePayConfig.currencyCode
        
        // Items de paiement
        let item = PKPaymentSummaryItem(
            label: label,
            amount: NSDecimalNumber(value: amount)
        )
        
        let total = PKPaymentSummaryItem(
            label: "SimPass",
            amount: NSDecimalNumber(value: amount),
            type: .final
        )
        
        request.paymentSummaryItems = [item, total]
        
        // Infos requises
        request.requiredBillingContactFields = [.emailAddress]
        
        return try await withCheckedThrowingContinuation { continuation in
            self.paymentCompletion = { result in
                continuation.resume(with: result)
            }
            
            let controller = PKPaymentAuthorizationController(paymentRequest: request)
            
            self.authorizationController = controller
            controller.delegate = self
            controller.present { presented in
                if !presented {
                    continuation.resume(throwing: ApplePayError.failedToPresent)
                }
            }
        }
    }
}

// MARK: - PKPaymentAuthorizationControllerDelegate

extension ApplePayService: PKPaymentAuthorizationControllerDelegate {
    
    public func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        // Paiement autorisé par l'utilisateur
        // Le token est dans payment.token.paymentData
        paymentCompletion?(.success(payment))
        paymentCompletion = nil
        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
    }
    
    public func paymentAuthorizationControllerDidFinish(
        _ controller: PKPaymentAuthorizationController
    ) {
        controller.dismiss {
            // Si paymentCompletion existe encore, c'est que l'utilisateur a annulé
            if self.paymentCompletion != nil {
                self.paymentCompletion?(.failure(ApplePayError.cancelled))
                self.paymentCompletion = nil
            }
            self.authorizationController = nil
        }
    }
}

// MARK: - Apple Pay Error

public enum ApplePayError: LocalizedError {
    case notAvailable
    case notConfigured
    case failedToCreate
    case failedToPresent
    case cancelled
    case paymentFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Pay is not available on this device"
        case .notConfigured:
            return "No payment cards configured"
        case .failedToCreate:
            return "Failed to create payment request"
        case .failedToPresent:
            return "Failed to present Apple Pay"
        case .cancelled:
            return "Payment was cancelled"
        case .paymentFailed(let message):
            return "Payment failed: \(message)"
        }
    }
}

// MARK: - Payment Token Extension

extension PKPayment {
    /// Retourne les données du token encodées en base64 pour envoi au backend
    public var tokenBase64: String {
        token.paymentData.base64EncodedString()
    }
    
    /// Retourne le réseau de carte utilisé
    public var paymentNetwork: String {
        token.paymentMethod.network?.rawValue ?? "unknown"
    }
}
