//
//  StepRedeemView.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/6/23.
//

import SwiftUI

struct StepRedeemView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    var userName: String
    @State private var showingMonthlySteps = true
    @State private var showingRedemptionAlert = false
    @State private var credits = 0.0
    
    private var accountBalance: Double {
        AccountManager.shared.getBalance(forUser: userName)
    }

    var body: some View {
        VStack {
            Text("Welcome, \(userName)")
            Text("Account Balance: $\(accountBalance, specifier: "%.2f")")
            Text("Credits: $\(credits, specifier: "%.2f")")

            Toggle("Monthly \\ Daily Steps", isOn: $showingMonthlySteps)
                .onChange(of: showingMonthlySteps) { newValue in
                    if newValue {
                        healthKitManager.queryMonthlyStepCount()
                    } else {
                        healthKitManager.queryDailyStepCount()
                    }
                }

            let steps = showingMonthlySteps ? healthKitManager.monthlySteps : healthKitManager.dailySteps
            Text("\(showingMonthlySteps ? "Monthly" : "Daily") steps: \(steps)")

            Button("Redeem Credits") {
                let stepsCredits = calculateCredits(steps: steps)
                if accountBalance >= stepsCredits {
                    redeemCredits(creditsToAdd: stepsCredits)
                    AccountManager.shared.updateBalance(forUser: userName, amount: -stepsCredits)
                    showingRedemptionAlert = true
                } else {
                    // Handle case where there isn't enough balance
                }
            }
            .alert(isPresented: $showingRedemptionAlert) {
                Alert(title: Text("Credits Redeemed"), message: Text("You have redeemed $\(calculateCredits(steps: steps), specifier: "%.2f") credits. Remaining balance: $\(accountBalance, specifier: "%.2f")"), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .onAppear {
            healthKitManager.queryMonthlyStepCount()
        }
    }

    func calculateCredits(steps: Int) -> Double {
        return Double(steps) * 0.0001 // 1 credit for every 10,000 steps
    }

    func redeemCredits(creditsToAdd: Double) {
        credits += creditsToAdd // Add Credits to the existing credits
    }
}

