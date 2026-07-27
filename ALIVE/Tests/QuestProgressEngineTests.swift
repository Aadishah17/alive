import SwiftData
import XCTest
@testable import ALIVE

final class QuestProgressEngineTests: XCTestCase {
    func testCompletionPersistsQuestXPAndStatOnlyOnce() throws {
        let context = try makeContext()
        let profile = UserProfile(username: "Hero", characterClass: .engineer, streakDays: 1)
        let quest = Quest(
            title: "Finish lab notes",
            questDescription: "Write the conclusions.",
            difficulty: .medium,
            statTypeReward: "Focus"
        )
        context.insert(profile)
        context.insert(quest)
        try context.save()

        let outcome = try XCTUnwrap(
            QuestProgressEngine.complete(quest: quest, profile: profile, context: context)
        )
        let transactions = try context.fetch(FetchDescriptor<XPTransaction>())

        XCTAssertTrue(quest.isCompleted)
        XCTAssertEqual(quest.currentProgress, quest.targetProgress)
        XCTAssertEqual(outcome.xpGained, 126)
        XCTAssertEqual(profile.totalXPEarned, 126)
        XCTAssertEqual(profile.focus, CharacterClass.engineer.baseStats.focus + 1)
        XCTAssertEqual(transactions.count, 1)
        XCTAssertNil(try QuestProgressEngine.complete(quest: quest, profile: profile, context: context))
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([UserProfile.self, Quest.self, XPTransaction.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}
