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

        private func generateImageForSteps(_ steps: Int) {
            let description = "A scenic view of a location equivalent to a walk of \(steps) steps" // Customize this prompt as needed
            requestImageFromDALLE(description: description)
        }

        private func requestImageFromDALLE(description: String) {
            let url = URL(string: "https://api.openai.com/v1/images/generations")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(Config.openAIKey)", forHTTPHeaderField: "Authorization")

            let body: [String: Any] = [
                "prompt": description,
                "n": 1,
                "size": "1024x1024"
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                // Parse the response data
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let data = jsonResponse["data"] as? [[String: Any]],
                   let firstImage = data.first,
                   let imageUrlString = firstImage["url"] as? String,
                   let imageUrl = URL(string: imageUrlString) {
                    
                    DispatchQueue.main.async {
                        self.imageUrl = imageUrl // Update imageUrl to display the image
                    }
                } else {
                    print("Failed to parse JSON or extract image URL")
                }
            }.resume()
        }


    }

    
//    struct HealthView_Previews: PreviewProvider { // Preview Provider: This struct provides a preview of HealthView in Xcode's canvas.
//        static var previews: some View {
//            HealthView()
//        }
//    }
//}
