//
//  NavBarOverlay.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/15/23.
//

import SwiftUI

struct NavBarOverlay: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var screenTitle: String?
    var isLoggedIn: Bool?
    
    @State private var goToBanks: Bool = false
    @State private var goToBudgets: Bool = false
    @State private var goToNews: Bool = false
    
    var body: some View {
            HStack {
                Text(screenTitle ?? "")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                if(isLoggedIn ?? false){
                    
                    Menu {
                        Button("Banks") {
                            goToBanks = true
                            presentationMode.wrappedValue.dismiss()
                        }
    
                        Button("News") {
                            goToNews = true
                            presentationMode.wrappedValue.dismiss()
                        }
                    } label: {
                        HStack {
                            Image("walletwise-logo")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                        }
                        
                    }
                }else{
                    Image("walletwise-logo")
                        .resizable()
                        .frame(width: 30, height: 30)
                    
                }
                
            }.fullScreenCover(isPresented: $goToBanks, content: {
                MapView()
            })
            .fullScreenCover(isPresented: $goToNews, content: {
                NewsListView()
            })
    }
}


struct NavBarOverlay_Previews: PreviewProvider {
    static var previews: some View {
        NavBarOverlay()
    }
}
