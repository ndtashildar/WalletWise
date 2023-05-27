//
//  BudgetsView.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/14/23.
//

import SwiftUI
import FirebaseAuth

struct BudgetsView: View {
    
    @ObservedObject var userViewModel = UserViewModel()
    
    @State private var totalBudget: Double = 0.0
    @State private var totalSpending: Double = 0.0
    @State private var budgetCategories: [BudgetModel] = []
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    NavBarOverlay(screenTitle: "Budgets", isLoggedIn: true)
                        .frame(height: 44)
                    Spacer()
                    Text("Budgets")
                        .font(.title)
                    
                    BudgetTile(budget: $totalBudget, spending: $totalSpending, viewName: "Budget")

                    Spacer()
                    if let budgetCategories = budgetCategories {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(budgetCategories, id: \.categoryName) { budget in
                                    NavigationLink(destination: BudgetCategoryView(budgetCategory: budget.categoryName)) {
                                        HStack {
                                            Image(systemName: budget.categoryIcon)
                                            Text(budget.categoryName)
                                            .foregroundColor(.white) // set text color to white
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 5) {
                                                Text("$\(String(format: "%.2f",budget.categoryBudget))")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                Text("- $\(String(format: "%.2f",budget.categorySpending))")
                                                    .foregroundColor(.red)
                                                    .font(.system(size: 14))
                                            }
                                        }
                                        .padding()
                                        .background(Color.gray)
                                        .cornerRadius(10)
                                        .shadow(radius: 3)
                                    }
                                }

                            }
                        }

                    }
                    Spacer()
                    HStack {
                        
                        NavigationLink(destination: AddSpendingView(viewName: "Budget")) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        })
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 30)
                .onAppear{
                    guard let userId = Auth.auth().currentUser?.uid else {
                        print("User is not authenticated.")
                        return
                    }
                    userViewModel.fetchUser(userId: userId) { user in
                        if let user = user {
                            totalBudget = user.totalBudget
                            totalSpending = user.totalSpending
                            budgetCategories = user.budgets
                        } else {
                            print("Failed to fetch user data.")
                        }
                    }
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct BudgetsView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetsView()
    }
}
