//
//  AppDelegate.swift
//  MusicApp
//
//  Created by 張淇雅 on 2022/7/19.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //MARK: -embedded navigationViewController
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController.init(rootViewController: ViewController())
        window.makeKeyAndVisible()
        self.window = window
        
        //MARK: -enabled background mode play musice & enabled silent mode can play music
        AudioHelper.shared.authSessionAccess()
        
        //configure Remote Control for volume and music
        UIApplication.shared.beginReceivingRemoteControlEvents()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

