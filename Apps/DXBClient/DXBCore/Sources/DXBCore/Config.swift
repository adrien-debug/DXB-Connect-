import Foundation

// MARK: - API Configuration

/// Configuration centralisée pour l'API
/// ⚠️ RÈGLE ABSOLUE: Toujours pointer vers Railway Backend
/// Railway est le SEUL point d'entrée (connecté à Supabase + eSIM API)
public enum APIConfig {

    /// Environnement actuel
    public enum Environment {
        case development
        case staging
        case production
    }

    /// Environnement par défaut (changer en production pour release)
    #if DEBUG
    public static var current: Environment = .development
    #else
    public static var current: Environment = .production
    #endif

    /// URL de base de l'API selon l'environnement
    public static var baseURL: URL {
        switch current {
        case .development:
            // Localhost pour dev (simulator)
            // Pour device physique, utiliser l'IP locale ou ngrok
            // Port 4000 pour Next.js dev server
            return URL(string: "http://localhost:4000/api")!

        case .staging:
            // Staging Railway - même architecture que production
            return URL(string: "https://web-production-14c51.up.railway.app/api")!

        case .production:
            // ✅ PRODUCTION RAILWAY - NE JAMAIS CHANGER
            // Railway Backend est le SEUL point d'entrée
            return URL(string: "https://web-production-14c51.up.railway.app/api")!
        }
    }

    /// Headers communs pour toutes les requêtes
    public static var commonHeaders: [String: String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Client-Platform": "iOS",
            "X-Client-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        ]
    }
}

// MARK: - API Endpoints

/// Endpoints de l'API - Alignés avec les routes Next.js
public enum APIEndpoint {

    // Auth
    case authApple
    case authLogin
    case authRegister
    case authEmailSendOTP
    case authEmailVerify
    case authRefresh
    case authResetPassword

    // eSIM
    case esimPackages
    case esimOrders
    case esimStock
    case esimPurchase
    case esimPurchaseApplePay
    case esimBalance
    case esimUsage
    case esimTopup
    case esimSuspend
    case esimCancel

    // Offers
    case offers
    case offerClick(id: String)

    // Subscriptions
    case subscriptionsMe
    case subscriptionsCreate
    case subscriptionsCreateApplePay
    case subscriptionsCancel

    // Rewards
    case rewardsSummary
    case rewardsCheckin
    case raffleEnter(id: String)

    // Checkout
    case checkout
    case checkoutConfirm
    case checkoutCrypto
    case checkoutCryptoStatus(id: String)

    // Promo
    case promoValidate

    public var path: String {
        switch self {
        // Auth
        case .authApple: return "auth/apple"
        case .authLogin: return "auth/login"
        case .authRegister: return "auth/register"
        case .authEmailSendOTP: return "auth/email/send-otp"
        case .authEmailVerify: return "auth/email/verify"
        case .authRefresh: return "auth/refresh"
        case .authResetPassword: return "auth/reset-password"

        // eSIM
        case .esimPackages: return "esim/packages"
        case .esimOrders: return "esim/orders"
        case .esimStock: return "esim/stock"
        case .esimPurchase: return "esim/purchase"
        case .esimPurchaseApplePay: return "esim/purchase/apple-pay"
        case .esimBalance: return "esim/balance"
        case .esimUsage: return "esim/usage"
        case .esimTopup: return "esim/topup"
        case .esimSuspend: return "esim/suspend"
        case .esimCancel: return "esim/cancel"

        // Offers
        case .offers: return "offers"
        case .offerClick(let id): return "offers/\(id)/click"

        // Subscriptions
        case .subscriptionsMe: return "subscriptions/me"
        case .subscriptionsCreate: return "subscriptions/create"
        case .subscriptionsCreateApplePay: return "subscriptions/create-apple-pay"
        case .subscriptionsCancel: return "subscriptions/cancel"

        // Rewards
        case .rewardsSummary: return "rewards/summary"
        case .rewardsCheckin: return "rewards/checkin"
        case .raffleEnter(let id): return "rewards/raffles/\(id)/enter"

        // Checkout
        case .checkout: return "checkout"
        case .checkoutConfirm: return "checkout/confirm"
        case .checkoutCrypto: return "checkout/crypto"
        case .checkoutCryptoStatus(let id): return "checkout/crypto/\(id)"

        // Promo
        case .promoValidate: return "promo/validate"
        }
    }

    public var url: URL {
        APIConfig.baseURL.appendingPathComponent(path)
    }
}
