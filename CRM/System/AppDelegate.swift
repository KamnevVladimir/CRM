//
//  AppDelegate.swift
//  CRM
//
//  Created by Tsar on 13.05.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let coordinatesVC = CoordinatesViewController()
        let coordinatesNavigationController = UINavigationController(rootViewController: coordinatesVC)
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [coordinatesNavigationController]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }

}

