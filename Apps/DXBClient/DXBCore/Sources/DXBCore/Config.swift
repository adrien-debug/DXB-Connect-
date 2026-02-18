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
    public static var current: Environment = .production

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
    case authEmailSendOTP
    case authEmailVerify

    // eSIM
    case esimPackages
    case esimOrders
    case esimPurchase
    case esimBalance

    // Checkout
    case checkout
    case checkoutConfirm

    public var path: String {
        switch self {
        // Auth
        case .authApple: return "auth/apple"
        case .authEmailSendOTP: return "auth/email/send-otp"
        case .authEmailVerify: return "auth/email/verify"

        // eSIM
        case .esimPackages: return "esim/packages"
        case .esimOrders: return "esim/orders"
        case .esimPurchase: return "esim/purchase"
        case .esimBalance: return "esim/balance"

        // Checkout
        case .checkout: return "checkout"
        case .checkoutConfirm: return "checkout/confirm"
        }
    }

    public var url: URL {
        APIConfig.baseURL.appendingPathComponent(path)
    }
}
