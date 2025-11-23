//
//  SubscriptionView.swift
//  Brainrot
//
//  Created by Alexander Lisovyk on 22.11.25.
//

import SwiftUI
import RevenueCat

enum Products: String {
    case annual = "bh_1y"
    case monthly = "bh_1m"
    case weekly = "bh_1w"
}

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss

    @State var selectedPlan: Products = .annual
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false

    var onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if UIScreen.main.bounds.height > 700 {
                        ZStack(alignment: .bottom) {
                            Image("subscription-bg")
                                .resizable()
                                .scaledToFill()
                                .frame(height: UIScreen.main.bounds.height / 1.5)
                                .clipped()
                                .ignoresSafeArea()
                                .opacity(0.8)

                            LinearGradient(
                                colors: [.clear, .white, .white],
                                startPoint: .top, endPoint: .bottom
                            )
                            .frame(height: UIScreen.main.bounds.height / 3)
                        }
                        .frame(height: UIScreen.main.bounds.height / 1.5)
                    }

                    Spacer()
                }
                
                VStack(spacing: 0) {
                    Text("Get Your 15 Years Back With Brainheal")
                        .foregroundStyle(.black)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .padding(.bottom, 4)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                        .minimumScaleFactor(0.5)
                    
                    VStack(spacing: 8) {
                        Text("✅ **Unlimited** slowdown sessions")
                            .foregroundStyle(.textPrimary)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(32)
                            .overlay {
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        .textSecondary.opacity(0.2),
                                        lineWidth: 1
                                    )
                            }
                        
                        Text("🌎 **Free** personal VPN")
                            .foregroundStyle(.textPrimary)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(32)
                            .overlay {
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        .textSecondary.opacity(0.2),
                                        lineWidth: 1
                                    )
                            }
                    }
                    
                    Spacer()
                    
                    Text("Join others **healing** **brainrot**!")
                        .foregroundStyle(.textPrimary)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(32)
                        .overlay {
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(
                                    .textSecondary.opacity(0.2),
                                    lineWidth: 1
                                )
                        }
                        .padding(.bottom, 24)
                    
                    // Annual button
                    Button {
                        selectedPlan = .annual
                        AnalyticsManager.shared.trackSubscriptionPlanSelected(
                            Products.annual.rawValue,
                            price: annualLocalizedPrice()
                        )
                    } label: {
                        ZStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Annual Plan")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    
                                    Text("\(annualLocalizedPrice()) / year")
                                        .foregroundStyle(.textSecondary)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    Text("\(annualDailyLocalizedPrice())")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                    
                                    Text(" / day")
                                        .foregroundStyle(.textSecondary)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    selectedPlan == .annual ? .green : .textSecondary.opacity(0.1),
                                    lineWidth: selectedPlan == .annual ? 3 : 2
                                )
                            
                            Text("SAVE 72%")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.green)
                                .cornerRadius(4)
                                .offset(y: -37)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Monthly button
                    Button {
                        selectedPlan = .monthly
                        AnalyticsManager.shared.trackSubscriptionPlanSelected(
                            Products.monthly.rawValue,
                            price: monthlyLocalizedPrice()
                        )
                    } label: {
                        ZStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Monthly Plan")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    
                                    Text("\(monthlyLocalizedPrice()) / month")
                                        .foregroundStyle(.textSecondary)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    Text("\(monthlyDailyLocalizedPrice())")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                    
                                    Text(" / day")
                                        .foregroundStyle(.textSecondary)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    selectedPlan == .monthly ? .green : .textSecondary.opacity(0.1),
                                    lineWidth: selectedPlan == .monthly ? 3 : 2
                                )
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Weekly button
                    Button {
                        selectedPlan = .weekly
                        AnalyticsManager.shared.trackSubscriptionPlanSelected(
                            Products.weekly.rawValue,
                            price: weeklyLocalizedPrice()
                        )
                    } label: {
                        ZStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Weekly Plan")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                    
                                    Text("\(weeklyLocalizedPrice()) / week")
                                        .foregroundStyle(.textSecondary)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 0) {
                                    Text("\(weeklyDailyLocalizedPrice())")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                    
                                    Text(" / day")
                                        .foregroundStyle(.textSecondary)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    selectedPlan == .weekly ? .green : .textSecondary.opacity(0.1),
                                    lineWidth: selectedPlan == .weekly ? 3 : 2
                                )
                        }
                    }
                    .padding(.bottom, 32)
                    
                    Button {
                        Task {
                            await purchase()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        } else {
                            Text("Continue")
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                        }
                    }
                    .buttonStyle(
                        PressableButtonStyle(
                            foregroundColor: .green,
                            backgroundColor: .green.opacity(0.7),
                            cornerRadius: 16
                        )
                    )
                    .frame(height: 60)
                    .disabled(isLoading)
                    
                    HStack(spacing: 32) {
                        Link(destination: URL(string: "https://telegra.ph/Privacy-Polic-11-23")!, label: {
                            Text("Privacy")
                                .foregroundStyle(.textSecondary)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        })
                        
                        Button {
                            Task {
                                await restorePurchases()
                            }
                        } label: {
                            Text("Restore Purchase")
                                .foregroundStyle(.textSecondary)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        
                        Link(destination: URL(string: "https://telegra.ph/Terms--Conditions-11-23-3")!, label: {
                            Text("Terms")
                                .foregroundStyle(.textSecondary)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        })
                    }
                    .padding(.top, 16)
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        onDismiss()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .onAppear {
                AnalyticsManager.shared.trackSubscriptionViewPresented(source: "onboarding")
            }
        }
    }

    func purchase() async {
        isLoading = true
        errorMessage = nil

        guard let product = ProductsService.shared.products.first(where: { $0.productIdentifier == selectedPlan.rawValue }) else {
            isLoading = false
            errorMessage = "Product not found"
            showError = true
            AnalyticsManager.shared.trackError(
                error: NSError(domain: "SubscriptionView", code: 404, userInfo: [NSLocalizedDescriptionKey: "Product not found"]),
                screen: "subscription"
            )
            return
        }

        AnalyticsManager.shared.trackSubscriptionPurchaseStarted(selectedPlan.rawValue)

        do {
            let result = try await Purchases.shared.purchase(product: product)
            isLoading = false

            if result.userCancelled {
                ProductsService.shared.subscribed = false
                AnalyticsManager.shared.trackCustomEvent("subscription_purchase_cancelled", parameters: [
                    "plan_id": selectedPlan.rawValue
                ])
                return
            }

            ProductsService.shared.subscribed = true

            // Track successful purchase
            AnalyticsManager.shared.trackSubscriptionPurchaseCompleted(
                selectedPlan.rawValue,
                price: Double(truncating: product.price as NSNumber),
                currency: product.currencyCode ?? "USD"
            )

            onDismiss()
            dismiss()
        } catch {
            isLoading = false
            ProductsService.shared.subscribed = false
            errorMessage = error.localizedDescription
            showError = true
            AnalyticsManager.shared.trackSubscriptionPurchaseFailed(
                selectedPlan.rawValue,
                error: error.localizedDescription
            )
        }
    }

    func restorePurchases() async {
        isLoading = true

        ProductsService.shared.restorePurchases { success in
            isLoading = false
            if success {
                ProductsService.shared.subscribed = true
                onDismiss()
                dismiss()
            } else {
                errorMessage = "No active subscriptions found"
                showError = true
                ProductsService.shared.subscribed = false
            }
        }
    }

    // Annual prices
    private func annualLocalizedPrice() -> String {
        let yearProduct = ProductsService.shared.products.first(where: { $0.productIdentifier == Products.annual.rawValue })
        return yearProduct?.localizedPriceString ?? "N/A"
    }
    
    private func annualDailyLocalizedPrice() -> String {
        let yearProduct = ProductsService.shared.products.first(where: { $0.productIdentifier == Products.annual.rawValue })
        return yearProduct?.localizedPricePerDay ?? "N/A"
    }
    
    // Monthly prices
    private func monthlyLocalizedPrice() -> String {
        let monthlyProduct = ProductsService.shared.products.first(where: { $0.productIdentifier == Products.monthly.rawValue })
        return monthlyProduct?.localizedPriceString ?? "N/A"
    }
    
    private func monthlyDailyLocalizedPrice() -> String {
        let monthlyProduct = ProductsService.shared.products.first(where: { $0.productIdentifier == Products.monthly.rawValue })
        return monthlyProduct?.localizedPricePerDay ?? "N/A"
    }
    
    // Weekly prices
    private func weeklyLocalizedPrice() -> String {
        let weekProduct = ProductsService.shared.products.first(where: { $0.productIdentifier == Products.weekly.rawValue })
        return weekProduct?.localizedPriceString ?? "N/A"
    }
    
    private func weeklyDailyLocalizedPrice() -> String {
        let weekProduct = ProductsService.shared.products.first(where: { $0.productIdentifier == Products.weekly.rawValue })
        return weekProduct?.localizedPricePerDay ?? "N/A"
    }
}

#Preview() {
    SubscriptionView() {}
}
