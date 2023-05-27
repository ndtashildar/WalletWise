//
//  UpdateBudgetView.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/16/23.
//

import SwiftUI
import FirebaseAuth

struct UpdateBudgetView: View {

    @StateObject var userViewModel = UserViewModel()
    @State private var budgetCategories: [BudgetModel]?

    @Environment(\.presentationMode) var presentationMode
    
    @State var viewName: String = "Budget"

    @State var selectedCategory: String = "Education"
    @State var inputBudget: String = ""
    @State var showAlert = false
    @State var alertMessage = ""
    
    @State private var isActive = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack {
                    Text("Update Budget")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Divider()
                    VStack {
                        if viewName == "Budget" {
                            if let budgetCategories = budgetCategories {
                                Picker(selection: $selectedCategory, label: Text("Select a category")) {
                                    ForEach(budgetCategories, id: \.categoryName) { budget in
                                        Text(budget.categoryName).tag(budget.categoryName)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 100)
                            }
                        }
                        
                        TextField("Enter new budget", text: $inputBudget)
                            .padding()
                            .frame(height: 50)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Button(action: {
                            guard let newBudget = Double(inputBudget) else {
                                // Throw an error if inputBudget is not a valid double
                                alertMessage = "Please enter a valid number for the budget."
                                showAlert = true
                                return
                            }
                            
                            if inputBudget.isEmpty {
                                alertMessage = "Please enter a budget for the selected category."
                                showAlert = true
                            } else if selectedCategory.isEmpty {
                                alertMessage = "Please select a category."
                                showAlert = true
                            } else {
                                if viewName == "Budget"{
                                    userViewModel.updateCategoryBudget(budgetCategory: selectedCategory, newCategoryBudget: newBudget) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                                else{
                                    userViewModel.updateCategoryBudget(budgetCategory: viewName, newCategoryBudget: newBudget) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }, label: {
                            Text("Update")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        })
                        .padding(.top, 20)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Cancel")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        })
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding()
                }
                .onAppear{
                    guard let userId = Auth.auth().currentUser?.uid else {
                        print("User is not authenticated.")
                        return
                    }
                    userViewModel.fetchUser(userId: userId) { user in
                        if let user = user {
                            budgetCategories = user.budgets
                        } else {
                            print("Failed to fetch user data.")
                        }
                    }
                }
                .alert(isPresented: $showAlert, content: {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                })
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}


struct UpdateBudgetView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateBudgetView()
    }
}
