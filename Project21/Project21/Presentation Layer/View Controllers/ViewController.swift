//
//  ViewController.swift
//  Project21
//
//  Created by Pham Anh Tuan on 8/23/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    let triggerNotificationAfterTimeInterval = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(handleRegisterButtonTapped))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Schedule w/ Cal", style: .plain, target: self, action: #selector(handleScheduleWithCalendarButtonTapped)),
            UIBarButtonItem(title: "Schedule w/ Interval", style: .plain, target: self, action: #selector(handleScheduleWithTimeIntervalButtonTapped))
        ]
    }
    
    // MARK: - Button Handlers
    
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
    
    @objc private func handleScheduleWithCalendarButtonTapped() {
        var triggerDate = DateComponents()
        triggerDate.hour = 8
        triggerDate.minute = 10
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        scheduleNotification(trigger: trigger)
    }
    
    @objc private func handleScheduleWithTimeIntervalButtonTapped() {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(triggerNotificationAfterTimeInterval), repeats: false)
        
        scheduleNotification(trigger: trigger)
    }
    
    // MARK: - Notification Center Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let data = userInfo["data"] as? String {
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // do something
                print("swipe ... \(data)")
            case "show":
                // do something
                print("tap show ... \(data)")
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    // MARK: - Extra Funcs
    
    private func scheduleNotification(trigger: UNNotificationTrigger) {
        registerCategory()
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Take my son from school"
        content.subtitle = "don't forget icecream & pancake"
        content.body = "4:30PM at Hoa Hong school"
        content.sound = .default
        content.badge = 10
        content.categoryIdentifier = "alarm"
        content.userInfo = ["data": "something"]

        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))

    }

    private func registerCategory() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Show", options: .foreground, icon: UNNotificationActionIcon(systemImageName: "rectangle.portrait.and.arrow.right.fill"))
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
}

