# Corrections Suite à l'Audit iOS - Backend & Database

Date: 17/02/2026

## 📋 Résumé Exécutif

L'audit de l'application iOS SwiftUI a révélé que l'architecture est solide mais que la configuration pointe vers l'ancienne API Railway. Les endpoints API fonctionnent correctement mais nécessitent des ajustements au niveau de l'authentification.

## 🔴 Corrections Critiques (À faire immédiatement)

### 1. Mise à jour de la configuration API

**Fichier**: `Apps/DXBClient/DXBCore/Sources/DXBCore/Config.swift`

**Problème**: L'app pointe vers l'ancienne API Railway en production.

**Solution**:
```swift
// Ligne 32-34
case .production:
    // Remplacer par l'URL de production Next.js
    return URL(string: "https://votre-domaine.vercel.app/api")!
    // OU temporairement pour dev:
    // return URL(string: "http://localhost:4000/api")!
```

**Impact**: Permet à l'app iOS d'utiliser la nouvelle API Next.js unifiée.

---

### 2. Correction de l'authentification sur les endpoints

**Fichiers**:
- `Apps/DXBClient/src/app/api/esim/balance/route.ts`
- `Apps/DXBClient/src/app/api/esim/orders/route.ts`

**Problème**: Les endpoints retournent 200 au lieu de 401 quand non authentifié.

**Solution**:
```typescript
// Ajouter au début de chaque route GET
export async function GET(request: Request) {
  // Vérifier l'authentification
  const authHeader = request.headers.get('Authorization')

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return NextResponse.json(
      { success: false, error: 'Unauthorized' },
      { status: 401 }
    )
  }

  const token = authHeader.replace('Bearer ', '')

  // Vérifier le token avec Supabase
  const supabase = await createClient()
  const { data: { user }, error } = await supabase.auth.getUser(token)

  if (error || !user) {
    return NextResponse.json(
      { success: false, error: 'Invalid token' },
      { status: 401 }
    )
  }

  // Continuer avec la logique existante...
}
```

**Impact**: Sécurise les endpoints qui nécessitent une authentification.

---

## 🟡 Corrections Importantes (À faire rapidement)

### 3. Implémentation du Refresh Token

**Fichier**: `Apps/DXBClient/DXBCore/Sources/DXBCore/AuthService.swift`

**Problème**: Pas de gestion automatique du refresh token.

**Solution**:
```swift
public actor AuthService: AuthServiceProtocol {
    // ... code existant ...

    private var tokenExpiryDate: Date?

    public func saveTokens(access: String, refresh: String?) async throws {
        try saveKeychainItem(key: accessTokenKey, value: access)
        if let refresh = refresh {
            try saveKeychainItem(key: refreshTokenKey, value: refresh)
        }

        // Décoder le JWT pour obtenir la date d'expiration
        if let expiryDate = decodeTokenExpiry(access) {
            tokenExpiryDate = expiryDate
        }
    }

    public func getAccessToken() async throws -> String? {
        guard let token = try getKeychainItem(key: accessTokenKey) else {
            return nil
        }

        // Vérifier si le token expire dans moins de 5 minutes
        if let expiryDate = tokenExpiryDate,
           Date().addingTimeInterval(300) > expiryDate {
            // Rafraîchir le token
            return try await refreshAccessToken()
        }

        return token
    }

    private func refreshAccessToken() async throws -> String? {
        guard let refreshToken = try getKeychainItem(key: refreshTokenKey) else {
            throw KeychainError.readFailed
        }

        // Appeler l'endpoint de refresh
        // TODO: Implémenter l'appel API
        // POST /api/auth/refresh avec refreshToken

        return nil // Temporaire
    }

    private func decodeTokenExpiry(_ token: String) -> Date? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3,
              let payloadData = Data(base64Encoded: parts[1].base64Padded()),
              let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: exp)
    }
}

extension String {
    func base64Padded() -> String {
        var base64 = self
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        return base64
    }
}
```

**Impact**: Évite les déconnexions intempestives et améliore l'UX.

---

### 4. Système de Logging Structuré

**Nouveau fichier**: `Apps/DXBClient/DXBCore/Sources/DXBCore/Logger.swift`

```swift
import Foundation
import OSLog

public enum LogLevel {
    case debug, info, warning, error
}

public actor AppLogger {
    private let logger: Logger

    public init(subsystem: String = "com.dxbconnect.app", category: String = "general") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    public func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        let logMessage = "[\(filename):\(line)] \(function) - \(message)"

        switch level {
        case .debug:
            logger.debug("\(logMessage)")
        case .info:
            logger.info("\(logMessage)")
        case .warning:
            logger.warning("\(logMessage)")
        case .error:
            logger.error("\(logMessage)")
        }
    }
}

// Usage global
public let appLogger = AppLogger()
```

