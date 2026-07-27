import SwiftData
import XCTest
@testable import ALIVE

final class DailyQuestServiceTests: XCTestCase {
    func testRefreshReplacesOldDailiesAndAdvancesNextDayStreak() throws {
        let context = try makeContext()
        let calendar = Calendar(identifier: .gregorian)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let profile = UserProfile(username: "Hero", characterClass: .scholar, streakDays: 4)
        profile.lastActiveDate = yesterday
        profile.lastQuestRefreshDate = yesterday
        context.insert(profile)
        context.insert(Quest(title: "Old daily", questDescription: "Old", category: .daily))
        context.insert(Quest(title: "Keep weekly", questDescription: "Keep", category: .weekly))
        try context.save()

        let result = try DailyQuestService.refreshIfNeeded(context: context, now: Date(), calendar: calendar)
        let quests = try context.fetch(FetchDescriptor<Quest>())

        XCTAssertTrue(result.didRefresh)
        XCTAssertEqual(result.questCount, 4)
        XCTAssertEqual(profile.streakDays, 5)
        XCTAssertEqual(quests.filter { $0.category == .daily }.count, 4)
        XCTAssertEqual(quests.filter { $0.category == .weekly }.count, 1)
    }

    func testRefreshDoesNotDuplicateDailiesOnTheSameDay() throws {
        let context = try makeContext()
        let profile = UserProfile(username: "Hero", characterClass: .scholar)
        profile.lastQuestRefreshDate = Date()
        context.insert(profile)
        context.insert(Quest(title: "Today", questDescription: "Today", category: .daily))
        try context.save()

        let result = try DailyQuestService.refreshIfNeeded(context: context, now: Date())
        let quests = try context.fetch(FetchDescriptor<Quest>())

        XCTAssertFalse(result.didRefresh)
        XCTAssertEqual(quests.filter { $0.category == .daily }.count, 1)
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([UserProfile.self, Quest.self, XPTransaction.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}
