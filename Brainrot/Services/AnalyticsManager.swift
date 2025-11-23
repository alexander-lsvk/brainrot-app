//
//  AnalyticsManager.swift
//  Brainrot
//
//  Created by Claude on 23.11.25.
//

import Foundation
import FirebaseAnalytics

/// Centralized analytics manager for tracking user behavior and events
final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    // MARK: - User Properties

    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    func identifyUser(_ userId: String) {
        Analytics.setUserID(userId)
    }

    // MARK: - Onboarding Events

    enum OnboardingStep: String {
        case welcome = "welcome"
        case screenTimePermission = "screen_time_permission"
        case benefits = "benefits"
        case subscription = "subscription"
    }

    func trackOnboardingStepViewed(_ step: OnboardingStep) {
        Analytics.logEvent("onboarding_step_viewed", parameters: [
            "step": step.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackOnboardingStepCompleted(_ step: OnboardingStep, timeSpent: TimeInterval) {
        Analytics.logEvent("onboarding_step_completed", parameters: [
            "step": step.rawValue,
            "time_spent_seconds": timeSpent,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackOnboardingDropOff(_ step: OnboardingStep, reason: String? = nil) {
        var params: [String: Any] = [
            "step": step.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        if let reason = reason {
            params["reason"] = reason
        }
        Analytics.logEvent("onboarding_drop_off", parameters: params)
    }

    func trackOnboardingCompleted(totalTime: TimeInterval) {
        Analytics.logEvent("onboarding_completed", parameters: [
            "total_time_seconds": totalTime,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    // MARK: - Screen Time Permission Events

    func trackScreenTimePermissionRequested() {
        Analytics.logEvent("screen_time_permission_requested", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackScreenTimePermissionGranted() {
        Analytics.logEvent("screen_time_permission_granted", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        setUserProperty("true", forName: "has_screen_time_permission")
    }

    func trackScreenTimePermissionDenied() {
        Analytics.logEvent("screen_time_permission_denied", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        setUserProperty("false", forName: "has_screen_time_permission")
    }

    // MARK: - Subscription Events

    func trackSubscriptionViewPresented(source: String) {
        Analytics.logEvent("subscription_view_presented", parameters: [
            "source": source,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackSubscriptionPlanSelected(_ planId: String, price: String) {
        Analytics.logEvent("subscription_plan_selected", parameters: [
            "plan_id": planId,
            "price": price,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackSubscriptionPurchaseStarted(_ planId: String) {
        Analytics.logEvent("subscription_purchase_started", parameters: [
            "plan_id": planId,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackSubscriptionPurchaseCompleted(_ planId: String, price: Double, currency: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemID: planId,
            AnalyticsParameterValue: price,
            AnalyticsParameterCurrency: currency,
            "timestamp": Date().timeIntervalSince1970
        ])
        setUserProperty("true", forName: "is_subscriber")
    }

    func trackSubscriptionPurchaseFailed(_ planId: String, error: String) {
        Analytics.logEvent("subscription_purchase_failed", parameters: [
            "plan_id": planId,
            "error": error,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackSubscriptionCancelled() {
        Analytics.logEvent("subscription_cancelled", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
        setUserProperty("false", forName: "is_subscriber")
    }

    func trackSubscriptionRestored() {
        Analytics.logEvent("subscription_restored", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    // MARK: - Dashboard Events

    func trackDashboardViewed() {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "dashboard",
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackVPNToggled(isEnabled: Bool, source: String = "dashboard") {
        Analytics.logEvent("vpn_toggled", parameters: [
            "enabled": isEnabled,
            "source": source,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackVPNConnectionSuccess(connectionTime: TimeInterval) {
        Analytics.logEvent("vpn_connection_success", parameters: [
            "connection_time_seconds": connectionTime,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackVPNConnectionFailed(error: String) {
        Analytics.logEvent("vpn_connection_failed", parameters: [
            "error": error,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackParticleEffectTriggered() {
        Analytics.logEvent("particle_effect_triggered", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    // MARK: - Screen Time Analytics

    func trackScreenTimeDataViewed(totalDuration: TimeInterval, appCount: Int) {
        Analytics.logEvent("screen_time_data_viewed", parameters: [
            "total_duration_seconds": totalDuration,
            "app_count": appCount,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackScreenTimeComparison(
        yesterdayChange: Double,
        weekChange: Double,
        monthChange: Double
    ) {
        Analytics.logEvent("screen_time_comparison_viewed", parameters: [
            "yesterday_change_percent": yesterdayChange,
            "week_change_percent": weekChange,
            "month_change_percent": monthChange,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    // MARK: - User Engagement Events

    func trackAppLaunched() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackSessionStart() {
        Analytics.logEvent("session_start", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackSessionEnd(duration: TimeInterval) {
        Analytics.logEvent("session_end", parameters: [
            "duration_seconds": duration,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    func trackFeatureDiscovered(_ featureName: String) {
        Analytics.logEvent("feature_discovered", parameters: [
            "feature": featureName,
            "timestamp": Date().timeIntervalSince1970
        ])
    }

    // MARK: - Button Click Events

    func trackButtonClicked(
        buttonName: String,
        screen: String,
        context: [String: Any]? = nil
    ) {
        var params: [String: Any] = [
            "button_name": buttonName,
            "screen": screen,
            "timestamp": Date().timeIntervalSince1970
        ]

        if let context = context {
            for (key, value) in context {
                params[key] = value
            }
        }

        Analytics.logEvent("button_clicked", parameters: params)
    }

    // MARK: - Error Tracking

    func trackError(
        error: Error,
        screen: String,
        context: [String: Any]? = nil
    ) {
        var params: [String: Any] = [
            "error_description": error.localizedDescription,
            "screen": screen,
            "timestamp": Date().timeIntervalSince1970
        ]

        if let context = context {
            for (key, value) in context {
                params[key] = value
            }
        }

        Analytics.logEvent("error_occurred", parameters: params)
    }

    // MARK: - User Journey Events

    func trackUserJourneyMilestone(_ milestone: String, metadata: [String: Any]? = nil) {
        var params: [String: Any] = [
            "milestone": milestone,
            "timestamp": Date().timeIntervalSince1970
        ]

        if let metadata = metadata {
            for (key, value) in metadata {
                params[key] = value
            }
        }

        Analytics.logEvent("user_journey_milestone", parameters: params)
    }

    // MARK: - Custom Events

    func trackCustomEvent(
        _ eventName: String,
        parameters: [String: Any]? = nil
    ) {
        var params = parameters ?? [:]
        params["timestamp"] = Date().timeIntervalSince1970

        Analytics.logEvent(eventName, parameters: params)
    }
}
