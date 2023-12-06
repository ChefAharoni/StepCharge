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
//    @AppStorage("lastRedemptionDateString") private var lastRedemptionDateString: String?

    var body: some View {
        VStack {
            Text("Welcome, \(userName)")
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
                redeemCredits(creditsToAdd: stepsCredits)
                showingRedemptionAlert = true
//                lastRedemptionDateString = ISO8601DateFormatter().string(from: Date()) // Store the date as a string
            }
//            .disabled(!canRedeemCredits(steps: steps))
//            .disabled(showingMonthlySteps ? steps < 50000 : steps < 10000)
            .alert(isPresented: $showingRedemptionAlert) {
                Alert(title: Text("Credits Redeemed"), message: Text("You have redeemed $\(calculateCredits(steps: steps), specifier: "%.2f") credits."), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
        .onAppear {
            healthKitManager.queryMonthlyStepCount()
        }
    }

    func calculateCredits(steps: Int) -> Double {
        return Double(steps) * 0.0001
    }

    func redeemCredits(creditsToAdd: Double) {
        credits += creditsToAdd
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
