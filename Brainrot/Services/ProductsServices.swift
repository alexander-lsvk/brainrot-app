//
//  ProductsServices.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 22.11.25.
//

import Combine
import RevenueCat

@MainActor
final class ProductsService: ObservableObject {
    static var shared = ProductsService()
    
    var products = [StoreProduct]()
    
    @Published var subscribed = true
    
    func setProducts() {
        Purchases.shared.getProducts(["bh_1y", "bh_1w", "bh_1m", "bh_1y_offer"]) { [weak self] products in
            self?.products.removeAll()
            self?.products = products
            print("[Purchases] Products: \(products)")
        }
    }
    
    func checkSubscription(completion: @escaping ((Bool) -> Void)) {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            if customerInfo?.allPurchasedProductIdentifiers.contains("bh_lifetime") ?? true {
                self?.subscribed = true
                completion(true)
            } else if customerInfo?.activeSubscriptions.isEmpty ?? true {
                self?.subscribed = false
                completion(false)
            } else {
                self?.subscribed = true
                completion(true)
            }
        }
    }
    
    func restorePurchases(completion: @escaping ((Bool) -> Void)) {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            if customerInfo?.allPurchasedProductIdentifiers.contains("bh_lifetime") ?? true {
                self?.subscribed = true
                completion(true)
            } else if customerInfo?.activeSubscriptions.isEmpty ?? true {
                self?.subscribed = false
                completion(false)
            } else {
                self?.subscribed = true
                completion(true)
            }
        }
    }
}
