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

    var body: some View {
        VStack {
            Text("Enter your Account Number:")
            TextField("#####-#####-#", text: $accountNumber)
                .keyboardType(.numberPad)
                .onReceive(accountNumber.publisher.collect()) {
                    let filtered = String($0.filter { "0123456789-".contains($0) })
                    if filtered != accountNumber {
                        accountNumber = filtered.applyPatternOnNumbers(pattern: "#####-#####-#", replacmentCharacter: "#")
                    }
                }
            Button("Submit") {
                userName = mapAccountToName(accountNumber)
                selectedTab = 1 // Change to the Daily Steps tab
                print("Submit tapped, tab changed to \(selectedTab)")

            }
            .disabled(accountNumber.count != 12)
        }
        .padding()
    }

    func mapAccountToName(_ account: String) -> String {
        let accountsDict = ["12345-12345-1": "Alice", "23456-23456-2": "Bob", "34567-34567-3": "Charlie"]
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
