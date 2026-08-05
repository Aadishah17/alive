import XCTest
@testable import ALIVE

final class FocusSessionViewModelTests: XCTestCase {

    func testTimerCompletionRequiresARunningSession() {
        let viewModel = FocusViewModel()

        XCTAssertFalse(viewModel.isReadyToClaimXP)

        viewModel.completeTimerSession()
        XCTAssertFalse(viewModel.isReadyToClaimXP)
        XCTAssertEqual(viewModel.status, .idle)
        XCTAssertEqual(viewModel.timeRemainingSeconds, viewModel.targetMinutes * 60)

        viewModel.startSession()
        viewModel.pauseSession()
        viewModel.completeTimerSession()
        XCTAssertEqual(viewModel.status, .paused)
        XCTAssertFalse(viewModel.isReadyToClaimXP)

        viewModel.startSession()
        viewModel.completeTimerSession()
        XCTAssertTrue(viewModel.isReadyToClaimXP)
        XCTAssertEqual(viewModel.timeRemainingSeconds, 0)

        viewModel.startSession()
        XCTAssertFalse(viewModel.isRunning)

        viewModel.resetSession()
        XCTAssertFalse(viewModel.isReadyToClaimXP)
        XCTAssertEqual(viewModel.timeRemainingSeconds, viewModel.targetMinutes * 60)
    }

    func testDurationCanOnlyChangeBeforeAFocusSessionStarts() {
        let viewModel = FocusViewModel()

        viewModel.setDuration(minutes: 45)
        XCTAssertEqual(viewModel.targetMinutes, 45)
        XCTAssertTrue(viewModel.canAdjustDuration)

        viewModel.startSession()
        viewModel.setDuration(minutes: 15)
        XCTAssertEqual(viewModel.targetMinutes, 45)
        XCTAssertFalse(viewModel.canAdjustDuration)

        viewModel.pauseSession()
        viewModel.setDuration(minutes: 15)
        XCTAssertEqual(viewModel.targetMinutes, 45)

        viewModel.resetSession()
        viewModel.setDuration(minutes: 15)
        XCTAssertEqual(viewModel.targetMinutes, 15)
    }
}
