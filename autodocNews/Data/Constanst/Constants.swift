//
//  Constants.swift
//  autodocNews
//
//  Created by Александр Гужавин on 17.01.2025.
//
import UIKit

enum Constants {
    enum URL {
        static let baseAPI = "https://webapi.autodoc.ru/api"
        enum API {
            static let news = baseAPI + "/news/"
        }
    }
    
    enum NavigationTitle {
        static let newsList = "Новости"
        static let newsDetails = "Новость"
    }
    
    enum Device {
        static let orientation = UIDevice.current.orientation
        static let type = UIDevice.current.userInterfaceIdiom
    }
}
