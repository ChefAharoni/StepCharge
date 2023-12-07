//
//  AccountEntryView.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/6/23.
//

import SwiftUI

 struct AccountEntryView: View {
     @State private var accountNumber: String = ""
     @Binding var userName: String
     @Binding var selectedTab: Int
     @State private var isAccountEntered = false // State to track if account is entered

     var body: some View {
         VStack {
             if isAccountEntered {
                 Text("Welcome, \(userName)")
             } else {
                 Text("Enter your Account Number:")
                 TextField("#####-#####-#", text: $accountNumber)
                     .keyboardType(.numberPad)
                     .onReceive(accountNumber.publisher.collect()) {
                         let filtered = String($0.filter { "0123456789-".contains($0) })
                         if filtered != accountNumber {
                             accountNumber = filtered.applyPatternOnNumbers(pattern: "#####-#####-#", replacmentCharacter: "#")
                         }
                     }
             }
             Button("Submit") {
                 userName = mapAccountToName(accountNumber)
                 // Initialize the account balance for the user if needed
                 AccountManager.shared.initializeBalance(forUser: userName)
                 isAccountEntered = true
             }
             .disabled(accountNumber.count != 12)
         }
         .padding()
     }

     func mapAccountToName(_ account: String) -> String {
         let accountsDict = ["12345-12345-1": "Alice", "23456-23456-2": "Bob", "34567-34567-3": "Charlie", "123451234512": "Amit Aharoni"]
         return accountsDict[account] ?? "Unknown User"
     }
 }
 
 extension String {
     func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
         var result = ""
         var index = self.startIndex
         for patternCharacter in pattern {
             if index == self.endIndex {
                 break
             }
             if patternCharacter == replacmentCharacter {
                 result.append(self[index])
                 index = self.index(after: index)
             } else {
                 result.append(patternCharacter)
             }
         }
         return result
     }
 }

