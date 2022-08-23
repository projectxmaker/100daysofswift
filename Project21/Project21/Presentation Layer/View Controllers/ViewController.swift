//
//  ViewController.swift
//  Project21
//
//  Created by Pham Anh Tuan on 8/23/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(handleRegisterButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(handleScheduleButtonTapped))
    }
    
    @objc private func handleRegisterButtonTapped() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
            if granted {
                print("granted")
            } else {
                print("oops")
            }
        }
    }
    
    @objc private func handleScheduleButtonTapped() {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Title here"
        content.subtitle = "Subtitle here"
        content.body = "Body here"
        content.sound = .default
        content.badge = 10
        content.categoryIdentifier = ""
        content.userInfo = ["data": "something"]

        var triggerDate = DateComponents()
        triggerDate.hour = 7
        triggerDate.minute = 49
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))

    }


}

