//
//  NotificationManager.swift
//  Plants
//
//  Created by Assistant on 2025-10-27
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
        }
    }

    func scheduleWateringReminderIfNeeded(for plant: Plant) {
        // فقط للنباتات اليومية وغير المسقاة
        guard plant.wateringDays == "Every day", plant.isWateredToday == false else { return }

        // منع التكرار: ألغِ الموجود أولاً
        cancelReminder(for: plant)

        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let's water your plant"
        content.sound = .default

        // بعد 5 ثوانٍ من الآن
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: notificationID(for: plant.id),
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule: \(error)")
            }
        }
    }

    func cancelReminder(for plant: Plant) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID(for: plant.id)])
    }

    private func notificationID(for id: UUID) -> String {
        "water_reminder_\(id.uuidString)"
    }
}
