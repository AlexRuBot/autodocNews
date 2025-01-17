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
    private let pageSize = 10
        
    func fetchNews(page: Int) -> AnyPublisher<APINewsList, APIError> {
        let endpoint = "\(baseURL)/\(page)/\(pageSize)"
        return request(endpoint: endpoint)
    }
    
    func fetchImage(url: String) -> AnyPublisher<Data, APIError> {
        return downloadImageWithCash(from: url)
    }
}
    
