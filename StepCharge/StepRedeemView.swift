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

    var body: some View {
        VStack {
            Text("Welcome, \(userName)")
            Text("Credits: $\(credits, specifier: "%.2f")")

            Toggle("Show Monthly Steps", isOn: $showingMonthlySteps)
                .onChange(of: showingMonthlySteps) { newValue in
                    if newValue {
                        healthKitManager.queryMonthlyStepCount()
                    } else {
                        healthKitManager.queryDailyStepCount()
                    }
                }

            let steps = showingMonthlySteps ? healthKitManager.monthlySteps : healthKitManager.dailySteps
            Text("Your steps: \(steps)")

            Button("Redeem Credits") {
                let stepsCredits = calculateCredits(steps: steps)
                redeemCredits(creditsToAdd: stepsCredits)
                showingRedemptionAlert = true
            }
            .disabled(showingMonthlySteps ? steps < 50000 : steps < 10000)
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
}
