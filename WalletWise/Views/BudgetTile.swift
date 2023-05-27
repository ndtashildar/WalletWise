//
//  BudgetTile.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/15/23.
//

import SwiftUI

struct BudgetTile: View {
    @StateObject var userViewModel = UserViewModel()
    @State private var selectedCategory = ""

    @Binding var budget: Double
    @Binding var spending: Double
    @State var viewName: String = "Budget"

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Total")
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                Text(String(format: "$%.2f", budget))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Text(String(format: "- $%.2f", spending))
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
            
            NavigationLink(destination: UpdateBudgetView(viewName: viewName)) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: 15))
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(20)
            }
            .offset(x: 0, y: 5)
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(maxWidth: 400) // set a maximum width
    }
}
