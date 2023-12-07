//
//  AccountManager.swift
//  StepCharge
//
//  Created by Amit Aharoni on 12/7/23.
//

import Foundation

 class AccountManager {
     static let shared = AccountManager()
     private init() {}

     private let accountBalanceKey = "accountBalances"

     func getBalance(forUser userName: String) -> Double {
         let balances = UserDefaults.standard.dictionary(forKey: accountBalanceKey) as? [String: Double] ?? [:]
         return balances[userName] ?? 0.0
     }

     func updateBalance(forUser userName: String, amount: Double) {
         var balances = UserDefaults.standard.dictionary(forKey: accountBalanceKey) as? [String: Double] ?? [:]
         balances[userName] = (balances[userName] ?? 0.0) + amount
         UserDefaults.standard.set(balances, forKey: accountBalanceKey)
     }

     func initializeBalance(forUser userName: String) {
         var balances = UserDefaults.standard.dictionary(forKey: accountBalanceKey) as? [String: Double] ?? [:]
         if balances[userName] == nil {
             balances[userName] = 88.12 // Set initial balance to 88.12 USD
             UserDefaults.standard.set(balances, forKey: accountBalanceKey)
         }
         
     }
     
 }


