//
//  LocalPushService.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import UserNotifications

class LocalPushService: NSObject {
    
    // MARK: - initial
    static let shared = LocalPushService()
    
    // MARK: -
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
            completion(granted)
        }
    }
    
    func addScheduleEveryday(title: String = "👉 Tap to play music!",
                             body: String = "Enjoy top pop songs of all time 📀📀📀",
                             hour: Int = 9, minute: Int = 0)
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            if notifications.count > 0 { return }
            
            // 1
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // 2
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            // 3
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: completion)
    }
}
