import Foundation
import SwiftData

public struct DailyQuestRefreshResult: Equatable, Sendable {
    public let didRefresh: Bool
    public let questCount: Int
    public let streakDays: Int

    public static let noChange = DailyQuestRefreshResult(didRefresh: false, questCount: 0, streakDays: 0)
}

/// Performs the once-per-calendar-day reset that makes ALIVE's quest board a
/// real daily loop instead of a static checklist. The service is intentionally
/// invoked from the app shell, not from a view body.
public enum DailyQuestService {
    @discardableResult
    public static func refreshIfNeeded(
        context: ModelContext,
        now: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent
    ) throws -> DailyQuestRefreshResult {
        let profiles = try context.fetch(FetchDescriptor<UserProfile>())
        guard let profile = profiles.first else {
            return .noChange
        }

        if let lastRefreshDate = profile.lastQuestRefreshDate,
           calendar.isDate(lastRefreshDate, inSameDayAs: now) {
            return DailyQuestRefreshResult(
                didRefresh: false,
                questCount: 0,
                streakDays: profile.streakDays
            )
        }

        let quests = try context.fetch(FetchDescriptor<Quest>())
        quests
            .filter { $0.category == .daily }
            .forEach(context.delete)

        let freshQuests = QuestEngine.defaultDailyQuests()
        freshQuests.forEach(context.insert)

        updateStreak(for: profile, now: now, calendar: calendar)
        profile.lastQuestRefreshDate = now

        try PersistenceService.save(context)
        WidgetSnapshotService.refresh(profile: profile, pendingQuestCount: freshQuests.count)

        return DailyQuestRefreshResult(
            didRefresh: true,
            questCount: freshQuests.count,
            streakDays: profile.streakDays
        )
    }

    private static func updateStreak(for profile: UserProfile, now: Date, calendar: Calendar) {
        let previousDay = calendar.startOfDay(for: profile.lastActiveDate)
        let currentDay = calendar.startOfDay(for: now)
        let elapsedDays = calendar.dateComponents([.day], from: previousDay, to: currentDay).day ?? 0

        switch elapsedDays {
        case ..<1:
            break
        case 1:
            profile.streakDays += 1
        default:
            profile.streakDays = 1
        }

        profile.lastActiveDate = now
    }
}
