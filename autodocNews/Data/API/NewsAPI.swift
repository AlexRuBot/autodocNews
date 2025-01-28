//
//  NewsAPI.swift
//  autodocNews
//
//  Created by Александр Гужавин on 17.01.2025.
//

import UIKit
import Combine

final class NewsAPI: BaseAPI {
    
    private let baseURL = URL(string: Constants.URL.API.news)!
    private let pageSize: Int = {
        switch Constants.Device.type {
        case .pad:
            return 20
        case .phone:
            return 10
        default:
            return 0
        }
    }()
        
    func fetchNews(page: Int) async throws-> APINewsList {
        let endpoint = "\(baseURL)/\(page)/\(pageSize)"
                
        return try await request(endpoint: endpoint)
    }
    
    func fetchImage(url: String) async throws-> Data {
        return try await downloadImage(from: url)
    }
}
    
