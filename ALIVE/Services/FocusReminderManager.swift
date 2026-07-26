import UserNotifications

@MainActor
public final class FocusReminderManager {
    public static let shared = FocusReminderManager()

    private let requestIdentifier = "alive.focus.complete"

    private init() {}

    public func scheduleCompletion(after seconds: Int, courseName: String) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }
        case .authorized, .provisional, .ephemeral:
            break
        case .denied:
            return
        @unknown default:
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Focus session complete"
        content.body = "\(courseName) is ready for your XP claim."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(max(1, seconds)),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: requestIdentifier,
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    public func cancelCompletionReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [requestIdentifier]
        )
    }
}
