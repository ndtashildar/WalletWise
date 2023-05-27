//
//  BudgetCategoryView.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/17/23.
//

import SwiftUI
import FirebaseAuth

struct BudgetCategoryView: View {
    @StateObject var userViewModel = UserViewModel()
    
    @State var budgetCategory: String = ""
    
    @State private var categoryBudget: Double = 0.0
    @State private var categorySpending: Double = 0.0
    @State private var spendingDetails: [SpendingDetailModel]?
    
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
                    Text(budgetCategory)
                        .font(.title)
                    BudgetTile(budget: $categoryBudget, spending: $categorySpending, viewName: budgetCategory)

                    Spacer()
                    if let spendingDetails = spendingDetails {
                        if spendingDetails.isEmpty{
                            Spacer()
                            Spacer()
                            Spacer()
                            Text("Tap the + button in the bottom left corner to add spending details!")
                                .font(.headline)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                            Spacer()
                            Spacer()
                        }else{
                            ScrollView {
                                LazyVStack(spacing: 20) {
                                    ForEach(spendingDetails, id: \.smid) { spending in
                                        let formattedDate = formatDate(spending.spendingDate)
                                        
                                        HStack {
                                            Image(systemName: "circle")
                                                .foregroundColor(.blue)
                                                .shadow(radius: 3)
                                            Text(spending.spendingName)
                                                .foregroundColor(.white)
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 5) {
                                                Text("$\(String(format: "%.2f",spending.spendingAmount))")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.red)
                                                Text(formattedDate)
                                                    .foregroundColor(.white)
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
                        
                        NavigationLink(destination: AddSpendingView(viewName: budgetCategory)) {
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
                    userViewModel.fetchBudgetCategory(budgetCategory: budgetCategory) { budget in
                        if let budget = budget {
                            categoryBudget = budget.categoryBudget
                            categorySpending = budget.categorySpending
                            spendingDetails = budget.spendingDetails
                        } else {
                            print("Failed to fetch user data.")
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
    }
}

struct BudgetCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetCategoryView()
    }
}
