import Foundation

/// A compact, Codable handoff model for WidgetKit. It intentionally contains no
/// SwiftData object references so widgets never need to open the app database.
public struct ALIVEWidgetSnapshot: Codable, Equatable, Sendable {
    public let heroName: String
    public let level: Int
    public let currentXP: Int
    public let requiredXP: Int
    public let streakDays: Int
    public let pendingQuestCount: Int
    public let updatedAt: Date

    public init(
        heroName: String,
        level: Int,
        currentXP: Int,
        requiredXP: Int,
        streakDays: Int,
        pendingQuestCount: Int,
        updatedAt: Date = Date()
    ) {
        self.heroName = heroName
        self.level = level
        self.currentXP = currentXP
        self.requiredXP = requiredXP
        self.streakDays = streakDays
        self.pendingQuestCount = pendingQuestCount
        self.updatedAt = updatedAt
    }

    public static let placeholder = ALIVEWidgetSnapshot(
        heroName: "Hero",
        level: 1,
        currentXP: 0,
        requiredXP: 100,
        streakDays: 1,
        pendingQuestCount: 3
    )
}

public enum ALIVEWidgetSnapshotStore {
    public static let appGroupIdentifier = "group.com.alive.app"

    private static let snapshotKey = "alive.widgetSnapshot"

    public static func load() -> ALIVEWidgetSnapshot {
        guard
            let data = defaults.data(forKey: snapshotKey),
            let snapshot = try? JSONDecoder().decode(ALIVEWidgetSnapshot.self, from: data)
        else {
            return .placeholder
        }

        return snapshot
    }

    public static func save(_ snapshot: ALIVEWidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        defaults.set(data, forKey: snapshotKey)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }
}
