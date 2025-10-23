//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Stepan on 22.10.2025.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    private let apiKey = "f56a56c51b2b49a9a90acfd5607b73a0"
    
    func fetchNews(completion: @escaping (Result<[Article], Error>) -> Void) {
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&apiKey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("❌ Wrong URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ No data from server")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                completion(.success(decoded.articles))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
        
    }
    
}
