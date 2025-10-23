//
//  Article.swift
//  NewsApp
//
//  Created by Stepan on 22.10.2025.
//

import Foundation

struct Article: Codable {
    let title: String
    let description: String?
    let urlToImage: String?
    let url: String?
}

struct NewsResponse: Codable {
    let articles: [Article]
}

