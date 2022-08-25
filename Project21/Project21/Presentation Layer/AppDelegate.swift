//
//  AppDelegate.swift
//  Project21
//
//  Created by Pham Anh Tuan on 8/23/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // let this to be delegator of User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
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

    // MARK: - User Notification Center Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        guard var userInfo = response.notification.request.content.userInfo as? [String: String] else { return }
        
        userInfo["actionIdentifier"] = response.actionIdentifier
        
        if let textInputNotificationResponse = response as? UNTextInputNotificationResponse {
            userInfo["inputtedText"] = textInputNotificationResponse.userText
        }
        
        ViewController.shared.saveUserNotificationDidReceiveResponse(userInfo)
        
        ViewController.shared.isExecutedUserNotificationDidReceive = false

        if response.actionIdentifier == "remindMeInNextSeconds" {
            ViewController.shared.executeUserNotificationDidReceive()
        }

        completionHandler()
    }

}

