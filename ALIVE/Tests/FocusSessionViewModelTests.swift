import XCTest
@testable import ALIVE

final class FocusSessionViewModelTests: XCTestCase {

    func testXPCanOnlyBeClaimedAfterTimerCompletes() {
        let viewModel = FocusViewModel()

        XCTAssertFalse(viewModel.isReadyToClaimXP)

        viewModel.completeTimerSession()
        XCTAssertTrue(viewModel.isReadyToClaimXP)
        XCTAssertEqual(viewModel.timeRemainingSeconds, 0)

        viewModel.startSession()
        XCTAssertFalse(viewModel.isRunning)

        viewModel.resetSession()
        XCTAssertFalse(viewModel.isReadyToClaimXP)
        XCTAssertEqual(viewModel.timeRemainingSeconds, viewModel.targetMinutes * 60)
    }
}
