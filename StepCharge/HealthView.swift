//
//  HealthKitManager.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/6/23.
//

import HealthKit
import Combine

import SwiftUI

struct HealthView: View {
    @StateObject var healthKitManager = HealthKitManager()

    var body: some View {
       // Body Property: Defines the UI of HealthView. It uses a VStack (vertical stack) to arrange text views. The first Text view displays a title, and the second shows the step count, binding to healthKitManager.steps. The .onAppear modifier is used to trigger the queryStepCount method when the view appears on screen.
        VStack {
            Text("Step Count")
                .font(.headline)

            Text("\(healthKitManager.steps)")
                .font(.largeTitle)
                .padding()
        }
        .onAppear {
            healthKitManager.queryStepCount()
        }
    }
}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}

