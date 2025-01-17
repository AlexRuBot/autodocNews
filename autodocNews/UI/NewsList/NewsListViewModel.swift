//
//  NewsListViewModel.swift
//  autodocNews
//
//  Created by Александр Гужавин on 16.01.2025.
//

import Combine
import UIKit


final class NewsListViewModel: ObservableObject {
    @Published var news: [News] = []
    private var cancellables = Set<AnyCancellable>()
    
    lazy private var navigator = NewsNavigationManager.shared
    private let apiService = NewsAPI()
    private var page = 0
    
    func fetchNews() {
        let dispatchGroup = DispatchGroup()
        
        page += 1
        apiService.fetchNews(page: page).sink { error in
            print(error)
        } receiveValue: { [weak self] newsList in
            var news: [News] = []
            
            for newsL in newsList.news {
                dispatchGroup.enter()
                self?.fetchImage(url: newsL.titleImageUrl) { image in
                    news.append(News(image: image, title: newsL.title, description: newsL.description, time: newsL.publishedDate, url: newsL.fullUrl))
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                news.sort { $0.time > $1.time }
                self?.news.append(contentsOf: news)
            }
            
        }
        .store(in: &cancellables)
    }
    
    func fetchImage(url: String, completion: @escaping (UIImage) -> Void) {
        apiService.fetchImage(url: url)
            .sink { error in
            print(error)
        } receiveValue: {data in
            completion(UIImage(data: data) ?? UIImage())
        }.store(in: &cancellables)
    }
    
    func pushToDetail(_ url: String) {
        navigator.pushTo(.detail(url))
    }
}
