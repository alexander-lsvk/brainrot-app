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
            RootView()
        }
    }
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = nil
        appearance.shadowImage = nil

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        UIScrollView.appearance().delaysContentTouches = false
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private var sessionStartTime: Date?

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

        // Track app launch
        AnalyticsManager.shared.trackAppLaunched()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Track session start
        sessionStartTime = Date()
        AnalyticsManager.shared.trackSessionStart()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Track session end
        if let startTime = sessionStartTime {
            let duration = Date().timeIntervalSince(startTime)
            AnalyticsManager.shared.trackSessionEnd(duration: duration)
        }
    }
}

// MARK: - PurchasesDelegate
extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        ProductsService.shared.checkSubscription(completion: { _ in })
    }
}
