//
//  NewsListViewModel.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/18/23.
//

import Foundation

class NewsViewModel: ObservableObject {
    @Published var newsItems = [NewsItem]()
    @Published var isLoading = false // Add isLoading property

    func fetchNews() {
        guard let url = URL(string: "https://api.marketaux.com/v1/news/all?countries=us&language=en&api_token=eriJHRAj3KSEwA7cDwMCwEQlAKpNMNLyOeAPno5X") else {
            return
        }
        
        isLoading = true // Update isLoading to true before starting network request
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data else {
                return
            }
            
            do {
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.newsItems = newsResponse.data
                    self.isLoading = false // Update isLoading to false once request completes
                }
            } catch let error {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}
