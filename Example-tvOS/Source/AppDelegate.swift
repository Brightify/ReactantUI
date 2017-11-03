//
//  AppDelegate.swift
//  Example-tvOS
//
//  Created by Matous Hybl on 03/11/2017.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let window = UIWindow()
        self.window = window
        window.backgroundColor = .white
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        activateLiveReload(in: window)
        return true
    }
}

