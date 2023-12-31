//
//  HealthKitManager.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/6/23.
//

import HealthKit
import Combine

class HealthKitManager: ObservableObject { // Class Declaration: Defines HealthKitManager as a class. The ObservableObject protocol allows instances of this class to be used within SwiftUI, enabling SwiftUI views to update when properties marked with @Published change.
    let healthStore = HKHealthStore() // Health Store Property: Instantiates HKHealthStore, which is a HealthKit object that provides an interface for accessing and storing health data.
    //    @Published var steps = 0 // Published property to notify SwiftUI of changes. | Published Property: Declares steps as an @Published property. This means that any changes to steps will notify SwiftUI views to update. steps is initialized to 0 and will store the step count.
    
    @Published var dailySteps = 0
    @Published var monthlySteps = 0
    
    init() { // Initializer: The init method checks if HealthKit data is available (HKHealthStore.isHealthDataAvailable()) and calls requestAuthorization() if it is. If HealthKit is not available, this is where you could handle that case (currently empty).
        if HKHealthStore.isHealthDataAvailable() {
            requestAuthorization()
        } else {
            // Health data is not available on this device
        }
    }
    
    func requestAuthorization() {
        // Request Authorization: This method requests the user's permission to read their step count data. It first ensures that the step count type (HKObjectType.quantityType(forIdentifier: .stepCount)) is valid. The requestAuthorization method of HKHealthStore is then called, specifying that we want to read step count data. If authorization is successful, queryStepCount is called. Error handling for failure of authorization should be done in the else block.
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return // This should never fail
        }
        
        healthStore.requestAuthorization(toShare: nil, read: Set([stepCountType])) { [weak self] success, error in
            if success {
                self?.queryDailyStepCount()
            } else {
                // Handle errors or lack of permissions here
            }
        }
    }
    
    func queryDailyStepCount() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            let dailyStepsCount = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                self?.dailySteps = Int(dailyStepsCount)
            }
        }
        healthStore.execute(query)
    }
    
    func queryMonthlyStepCount() {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let now = Date()
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: now)) ?? now
        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            let monthlyStepsCount = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
                self?.monthlySteps = Int(monthlyStepsCount)
            }
        }
        healthStore.execute(query)
    }
    
}
