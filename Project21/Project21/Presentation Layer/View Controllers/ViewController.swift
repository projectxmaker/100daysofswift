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
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Schedule w/ Cal", style: .plain, target: self, action: #selector(handleScheduleWithCalendarButtonTapped)),
            UIBarButtonItem(title: "Schedule w/ Interval", style: .plain, target: self, action: #selector(handleScheduleWithTimeIntervalButtonTapped))
        ]
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
    
    private func scheduleNotification(trigger: UNNotificationTrigger) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Title here"
        content.subtitle = "Subtitle here"
        content.body = "Body here"
        content.sound = .default
        content.badge = 10
        content.categoryIdentifier = ""
        content.userInfo = ["data": "something"]

        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))

    }
    
    @objc private func handleScheduleWithCalendarButtonTapped() {
        var triggerDate = DateComponents()
        triggerDate.hour = 8
        triggerDate.minute = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        scheduleNotification(trigger: trigger)
    }
    
    @objc private func handleScheduleWithTimeIntervalButtonTapped() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        scheduleNotification(trigger: trigger)
    }


}

