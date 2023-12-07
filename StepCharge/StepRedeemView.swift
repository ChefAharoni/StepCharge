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
//    @State private var accountBalance: Double = 0.0 // State to store the account balance
    @State private var currentAccountBalance: Double = 0.0 // State to store the current account balance

//    @AppStorage("lastRedemptionDateString") private var lastRedemptionDateString: String?
    
    
    private var accountBalance: Double {
        AccountManager.shared.getBalance(forUser: userName)
    }
    

    var body: some View {
        VStack {
            Text("Welcome, \(userName)")
            Text("Account Balance: $\(accountBalance, specifier: "%.2f")") // Display account balance
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
                if currentAccountBalance >= stepsCredits {
                    redeemCredits(creditsToAdd: stepsCredits)
                    AccountManager.shared.updateBalance(forUser: userName, amount: -stepsCredits)
                    currentAccountBalance -= stepsCredits // Update local state
                    showingRedemptionAlert = true
                } else {
                    // Handle case where there isn't enough balance
                }
            }
            .onAppear {
                currentAccountBalance = AccountManager.shared.getBalance(forUser: userName) // Fetch balance on appear
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
    
//    func canRedeemCredits(steps: Int) -> Bool {
//        let minimumStepsRequired = showingMonthlySteps ? 50000 : 10000
//        let isEligibleForRedemption = steps >= minimumStepsRequired
//
//        guard let lastRedemptionStr = lastRedemptionDateString,
//              let lastRedemption = ISO8601DateFormatter().date(from: lastRedemptionStr) else {
//            return isEligibleForRedemption // No redemption made yet or invalid date string
//        }
//
//        let calendar = Calendar.current
//        let currentMonth = calendar.component(.month, from: Date())
//        let lastRedemptionMonth = calendar.component(.month, from: lastRedemption)
//
//        return isEligibleForRedemption && (currentMonth != lastRedemptionMonth)
//    }
}
