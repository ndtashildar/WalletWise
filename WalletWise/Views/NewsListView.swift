//
//  NewsListView.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/18/23.
//

import SwiftUI

struct NewsListView: View {
    @StateObject var viewModel = NewsViewModel()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var newsItems: [NewsItem] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    NavBarOverlay(screenTitle: "News")
                        .frame(height: 44)
                    Spacer()
                    Text("Financial News")
                        .font(.title)
                    
                    Divider()
                    
                    if viewModel.isLoading {
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    } else if let newsItems = viewModel.newsItems {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(newsItems, id: \.uuid) { newsItem in
                                    let formattedDate = formatDate(newsItem.published_at)
                                    VStack(alignment: .leading) {
                                        Link(destination: URL(string: newsItem.url)!) {
                                            Text(newsItem.title)
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                        }
                                        Spacer()
                                        Text(newsItem.description)
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                        Spacer()
                                        Text(formattedDate, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Divider()
                                    }
                                }
                            }
                        }
                    } else {
                        Text("Failed to load news")
                            .foregroundColor(.red)
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
                .padding(.horizontal, 30)
                .onAppear{
                    viewModel.fetchNews()
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func formatDate(_ date: String) -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.date(from: date) ?? Date()
    }
}


