//
//  ViewController.swift
//  Project21
//
//  Created by Pham Anh Tuan on 8/23/22.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    let triggerNotificationForRemindMeInSeconds = 10
    let triggerNotificationAfterTimeInterval = 10
    let triggerNotificationAtSpecificDate = [
        "hour": 8,
        "minute": 10
    ]
    
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
        triggerDate.hour = triggerNotificationAtSpecificDate["hour"]
        triggerDate.minute = triggerNotificationAtSpecificDate["minute"]
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        
        scheduleNotification(trigger: trigger)
    }
    
    @objc private func handleScheduleWithTimeIntervalButtonTapped() {
        scheduleWithTimeInterval()
    }
    
    // MARK: - Notification Center Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        if let _ = userInfo["data"] as? String {
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // do something
                print("haaalo")
                showAlert(title: "Swiped!", message: "You've just swipped the notification")
            case "show":
                // do something
                showAlert(title: "Show what?", message: "You've just tapped on Show button!")
            case "remindMeInNextSeconds":
                print("remind me")
                scheduleWithTimeInterval(triggerNotificationForRemindMeInSeconds)
            case "inputSomething":
                print("haaaa")
                guard let inputResponse = (response as? UNTextInputNotificationResponse) else { return }
                
                print("ok, I got it \(inputResponse.userText)")
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    // MARK: - Extra Funcs
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func scheduleWithTimeInterval(_ specifiedTimeInterval: Int? = nil) {
        var timeInterval = triggerNotificationAfterTimeInterval
        if let tmpTimeInterval = specifiedTimeInterval {
            timeInterval = tmpTimeInterval
        }
            
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: false)
        
        scheduleNotification(trigger: trigger)
    }
    
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
        
        let remindMeInNextSeconds = UNNotificationAction(identifier: "remindMeInNextSeconds", title: "Remind me in \(triggerNotificationForRemindMeInSeconds) seconds", options: .destructive, icon: UNNotificationActionIcon(systemImageName: "bell.fill"))
        
        let inputSomething = UNTextInputNotificationAction(identifier: "inputSomething", title: "Note", options: [.foreground], icon: UNNotificationActionIcon(systemImageName: "pencil.circle.fill"), textInputButtonTitle: "Save", textInputPlaceholder: "leave a note")
        
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remindMeInNextSeconds, inputSomething], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
}

