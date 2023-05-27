//
//  MapView.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/14/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var locationManager = LocationManager()

    @State var tracking:MapUserTrackingMode = .follow

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack{
                    HStack {
                        NavBarOverlay(screenTitle: "Banks & ATMs")
                            .padding(.leading)
                        Spacer()
                    }
                    Map(
                        coordinateRegion: $locationManager.region,
                        interactionModes: MapInteractionModes.all,
                        showsUserLocation: true,
                        userTrackingMode: $tracking,
                        annotationItems: locationManager.markers
                    ){location in
                        MapAnnotation(coordinate: location.coordinate) {
                            VStack(spacing: 0) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.red)
                                Text(location.name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                            .padding(8)
                            .background(Color.clear)
                            .offset(y: -22)
                        }
                    }
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
                .onAppear {
                    DispatchQueue.main.async {
                        locationManager.searchNearbyBanksAndATMs()
                        print("onAppear")
                    }
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
