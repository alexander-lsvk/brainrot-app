//
//  BrainrotApp.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import SwiftUI
import FirebaseCore
import RevenueCat

@main
struct BrainrotApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SubscriptionView()
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        Purchases.configure(with: Configuration.Builder(withAPIKey: "appl_zYjWzgwxzJWRPohHbgZjVBrsZLs").build())
        Purchases.shared.delegate = self
        Purchases.logLevel = .error
        
        ProductsService.shared.setProducts()
        ProductsService.shared.checkSubscription(completion: { _ in })
        
        return true
    }
}

// MARK: - PurchasesDelegate
extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        ProductsService.shared.checkSubscription(completion: { _ in })
    }
}
