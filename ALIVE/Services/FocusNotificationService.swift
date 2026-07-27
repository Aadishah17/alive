import Foundation

#if os(iOS) && canImport(UserNotifications)
import UserNotifications

public actor FocusNotificationService {
    public static let shared = FocusNotificationService()

    private let reminderIdentifier = "alive.dailyFocusReminder"
    private let notificationCenter = UNUserNotificationCenter.current()

    @discardableResult
    public func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    @discardableResult
    public func scheduleDailyReminder(hour: Int, minute: Int) async -> Bool {
        let content = UNMutableNotificationContent()
        content.title = "Your next quest is ready"
        content.body = "A focused session is the fastest way to earn XP and protect your streak."
        content.sound = .default
        content.threadIdentifier = "alive.focus"
        content.userInfo = ["alive.route": "startFocus"]

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )

        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        do {
            try await notificationCenter.add(request)
            return true
        } catch {
            return false
        }
    }

    public func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }
}
#else
public actor FocusNotificationService {
    public static let shared = FocusNotificationService()

    @discardableResult
    public func requestAuthorization() async -> Bool { false }

    @discardableResult
    public func scheduleDailyReminder(hour: Int, minute: Int) async -> Bool { false }

    public func cancelDailyReminder() {}
}
#endif
