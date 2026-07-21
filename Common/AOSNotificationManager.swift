import Foundation
import UserNotifications

public final class AOSNotificationManager {
    public static let shared = AOSNotificationManager()
    
    private init() {}
    
    public func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Notification permissions error: \(error.localizedDescription)")
            }
        }
    }
    
    public func scheduleLowRunwayAlert(months: Double) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Capital Runway Alert"
        content.body = String(format: "Your survival runway is down to %.1f months! Cost reductions are highly recommended.", months)
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "LowRunwayAlert", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    public func scheduleMissionReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Daily Missions Pending"
        content.body = "Remember to complete your daily missions before the evening reset to protect your streak!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8 PM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "DailyMissionsReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    public func scheduleHabitReminder(forHabit title: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔥 Habit Stack Due"
        content.body = "It's time for your habit: \(title). Perform your stack response to claim stat XP!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600 * 4, repeats: true) // Every 4 hours
        let request = UNNotificationRequest(identifier: "Habit_\(title)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    public func scheduleLeanCanvasReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🚀 Business Assumptions Overdue"
        content.body = "Your Lean Canvas assumptions have not been revised in 14 days. Review validation logs now."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400 * 2, repeats: true) // Every 2 days
        let request = UNNotificationRequest(identifier: "LeanCanvasOverdue", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
