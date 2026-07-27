import Foundation
import Observation

/// The small set of destinations ALIVE exposes both in-app and to system surfaces.
/// Keeping this surface intentionally narrow prevents shortcuts from becoming a mirror
/// of the entire navigation tree.
public enum ALIVEIntentRoute: String, CaseIterable, Codable, Sendable {
    case today
    case quests
    case focus
    case startFocus
    case academics
    case skills
    case badges

    var tab: ALIVETab {
        switch self {
        case .today:
            return .today
        case .quests:
            return .quests
        case .focus, .startFocus:
            return .focus
        case .academics:
            return .academics
        case .skills:
            return .skills
        case .badges:
            return .badges
        }
    }
}

public enum ALIVETab: String, CaseIterable, Hashable, Identifiable, Sendable {
    case today
    case quests
    case skills
    case academics
    case focus
    case badges

    public var id: Self { self }
}

/// Stores an intent route long enough for the foreground scene to consume it.
/// App Intents live in the app target today, so the standard defaults suite is the
/// correct shared handoff surface. Move this to an app-group suite if intents move
/// into an extension in the future.
public enum ALIVEIntentRouteStore {
    public static let didRequestRoute = Notification.Name("ALIVEIntentRouteStore.didRequestRoute")

    private static let pendingRouteKey = "alive.pendingIntentRoute"

    public static func request(_ route: ALIVEIntentRoute) {
        UserDefaults.standard.set(route.rawValue, forKey: pendingRouteKey)
        NotificationCenter.default.post(name: didRequestRoute, object: nil)
    }

    public static func takePendingRoute() -> ALIVEIntentRoute? {
        defer { UserDefaults.standard.removeObject(forKey: pendingRouteKey) }

        guard let rawValue = UserDefaults.standard.string(forKey: pendingRouteKey) else {
            return nil
        }

        return ALIVEIntentRoute(rawValue: rawValue)
    }
}

@MainActor
@Observable
public final class ALIVERouter {
    public var selectedTab: ALIVETab = .today
    public private(set) var focusStartRequestID: UUID?

    public init() {}

    public func route(to route: ALIVEIntentRoute) {
        selectedTab = route.tab

        if route == .startFocus {
            focusStartRequestID = UUID()
        }
    }

    public func consumePendingIntentRoute() {
        guard let pendingRoute = ALIVEIntentRouteStore.takePendingRoute() else {
            return
        }

        self.route(to: pendingRoute)
    }

    public func handle(url: URL) {
        guard url.scheme?.lowercased() == "alive" else {
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let routeValue = components?.queryItems?.first(where: { $0.name == "route" })?.value
            ?? url.host

        guard let routeValue, let pendingRoute = ALIVEIntentRoute(rawValue: routeValue) else {
            return
        }

        self.route(to: pendingRoute)
    }
}
