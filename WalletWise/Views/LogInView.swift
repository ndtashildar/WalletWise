//
//  LogInView.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/14/23.
//

import SwiftUI
import FirebaseAuth

struct LogInView: View {
    
    @StateObject var userViewModel = UserViewModel()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // regular expression to validate entered email
    private let emailRegex = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/
    
    // store the email used by the user to log-in/sign-up in shared preferences
    @AppStorage("email") private var email: String = ""
    @State private var password: String = ""
    
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    @State private var showingProgressBar: Bool = false
    
    @State private var isLoggedIn = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                if showingProgressBar {
                    ProgressView()
                }
                else {
                    VStack(spacing: 20) {
                        NavBarOverlay(screenTitle: "Log In").frame(height: 44)
                        Spacer()
                        Image("log-in-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                            .autocorrectionDisabled(true)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 200)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        
                        Button(action: {
                            // check if the form is valid
                            if isFormValid() {
                                showingProgressBar = true
                                // create an asynchronous task to log the user in
                                Task {
                                    await login()
                                    showingProgressBar = false
                                }
                            }
                        }) {
                            Text("Log In")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.gray)
                        .cornerRadius(10)
                        
                        Button(action: {
                            // check if the form is valid
                            if isFormValid() {
                                showingProgressBar = true
                                // create an asynchronous task to sign the user up
                                Task {
                                    await signup()
                                    showingProgressBar = false
                                }
                            }
                        }) {
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.gray)
                        .cornerRadius(10)
                        
                        Spacer()
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
                    .padding(.horizontal, 30)
                    }
                }
                
        }.navigationBarBackButtonHidden(true)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                showingAlert = false
            }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $isLoggedIn, content: {
            BudgetsView()
        })
    }
    
    // validate user input before proceeding with either log in or sign up
    private func isFormValid() -> Bool {
        // Case 1: email shouldn't be empty
        if email.isEmpty {
            showAlert(
                title: "Email Input Error",
                message: "Email address cannot be empty"
            )
            return false
        }
        // Case 2: email should be in the correct format (OPTIONAL)
        guard let _ = try? emailRegex.wholeMatch(in: email) else {
            showAlert(
                title: "Email Input Error",
                message: "\(email) is not a valid email address"
            )
            return false
        }
        // Case 3: password shouldn't be empty
        if password.isEmpty {
            showAlert(
                title: "Password Input Error",
                message: "Password cannot be empty"
            )
            return false
        }
        // Case 4: password length criteria should satisfy
        if password.count < 6 {
            showAlert(
                title: "Password Input Error",
                message: "Password length is too short (need something greater than 5)"
            )
            return false
        }
        return true
    }
    
    private func login() async {
        do {
            // use Firebase auth library to log-in the user
            try await Auth.auth().signIn(withEmail: email, password: password)
            isLoggedIn = true
            password = ""
        } catch let error {
            showAlert(
                title: "Login Error",
                message: error.localizedDescription
            )
        }
    }
    
    private func signup() async {
        do {
            // use Firebase auth library to sign-up a new user
            try await Auth.auth().createUser(withEmail: email, password: password)
            userViewModel.createUserData()
            password = ""
            showAlert(
                title: "Account Created Successfully",
                message: "Log in using your credentials"
            )
        } catch let error {
            showAlert(
                title: "Sign-up Error",
                message: error.localizedDescription
            )
        }
    }
    
    // utility function, prompts alert with provided title and message
    private func showAlert(title: String, message: String) {
        showingAlert = true
        alertTitle = title
        alertMessage = message
        showingProgressBar = false
    }
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
