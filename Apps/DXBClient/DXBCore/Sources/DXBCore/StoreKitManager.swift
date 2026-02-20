import Foundation
import StoreKit

/// Manages StoreKit 2 subscriptions for SimPass Privilege/Elite/Black plans.
@MainActor
public final class StoreKitManager: ObservableObject {
    public static let shared = StoreKitManager()

    @Published public var products: [Product] = []
    @Published public var purchasedProductIDs: Set<String> = []
    @Published public var isLoading = false
    @Published public var error: String?

    public static let privilegeMonthlyID = "com.simpass.privilege.monthly"
    public static let privilegeYearlyID = "com.simpass.privilege.yearly"
    public static let eliteMonthlyID = "com.simpass.elite.monthly"
    public static let eliteYearlyID = "com.simpass.elite.yearly"
    public static let blackMonthlyID = "com.simpass.black.monthly"
    public static let blackYearlyID = "com.simpass.black.yearly"

    private static let allProductIDs: Set<String> = [
        privilegeMonthlyID, privilegeYearlyID,
        eliteMonthlyID, eliteYearlyID,
        blackMonthlyID, blackYearlyID,
    ]

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load Products

    public func loadProducts() async {
        isLoading = true
        error = nil

        do {
            products = try await Product.products(for: Self.allProductIDs)
                .sorted { $0.price < $1.price }
            await updatePurchasedProducts()
        } catch {
            self.error = "Failed to load products"
            await AppLogger.shared.logError(error, message: "StoreKit: loadProducts")
        }

        isLoading = false
    }

    // MARK: - Purchase

    public func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        isLoading = true
        error = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                isLoading = false
                return transaction

            case .userCancelled:
                isLoading = false
                return nil

            case .pending:
                isLoading = false
                return nil

            @unknown default:
                isLoading = false
                return nil
            }
        } catch {
            self.error = "Purchase failed"
            isLoading = false
            throw error
        }
    }

    // MARK: - Restore

    public func restorePurchases() async {
        isLoading = true
        try? await AppStore.sync()
        await updatePurchasedProducts()
        isLoading = false
    }

    // MARK: - Active Subscription

    public var activeSubscription: Product? {
        products.first { purchasedProductIDs.contains($0.id) }
    }

    public var activePlanName: String? {
        guard let id = activeSubscription?.id else { return nil }
        if id.contains("privilege") { return "Privilege" }
        if id.contains("elite") { return "Elite" }
        if id.contains("black") { return "Black" }
        return nil
    }

    public var activeDiscountPercent: Int {
        guard let name = activePlanName else { return 0 }
        switch name {
        case "Privilege": return 15
        case "Elite": return 30
        case "Black": return 50
        default: return 0
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchasedProducts() async {
        var purchased: Set<String> = []

        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            }
        }

        purchasedProductIDs = purchased
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                }
            }
        }
    }
}

enum StoreKitError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        }
    }
}
