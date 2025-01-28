//
//  BaseAPI.swift
//  autodocNews
//
//  Created by Александр Гужавин on 17.01.2025.
//

import UIKit
import Combine

enum APIError: Error {
    case invalidURL
    case responseError(statusCode: Int)
    case decodingError
    case unknownError(title: String)
}

class BaseAPI {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>( endpoint: String,
                                method: String = "GET",
                                headers: [String: String]? = nil,
                                body: Data? = nil) async throws -> T {
        guard let url = URL(string: endpoint) else {
            print(endpoint)
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknownError(title: "Response is not HTTPURLResponse")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.responseError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder: JSONDecoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            throw APIError.decodingError
        }
    }
    
    func downloadImage(from url: String) async throws -> Data {
        guard let imageUrl = URL(string: url) else {
            print(url)
            throw APIError.invalidURL
        }
            
        let cacheKey = imageUrl.absoluteString
        let (data, response) = try await session.data(from: imageUrl)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.responseError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
            
        guard let image = UIImage(data: data),
            let resizedImageData = image.jpegData(compressionQuality: 0.5) else {
            throw APIError.unknownError(title: "Failed to compress image")
        }
        
        return resizedImageData
    }
}
