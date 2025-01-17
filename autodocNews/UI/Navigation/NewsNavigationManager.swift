//
//  NewsNavigationManager.swift
//  autodocNews
//
//  Created by Александр Гужавин on 17.01.2025.
//

import UIKit

protocol NavigationManaging {
    func pushViewController(_ viewController: UIViewController, animated: Bool)
    func popViewController(animated: Bool)
    func present(_ viewController: UIViewController, animated: Bool)
    func dismiss(animated: Bool)
    func setRootViewController(_ viewController: UIViewController)
    func currentViewController() -> UIViewController?
}

enum NewsListNavigation {
    case main
    case detail(String)
}

class NewsNavigationManager: NavigationManaging {
    
    static let shared = NewsNavigationManager()

    private var navigationController: UINavigationController!
    
    
    var nc: UINavigationController {
        get {
            return navigationController
        }
    }
    
    init() {
        self.navigationController = UINavigationController(rootViewController: ViewControllerFactory.createViewController(for: .main))
    }
    
    func pushViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
    
    func present(_ viewController: UIViewController, animated: Bool) {
        navigationController.present(viewController, animated: animated, completion: nil)
    }
    
    func dismiss(animated: Bool) {
        navigationController.dismiss(animated: animated, completion: nil)
    }
    
    func setRootViewController(_ viewController: UIViewController) {
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func currentViewController() -> UIViewController? {
        return navigationController.topViewController
    }
    
    func pushTo(_ controller:NewsListNavigation) {
        let vc = ViewControllerFactory.createViewController(for: controller)
        pushViewController(vc, animated: true)
    }
}
