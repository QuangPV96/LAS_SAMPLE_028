import UserNotifications

public class UserNotificationHandle: NSObject {
    
    // MARK: - properties
    let titles: [String] = [
        "Music just for you 🎧\nListen and download free music 🎧",
        "👉 Tap to play music",
        "Keep Listening! Keep Swinging!",
        "👉 Tap to play \"YouTube Offline\" !!!\nFind 👉 New & Trending songs"
    ]
    
    // MARK: - initial
    @objc public static let shared = UserNotificationHandle()
    
    // MARK: - private
    private func randomTitle() -> String {
        let index = Int.random(in: 0..<titles.count)
        return titles[index]
    }
    
    // MARK: - public
    @objc public func request(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _  in
            self?.makeScheduleEveryday(title: self?.titles.first ?? "")
            completion(granted)
        }
    }
    
    @objc public func makeScheduleEveryday(body: String = "Enjoy top pop songs of all time 📀📀📀", hour: Int = 9, minute: Int = 30)
    {
        makeScheduleEveryday(title: self.randomTitle(), body: body, hour: hour, minute: minute)
    }
    
    @objc public func makeScheduleEveryday(title: String, body: String = "Enjoy top pop songs of all time 📀📀📀", hour: Int = 9, minute: Int = 30)
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            // find id notification has exists
            var identifier: String?
            for noti in notifications {
                if let trigger = noti.trigger as? UNCalendarNotificationTrigger {
                    if trigger.dateComponents.hour == hour && trigger.dateComponents.minute == minute {
                        identifier = noti.identifier
                        break
                    }
                }
            }
            
            // remove notification with identifier
            if let id = identifier {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            }
            
            // re-add
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
}
