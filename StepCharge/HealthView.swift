//
//  HealthView.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/6/23.
//

 import HealthKit
 import Combine
 import SwiftUI

 struct HealthView: View {
     @ObservedObject var healthKitManager: HealthKitManager
     var displayMode: DisplayMode
     @State private var imageUrl: URL?
     @State private var generatedLocation: String = ""

     enum DisplayMode {
         case daily, monthly
     }

     var body: some View {
         VStack {
             if displayMode == .daily {
                 Text("Daily Steps: \(healthKitManager.dailySteps)")
                 Button("Generate Image") {
                     generateImageForSteps(healthKitManager.dailySteps)
                 }
             } else {
                 Text("Monthly Steps: \(healthKitManager.monthlySteps)")
                 Button("Generate Image") {
                     generateImageForSteps(healthKitManager.monthlySteps)
                 }
             }
             
             if !generatedLocation.isEmpty {
                 Text(timeFrameText + generatedLocation)
                     .padding()
             }

             if let imageUrl = imageUrl {
                 AsyncImage(url: imageUrl) { image in
                     image.resizable()
                 } placeholder: {
                     ProgressView()
                 }
                 .frame(width: 200, height: 200)
             }
         }
     }

     private var timeFrameText: String {
         switch displayMode {
         case .daily:
             return "Today, you have walked the amount of steps that are equivalent to "
         case .monthly:
             return "This Month, you have walked the amount of steps that are equivalent to "
         }
     }

     private func generateImageForSteps(_ steps: Int) {
         generatePromptForSteps(steps) { fullDescription in
             let location = self.extractLocation(from: fullDescription)
             DispatchQueue.main.async {
                 self.generatedLocation = location // Store the location
             }
             self.requestImageFromDALLE(description: fullDescription) // Use the full description for the image
         }
     }
     
     // Function to extract a location from a given text
     private func extractLocation(from text: String) -> String {
         let sentences = text.components(separatedBy: ". ")
         let firstSentence = sentences.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
         // Extract the first 2-3 words from the sentence as the location
         let words = firstSentence.components(separatedBy: " ")
         let location = words.prefix(3).joined(separator: " ")
         return location
     }

     // ...existing code for generatePromptForSteps and requestImageFromDALLE...
     private func generatePromptForSteps(_ steps: Int, completion: @escaping (String) -> Void) {
         let url = URL(string: "https://api.openai.com/v1/chat/completions")!
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.addValue("Bearer \(Config.openAIKey)", forHTTPHeaderField: "Authorization")
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")

         // Updated prompt to ask for a brief location name
         let prompt = "Provide a short name (2-3 words) of a location that represents a walk of \(steps) steps."
         let body: [String: Any] = [
             "model": "gpt-4",
             "messages": [["role": "system", "content": prompt]]
         ]

         request.httpBody = try? JSONSerialization.data(withJSONObject: body)

     URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
             print("GPT-4 Request Error: \(error.localizedDescription)")
             return
         }

         // Debug: Print the raw response for inspection
         if let jsonStr = String(data: data!, encoding: .utf8) {
             print("Raw JSON Response: \(jsonStr)")
         }

         guard let data = data else {
             print("GPT-4 No Data Received")
             return
         }

         // Adjusted parsing logic
         if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let choices = jsonResponse["choices"] as? [[String: Any]],
            let lastMessage = choices.first?["message"] as? [String: Any],
            let text = lastMessage["content"] as? String {
             
             DispatchQueue.main.async {
                 completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
             }
         } else {
             print("Failed to parse GPT-4 JSON or extract text")
         }
     }.resume()
 }

     private func requestImageFromDALLE(description: String) {
         let url = URL(string: "https://api.openai.com/v1/images/generations")!
         var request = URLRequest(url: url)
         request.httpMethod = "POST"
         request.addValue("application/json", forHTTPHeaderField: "Content-Type")
         request.addValue("Bearer \(Config.openAIKey)", forHTTPHeaderField: "Authorization")

         // Ensure the prompt is suitable for DALL-E
         let dallePrompt = "A scenic view of \(description)"
         let body: [String: Any] = [
             "prompt": dallePrompt,
             "n": 1,
             "size": "1024x1024"
         ]

         request.httpBody = try? JSONSerialization.data(withJSONObject: body)


     URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
             print("DALL-E Request Error: \(error.localizedDescription)")
             return
         }
         if let httpResponse = response as? HTTPURLResponse {
             print("DALL-E Response Status Code: \(httpResponse.statusCode)")
         }
         guard let data = data else {
             print("DALL-E No Data Received")
             return
         }
         if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let data = jsonResponse["data"] as? [[String: Any]],
            let firstImage = data.first,
            let imageUrlString = firstImage["url"] as? String,
            let imageUrl = URL(string: imageUrlString) {
             
             DispatchQueue.main.async {
                 self.imageUrl = imageUrl // Update imageUrl to display the image
             }
         } else {
             print("Failed to parse DALL-E JSON or extract image URL")
         }
     }.resume()
 }
 }

 
