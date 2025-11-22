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
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    Image("mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                    
                    Text("Get Your 15 Years Back With Brainheal")
                        .foregroundStyle(.black)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .padding(.bottom, 4)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                    
                    Text("The only working way to reverse cognitive decline")
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    Button {
                        selectedPlan = .annual
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
                                
                                Text("\(annualDailyLocalizedPrice()) / day")
                                    .foregroundStyle(.textSecondary)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
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
                    
                    Button {
                        selectedPlan = .weekly
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
                                
                                Text("\(weeklyDailyLocalizedPrice()) / day")
                                    .foregroundStyle(.textSecondary)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
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
                        Text("Continue")
                            .foregroundStyle(.white)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    .buttonStyle(
                        PressableButtonStyle(
                            foregroundColor: .green,
                            backgroundColor: .green.opacity(0.7),
                            cornerRadius: 16
                        )
                    )
                    .frame(height: 60)
                    
                    HStack(spacing: 32) {
                        Button {
                            
                        } label: {
                            Text("Privacy")
                                .foregroundStyle(.textSecondary)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        
                        Button {
                            
                        } label: {
                            Text("Restore Purchase")
                                .foregroundStyle(.textSecondary)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                        
                        Button {
                            
                        } label: {
                            Text("Terms")
                                .foregroundStyle(.textSecondary)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.gray.opacity(0.3))
                    }
                }
            }
        }
    }
    
    func purchase() async {
        guard let product = ProductsService.shared.products.first(where: { $0.productIdentifier == selectedPlan.rawValue }) else {
            return
        }
        do {
            let result = try await Purchases.shared.purchase(product: product)
            if result.userCancelled {
                ProductsService.shared.subscribed = false
                return
            }
            ProductsService.shared.subscribed = true
            dismiss()
        } catch {
            ProductsService.shared.subscribed = false
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
    SubscriptionView()
}