**Utilisation**:
```swift
// Remplacer tous les print() par:
await appLogger.log("Loading eSIMs", level: .info)
await appLogger.log("Error loading eSIMs: \(error)", level: .error)
```

**Impact**: Meilleur debugging et monitoring en production.

---

### 5. Cache Local pour Mode Offline

**Nouveau fichier**: `Apps/DXBClient/DXBCore/Sources/DXBCore/CacheManager.swift`

```swift
import Foundation

public actor CacheManager {
    private let userDefaults = UserDefaults.standard
    private let cacheExpiryInterval: TimeInterval = 3600 // 1 heure

    public init() {}

    // Cache pour les plans
    public func cachePlans(_ plans: [Plan]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(plans) {
            userDefaults.set(data, forKey: "cached_plans")
            userDefaults.set(Date(), forKey: "cached_plans_date")
        }
    }

    public func getCachedPlans() -> [Plan]? {
        guard let date = userDefaults.object(forKey: "cached_plans_date") as? Date,
              Date().timeIntervalSince(date) < cacheExpiryInterval,
              let data = userDefaults.data(forKey: "cached_plans") else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode([Plan].self, from: data)
    }

    // Cache pour les eSIMs
    public func cacheESIMs(_ esims: [ESIMOrder]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(esims) {
            userDefaults.set(data, forKey: "cached_esims")
            userDefaults.set(Date(), forKey: "cached_esims_date")
        }
    }

    public func getCachedESIMs() -> [ESIMOrder]? {
        guard let date = userDefaults.object(forKey: "cached_esims_date") as? Date,
              Date().timeIntervalSince(date) < cacheExpiryInterval,
              let data = userDefaults.data(forKey: "cached_esims") else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode([ESIMOrder].self, from: data)
    }

    public func clearCache() {
        userDefaults.removeObject(forKey: "cached_plans")
        userDefaults.removeObject(forKey: "cached_plans_date")
        userDefaults.removeObject(forKey: "cached_esims")
        userDefaults.removeObject(forKey: "cached_esims_date")
    }
}
```

**Intégration dans DXBAPIService**:
```swift
public actor DXBAPIService: DXBAPIServiceProtocol {
    private let cacheManager = CacheManager()

    public func fetchPlans(locale: String) async throws -> [Plan] {
        // Essayer le cache d'abord
        if let cachedPlans = await cacheManager.getCachedPlans() {
            await appLogger.log("Using cached plans", level: .debug)
            return cachedPlans
        }

        // Sinon, fetch depuis l'API
        let plans = try await fetchPlansFromAPI(locale: locale)

        // Mettre en cache
        await cacheManager.cachePlans(plans)

        return plans
    }
}
```

**Impact**: Améliore les performances et permet un usage offline partiel.

---

## 🟢 Améliorations Recommandées (À planifier)

### 6. Tests Unitaires

**Nouveau dossier**: `Apps/DXBClient/DXBCore/Tests/DXBCoreTests/`

```swift
// AuthServiceTests.swift
import XCTest
@testable import DXBCore

final class AuthServiceTests: XCTestCase {
    var authService: AuthService!

    override func setUp() async throws {
        authService = AuthService()
    }

    func testSaveAndRetrieveToken() async throws {
        let testToken = "test_token_123"
        try await authService.saveTokens(access: testToken, refresh: nil)

        let retrievedToken = try await authService.getAccessToken()
        XCTAssertEqual(retrievedToken, testToken)
    }

    func testClearTokens() async throws {
        try await authService.saveTokens(access: "test", refresh: nil)
        try await authService.clearTokens()

        let token = try await authService.getAccessToken()
        XCTAssertNil(token)
    }
}
```

---

### 7. Gestion des Erreurs Améliorée

**Fichier**: `Apps/DXBClient/DXBCore/Sources/DXBCore/APIClient.swift`

```swift
public enum APIError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int, message: String?)
    case unauthorized
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Réponse serveur invalide"
        case .httpError(let statusCode, let message):
            if let message = message {
                return "Erreur serveur (\(statusCode)): \(message)"
            }
            return "Erreur serveur (\(statusCode))"
        case .unauthorized:
            return "Session expirée. Veuillez vous reconnecter."
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Erreur de décodage: \(error.localizedDescription)"
        case .serverError(let message):
            return "Erreur serveur: \(message)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .unauthorized:
            return "Reconnectez-vous pour continuer"
        case .networkError:
            return "Vérifiez votre connexion internet"
        case .httpError(let statusCode, _) where statusCode >= 500:
            return "Le service est temporairement indisponible. Réessayez plus tard."
        default:
            return nil
        }
    }
}
```

