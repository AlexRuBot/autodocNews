//
//  News.swift
//  autodocNews
//
//  Created by Александр Гужавин on 17.01.2025.
//


struct APINewsList: Codable {
    var news: [APINews]
}

struct APINews: Codable {
    var id: Int
    var title: String
    var description: String
    var publishedDate: String
    var url: String
    var fullUrl: String
    var titleImageUrl: String
    var categoryType: String
}
