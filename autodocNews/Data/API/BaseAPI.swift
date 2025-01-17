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
                                body: Data? = nil,
                                decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: endpoint) else {
            print(endpoint)
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.httpBody = body

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknownError(title: "is not HTTPURLResponse")
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.responseError(statusCode: httpResponse.statusCode)
                }

                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                switch error {
                case is DecodingError:
                    return APIError.decodingError
                case let apiError as APIError:
                    return apiError
                default:
                    return APIError.unknownError(title: "default")
                }
            }
            .eraseToAnyPublisher()
    }
    
    func downloadImageWithCash(from url: String) -> AnyPublisher<Data, APIError> {
        guard let imageUrl = URL(string: url) else {
            print(url)
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        let cacheKey = imageUrl.absoluteString
        
        return session.dataTaskPublisher(for: imageUrl)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.responseError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
                }
                let image = UIImage(data: data)!
                let resizeImageData = image.jpegData(compressionQuality: 0.5)
                return resizeImageData ?? Data()
            }
            .mapError { error -> APIError in
                switch error {
                case let apiError as APIError:
                    return apiError
                default:
                    return APIError.unknownError(title: "default")
                }
            }
            .eraseToAnyPublisher()
    }
}