---

### 8. Analytics et Monitoring

**Nouveau fichier**: `Apps/DXBClient/DXBCore/Sources/DXBCore/Analytics.swift`

```swift
import Foundation

public actor Analytics {
    public enum Event {
        case appLaunched
        case userSignedIn(method: String)
        case userSignedOut
        case planViewed(planId: String)
        case planPurchased(planId: String, price: Double)
        case esimActivated(orderId: String)
        case error(message: String, context: String)
    }

    public init() {}

    public func track(_ event: Event) {
        #if DEBUG
        await appLogger.log("Analytics: \(event)", level: .debug)
        #endif

        // TODO: Intégrer Firebase Analytics, Mixpanel, etc.
        switch event {
        case .appLaunched:
            trackEvent(name: "app_launched")
        case .userSignedIn(let method):
            trackEvent(name: "user_signed_in", properties: ["method": method])
        case .planPurchased(let planId, let price):
            trackEvent(name: "plan_purchased", properties: [
                "plan_id": planId,
                "price": price
            ])
        default:
            break
        }
    }

    private func trackEvent(name: String, properties: [String: Any] = [:]) {
        // Implémenter l'envoi vers votre service d'analytics
    }
}

public let analytics = Analytics()
```

---

## 📝 Checklist de Migration

### Phase 1: Configuration (1-2h)
- [ ] Mettre à jour `Config.swift` avec la nouvelle URL de production
- [ ] Tester la connexion aux endpoints depuis l'app iOS
- [ ] Vérifier que les données se chargent correctement

### Phase 2: Sécurité (2-3h)
- [ ] Ajouter la vérification d'authentification sur `/api/esim/balance`
- [ ] Ajouter la vérification d'authentification sur `/api/esim/orders`
- [ ] Implémenter le refresh token automatique
- [ ] Tester le flux d'authentification complet

### Phase 3: Robustesse (3-4h)
- [ ] Implémenter le système de logging
- [ ] Remplacer tous les `print()` par des logs structurés
- [ ] Ajouter le cache local pour les plans et eSIMs
- [ ] Améliorer la gestion d'erreurs

### Phase 4: Qualité (4-6h)
- [ ] Écrire des tests unitaires pour AuthService
- [ ] Écrire des tests unitaires pour APIClient
- [ ] Écrire des tests unitaires pour DXBAPIService
- [ ] Ajouter des tests d'intégration

### Phase 5: Monitoring (2-3h)
- [ ] Intégrer Firebase Analytics ou Mixpanel
- [ ] Intégrer Sentry pour le crash reporting
- [ ] Configurer les alertes de monitoring
- [ ] Créer un dashboard de métriques

---

## 🧪 Tests à Effectuer

### Tests Manuels
1. **Authentification**
   - [ ] Sign in with Apple
   - [ ] Email + OTP
   - [ ] Déconnexion
   - [ ] Reconnexion automatique

2. **Données**
   - [ ] Chargement des plans
   - [ ] Affichage des détails d'un plan
   - [ ] Chargement des eSIMs
   - [ ] Affichage des détails d'un eSIM

3. **Mode Offline**
   - [ ] Activer le mode avion
   - [ ] Vérifier que les données en cache s'affichent
   - [ ] Désactiver le mode avion
   - [ ] Vérifier la synchronisation

### Tests Automatisés
```bash
# Lancer les tests unitaires
cd Apps/DXBClient/DXBCore
swift test

# Lancer les tests d'intégration
cd Apps/DXBClient
xcodebuild test -scheme DXBClient -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## 📊 Métriques de Succès

### Performance
- Temps de chargement des plans: < 2s
- Temps de chargement des eSIMs: < 2s
- Taux de réussite des requêtes API: > 99%

### Qualité
- Couverture de tests: > 80%
- Nombre de crashs: < 0.1% des sessions
- Taux de rétention J7: > 60%

### Sécurité
- Aucune fuite de token
- Aucune donnée sensible en logs
- Refresh token automatique: 100% des cas

---

## 🔗 Ressources

### Documentation
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui)
- [Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [OSLog](https://developer.apple.com/documentation/oslog)

### Outils
- [Charles Proxy](https://www.charlesproxy.com/) - Debug réseau
- [Xcode Instruments](https://developer.apple.com/xcode/features/) - Profiling
- [Postman](https://www.postman.com/) - Test API

---

## 📞 Support

Pour toute question sur ces corrections:
1. Consulter la documentation dans `Apps/DXBClient/README.md`
2. Exécuter le script d'audit: `./ios-backend-audit.sh`
3. Vérifier les logs dans Console.app (filtre: `com.dxbconnect.app`)
