//
//  WelcomeView.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/14/23.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack {
                    Image("walletwise-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding()
                    Text("Wallet Wise")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                    NavigationLink(destination: LogInView()) {
                        Text("Log In")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                    NavigationLink(destination: MapView()) {
                        Text("Banks")
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
