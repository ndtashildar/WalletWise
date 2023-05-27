//
//  UserModel.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/15/23.
//

import Foundation

struct UserModel {
    let umid: String
    var totalBudget: Double
    var totalSpending: Double
    var budgets: [BudgetModel]
}
