//
//  BrainrotApp.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 16.11.25.
//

import SwiftUI
import FirebaseCore
import FirebaseRemoteConfig
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
        
        // Remote config
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 5
        remoteConfig.configSettings = settings
        
        fetchRemoteConfig()
        
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
    
    func fetchRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                remoteConfig.activate(completion: { error, _  in
                    if error == nil {
                        print("Config activated!")
                    }
                })
            } else {
                print("Config not fetched")
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - PurchasesDelegate
extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        ProductsService.shared.checkSubscription(completion: { _ in })
    }
}
