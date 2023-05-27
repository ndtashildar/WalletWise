//
//  BudgetModel.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/15/23.
//

import Foundation

struct BudgetModel {
    let categoryName: String
    var categoryIcon: String
    var categoryBudget: Double
    var categorySpending: Double
    var spendingDetails: [SpendingDetailModel]?
}
