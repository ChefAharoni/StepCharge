//
//  HealthKitManager.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/6/23.
//

import HealthKit
import Combine

import SwiftUI

struct HealthView: View { // View Declaration: Declares a new SwiftUI view named HealthView.
    @ObservedObject var healthKitManager: HealthKitManager
    var displayMode: DisplayMode
    enum DisplayMode {
        case daily, monthly
    }
//    @StateObject var healthKitManager = HealthKitManager() // StateObject: Creates an instance of HealthKitManager and marks it as a @StateObject. This means that HealthView will re-render whenever healthKitManager publishes changes (e.g., when steps is updated).
    
    var body: some View {
        // Body Property: Defines the UI of HealthView. It uses a VStack (vertical stack) to arrange text views. The first Text view displays a title, and the second shows the step count, binding to healthKitManager.steps. The .onAppear modifier is used to trigger the queryStepCount method when the view appears on screen.
        VStack {
            VStack {
                if displayMode == .daily {
                    Text("Daily Steps: \(healthKitManager.dailySteps)")
                    // Additional UI for daily steps
                } else {
                    Text("Monthly Steps: \(healthKitManager.monthlySteps)")
                    // Additional UI for monthly steps
                }
            }
        }
    }
    
//    struct HealthView_Previews: PreviewProvider { // Preview Provider: This struct provides a preview of HealthView in Xcode's canvas.
//        static var previews: some View {
//            HealthView()
//        }
//    }
}
