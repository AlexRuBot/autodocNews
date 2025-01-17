//
//  SceneDelegate.swift
//  autodocNews
//
//  Created by Александр Гужавин on 16.01.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowsScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowsScene)
        let nManager = NewsNavigationManager.shared
        window.rootViewController = nManager.nc
        self.window = window
        window.makeKeyAndVisible()
    }
}

