import SwiftData
import XCTest
@testable import ALIVE

final class FocusSessionTests: XCTestCase {
    func testCompletedTimerRemainsClaimableUntilRewardIsSaved() {
        let viewModel = FocusViewModel()

        viewModel.startSession()
        XCTAssertEqual(viewModel.status, .running)
        XCTAssertFalse(viewModel.isClaimable)

        viewModel.completeTimerSession()

        XCTAssertEqual(viewModel.status, .completed)
        XCTAssertEqual(viewModel.timeRemainingSeconds, 0)
        XCTAssertTrue(viewModel.isClaimable)
    }

    func testPausedTimerCannotClaimAFullSessionReward() {
        let viewModel = FocusViewModel()

        viewModel.startSession()
        viewModel.pauseSession()

        XCTAssertEqual(viewModel.status, .paused)
        XCTAssertFalse(viewModel.isClaimable)
    }

    func testFocusRewardClampsAnInvalidFocusScore() {
        XCTAssertEqual(FocusViewModel.xpAward(forMinutes: 25, focusScore: 100), 250)
        XCTAssertEqual(FocusViewModel.xpAward(forMinutes: 25, focusScore: 500), 250)
        XCTAssertEqual(FocusViewModel.xpAward(forMinutes: 25, focusScore: -20), 125)
    }

    func testClaimedSessionPersistsOneStreakAdjustedReward() throws {
        let context = try makeContext()
        let profile = UserProfile(username: "Hero", characterClass: .scholar, streakDays: 5)
        context.insert(profile)
        try context.save()

        let viewModel = FocusViewModel()
        viewModel.startSession()
        viewModel.completeTimerSession()

        let reward = try XCTUnwrap(viewModel.claimCompletedSession(profile: profile, context: context))
        let sessions = try context.fetch(FetchDescriptor<StudySession>())
        let transactions = try context.fetch(FetchDescriptor<XPTransaction>())

        XCTAssertEqual(reward.xpGained, 312)
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.xpEarned, 312)
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(transactions.first?.amount, 312)
        XCTAssertEqual(profile.totalXPEarned, 312)
        XCTAssertEqual(profile.focus, CharacterClass.scholar.baseStats.focus + 1)
        XCTAssertEqual(viewModel.status, .idle)
        XCTAssertNil(viewModel.claimCompletedSession(profile: profile, context: context))
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([UserProfile.self, Quest.self, StudySession.self, XPTransaction.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}
