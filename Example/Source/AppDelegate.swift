//
//  AppDelegate.swift
//  ReactantPrototyping
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import Hyperdrive

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Configuration.global.set(Properties.Style.controllerRoot) {
            $0.backgroundColor = .white
        }

        let window = UIWindow()
        self.window = window
        window.backgroundColor = .white
        window.rootViewController = MainWireframe().entrypoint()
        window.makeKeyAndVisible()

        activateLiveReload(in: window)

        return true
    }
}

