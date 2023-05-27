//
//  NewsItem.swift
//  WalletWise
//
//  Created by Ninad Tashildar on 4/18/23.
//

import Foundation

struct NewsResponse: Codable {
    let meta: Meta
    let data: [NewsItem]
}

struct Meta: Codable {
    let found: Int
    let returned: Int
    let limit: Int
    let page: Int
}

struct NewsItem: Codable {
    let uuid: String
    let title: String
    let description: String
    let keywords: String
    let snippet: String
    let url: String
    let image_url: String
    let language: String
    let published_at: String
    let source: String
    let relevance_score: String?
    let entities: [Entity]
    let similar: [NewsItem]?
}

struct Entity: Codable {
    let symbol: String
    let name: String
    let exchange: String
    let exchange_long: String
    let country: String
    let type: String
    let industry: String
    let match_score: Double
    let sentiment_score: Double?
    let highlights: [Highlight]
}

struct Highlight: Codable {
    let highlight: String
    let sentiment: Double
    let highlighted_in: String
}
