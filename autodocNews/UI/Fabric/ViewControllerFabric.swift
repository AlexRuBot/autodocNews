//
//  ViewControllerFabric.swift
//  autodocNews
//
//  Created by Александр Гужавин on 17.01.2025.
//

import UIKit

class ViewControllerFactory {

    static func createViewController(for type: NewsListNavigation) -> UIViewController {
        switch type {
        case .main:
            return NewsListController()
        case .detail(let url):
            let detailController = NewsDetailController()
            detailController.urlString = url
            return detailController
        }
    }
}
