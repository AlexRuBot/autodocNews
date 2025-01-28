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
    
    func fetchNews() async throws {
        page += 1
           
            let newsList = try await apiService.fetchNews(page: page)
            
            let newsData: [News] = try await withThrowingTaskGroup(of: News.self) { group in
                for newsL in newsList.news {
                    group.addTask {
                        let imageNews = await self.fetchImage(url: newsL.titleImageUrl)
                        
                        return News(
                            image: imageNews,
                            title: newsL.title,
                            description: newsL.description,
                            time: newsL.publishedDate,
                            url: newsL.fullUrl
                        )
                    }
                }
                
                var results: [News] = []
                for try await newsItem in group {
                    results.append(newsItem)
                }
                return results
            }
            
            let sortedNewsData = newsData.sorted { $0.time > $1.time }
            
            await MainActor.run {
                self.news.append(contentsOf: sortedNewsData)
            }
    }
    
    func fetchImage(url: String) async -> UIImage {
        
        do {
            let dataImage = try await apiService.downloadImage(from: url)
            return UIImage(data: dataImage)!
        } catch {
            print("error fatch image")
            return UIImage()
        }
    }
    
    func pushToDetail(_ url: String) {
        navigator.pushTo(.detail(url))
    }
}
