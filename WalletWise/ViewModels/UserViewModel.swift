//
//  UserViewModel.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/15/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var user: UserModel?
    private var db = Firestore.firestore()
    
    
    func createUserData() {
        // Call this function when a user is created to create a document for that user based on their id
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.createDocument(for: user.uid)
            }
        }
    }
    
    func createDocument(for userId: String) {
        let userRef = db.collection("Users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Document already exists for userID: \(userId)")
            } else {
                userRef.setData([
                    "totalBudget": 3000,  // set default budget to 1000
                    "totalSpending": 0
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(userRef.documentID)")
                    }
                }
                
                for category in [("Food and Drinks", "cart"), ("Housing", "house"), ("Entertainment", "film"), ("Travel", "airplane"), ("Education", "book"), ("Miscellaneous", "square.and.pencil")] {
                    let budgetRef = userRef.collection("Budgets").document(category.0)
                    budgetRef.getDocument { (document, error) in
                        if let document = document, document.exists {
                            print("Document already exists for category: \(category.0)")
                        } else {
                            budgetRef.setData([
                                "categoryIcon": category.1,
                                "categoryBudget": 500,
                                "categorySpending": 0
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(budgetRef.documentID)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchUser(userId: String, completion: @escaping (UserModel?) -> Void) {
        db.collection("Users").document(userId)
            .getDocument { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching user: \(error!)")
                    completion(nil)
                    return
                }
                guard let data = document.data() else {
                    print("User document data was empty.")
                    completion(nil)
                    return
                }
                var budgets = [BudgetModel]()
                let budgetCollection = self.db.collection("Users/\(userId)/Budgets")
                budgetCollection.getDocuments { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print("Error fetching budgets: \(error!)")
                        completion(nil)
                        return
                    }
                    for document in snapshot.documents {
                        let budgetData = document.data()
                        let budget = BudgetModel(
                            categoryName: document.documentID,
                            categoryIcon: budgetData["categoryIcon"] as? String ?? "",
                            categoryBudget: budgetData["categoryBudget"] as? Double ?? 0.0,
                            categorySpending: budgetData["categorySpending"] as? Double ?? 0.0,
                            spendingDetails: nil
                        )
                        budgets.append(budget)
                    }
                    let user = UserModel(
                        umid: userId,
                        totalBudget: data["totalBudget"] as? Double ?? 0.0,
                        totalSpending: data["totalSpending"] as? Double ?? 0.0,
                        budgets: budgets
                    )
                    completion(user)
                }
            }
    }
    
    func updateCategoryBudget(budgetCategory: String, newCategoryBudget: Double, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        
        let userRef = db.collection("Users").document(userId)
        let budgetRef = userRef.collection("Budgets").document(budgetCategory)
        
        db.runTransaction { transaction, errorPointer in
            let budgetDocument: DocumentSnapshot
            do {
                try budgetDocument = transaction.getDocument(budgetRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldCategoryBudget = budgetDocument.data()?["categoryBudget"] as? Double ?? 0.0
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldTotalBudget = userDocument.data()?["totalBudget"] as? Double ?? 0.0
            let newTotalBudget = oldTotalBudget - oldCategoryBudget + newCategoryBudget
            
            transaction.updateData([
                "categoryBudget": newCategoryBudget
            ], forDocument: budgetRef)
            
            transaction.updateData([
                "totalBudget": newTotalBudget
            ], forDocument: userRef)
            
            return nil
        } completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                completion()
            }
        }
    }
    
    func fetchBudgetCategory(budgetCategory: String, completion: @escaping (BudgetModel?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            completion(nil)
            return
        }
        
        let budgetRef = db.collection("Users/\(userId)/Budgets").document(budgetCategory)
        budgetRef.getDocument { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching budget: \(error!)")
                completion(nil)
                return
            }
            guard let data = document.data() else {
                print("Budget document data was empty.")
                completion(nil)
                return
            }
            var spendingDetails = [SpendingDetailModel]()
            let spendingCollection = budgetRef.collection("spendingDetails")
            spendingCollection.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    print("Error fetching spending details: \(error!)")
                    completion(nil)
                    return
                }
                for document in snapshot.documents {
                    let spendingData = document.data()
                    let spending = SpendingDetailModel(
                        smid: document.documentID,
                        spendingName: spendingData["spendingName"] as? String ?? "",
                        spendingAmount: spendingData["spendingAmount"] as? Double ?? 0.0,
                        spendingDate: Date(timeIntervalSince1970: TimeInterval((spendingData["spendingDate"] as? Timestamp)?.seconds ?? 0))
                    )
                    spendingDetails.append(spending)
                }
                let budget = BudgetModel(
                    categoryName: budgetCategory,
                    categoryIcon: data["categoryIcon"] as? String ?? "",
                    categoryBudget: data["categoryBudget"] as? Double ?? 0.0,
                    categorySpending: data["categorySpending"] as? Double ?? 0.0,
                    spendingDetails: spendingDetails
                )
                completion(budget)
            }
        }
    }
    
    func addSpending(budgetCategory: String, spendingName: String, spendingAmount: Double, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        
        let userRef = db.collection("Users").document(userId)
        let budgetRef = userRef.collection("Budgets").document(budgetCategory)
        let spendingDetailsRef = budgetRef.collection("spendingDetails").document()
        let date = Timestamp(date: Date())
        
        db.runTransaction { transaction, errorPointer in
            let budgetDocument: DocumentSnapshot
            do {
                try budgetDocument = transaction.getDocument(budgetRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldCategorySpending = budgetDocument.data()?["categorySpending"] as? Double ?? 0.0
            let newCategorySpending = oldCategorySpending + spendingAmount
            
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldTotalSpending = userDocument.data()?["totalSpending"] as? Double ?? 0.0
            let newTotalSpending = oldTotalSpending + spendingAmount
            
            transaction.updateData([
                "categorySpending": newCategorySpending
            ], forDocument: budgetRef)
            
            transaction.updateData([
                "totalSpending": newTotalSpending
            ], forDocument: userRef)
            
            spendingDetailsRef.setData([
                "spendingName": spendingName,
                "spendingAmount": spendingAmount,
                "spendingDate": date
            ]) { err in
                if let err = err {
                    print("Error adding spending details: \(err)")
                } else {
                    print("Spending details added for category: \(budgetCategory)")
                }
            }
            
            return nil
        }  completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                completion()
            }
        }
    }
    
    func deleteSpending(budgetCategory: String, spendingId: String, spendingAmount: Double, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated.")
            return
        }
        
        let userRef = db.collection("Users").document(userId)
        let budgetRef = userRef.collection("Budgets").document(budgetCategory)
        let spendingRef = budgetRef.collection("spendingDetails").document(spendingId)
        
        db.runTransaction { transaction, errorPointer in
            let budgetDocument: DocumentSnapshot
            do {
                try budgetDocument = transaction.getDocument(budgetRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldCategorySpending = budgetDocument.data()?["categorySpending"] as? Double ?? 0.0
            let newCategorySpending = oldCategorySpending - spendingAmount
            
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let oldTotalSpending = userDocument.data()?["totalSpending"] as? Double ?? 0.0
            let newTotalSpending = oldTotalSpending - spendingAmount
            
            transaction.updateData([
                "categorySpending": newCategorySpending
            ], forDocument: budgetRef)
            
            transaction.updateData([
                "totalSpending": newTotalSpending
            ], forDocument: userRef)
            
            transaction.deleteDocument(spendingRef)
            
            return nil
        } completion: { _, error in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                completion()
            }
        }
    }

}
