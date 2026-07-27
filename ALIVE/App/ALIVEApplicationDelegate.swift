#if os(iOS)
import UIKit
import UserNotifications

/// Bridges notification responses into the same router used by App Intents and
/// custom URLs. This keeps a reminder tap useful whether the app is warm, cold,
/// or already foregrounded.
final class ALIVEApplicationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        guard let rawRoute = userInfo["alive.route"] as? String,
              let route = ALIVEIntentRoute(rawValue: rawRoute) else {
            return
        }

        ALIVEIntentRouteStore.request(route)
    }
}
#endif
