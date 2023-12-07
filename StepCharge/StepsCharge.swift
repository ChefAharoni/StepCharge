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

struct AIView: View {
    @State private var aiResponse: String = ""

    var body: some View {
        VStack {
            Text("AI Response:")
            Text(aiResponse)
                .padding()

            // Button to trigger AI interaction
            Button("Fetch AI Response") {
                fetchAIResponse()


	
    var body: some Scene {
        WindowGroup {
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

                HealthView(healthKitManager: healthKitManager, displayMode: .monthly)
                    .tabItem {
                        Label("Monthly Steps", systemImage: "calendar")
                    }
                    .tag(2)

                StepRedeemView(healthKitManager: healthKitManager, userName: userName)
                    .tabItem {
                        Label("Redeem", systemImage: "dollarsign.circle")
                    }
                    .tag(3)
		      // Add a view to trigger the AI interaction
                AIView(healthKitManager: healthKitManager)
                    .tabItem {
                        Label("AI Interaction", systemImage: "ellipsis.bubble")
                    }
                    .tag(4)
            
            }
            .onAppear {
                healthKitManager.queryMonthlyStepCount()  // Fetch monthly steps when the TabView appears
		 // Fetch AI response when the TabView appears
                fetchAIResponse()
            }
            .onAppear {
                healthKitManager.queryDailyStepCount() // Fetch daily steps when the TabView appears
            }
        }
    }
    // Method to fetch AI response
    func fetchAIResponse() {
        // Use a networking library or URLSession to fetch data from Cloudflare Worker
        // You can replace the placeholder URL with the actual URL of your Cloudflare Worker
        guard let url = URL(string: "https://your-cloudflare-worker-url") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                // Parse the data and update UI as needed
                // You may need to decode the response depending on the format
                let decodedResponse = try? JSONDecoder().decode(ResponseType.self, from: data)
                // Update UI or perform other actions with the decoded response
            }
        }.resume()
    }
}
