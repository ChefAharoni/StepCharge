//
//  StepsCharge.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/6/23.
//
import Foundation
import SwiftUI

@main
struct StepsCharge: App {
    @StateObject var healthKitManager = HealthKitManager()
    @State private var userName: String = ""
    @State private var showAccountEntryView = true
    @State private var showStepView = false
    @State private var showStepRedeemView = false
    @State private var selectedTab: Int = 0

    var body: some Scene {
        WindowGroup {
            TabView {
                AccountEntryView(userName: $userName, selectedTab: $selectedTab)
                    .tabItem {
                        Label("Account", systemImage: "person.crop.circle")
                    }
                    .tag(0)

                HealthView(healthKitManager: healthKitManager, displayMode: .daily)
                    .tabItem {
                        Label("Daily Steps", systemImage: "sun.max")
                    }
                    .tag(1)

                HealthView(healthKitManager: healthKitManager, displayMode: .monthly)
                    .tabItem {
                        Label("Monthly Steps", systemImage: "calendar")
                    }

                StepRedeemView(healthKitManager: healthKitManager, userName: userName)
                    .tabItem {
                        Label("Redeem", systemImage: "dollarsign.circle")
                    }
            }
        }
    }
}

/*
 @StateObject var healthKitManager = HealthKitManager()
 @State private var userName: String = ""
 @State private var selectedTab: Int = 0
 TabView(selection: $selectedTab) {
     AccountEntryView(userName: $userName, selectedTab: $selectedTab)
         .tabItem {
             Label("Account", systemImage: "person.crop.circle")
         }
         .tag(0)

     HealthView(healthKitManager: healthKitManager, displayMode: .daily)
         .tabItem {
             Label("Daily Steps", systemImage: "sun.max")
         }
         .tag(1)
 */
