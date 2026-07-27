import XCTest
@testable import ALIVE

@MainActor
final class ALIVERouterTests: XCTestCase {
    override func tearDown() {
        _ = ALIVEIntentRouteStore.takePendingRoute()
        super.tearDown()
    }

    func testStartFocusRouteSelectsFocusAndCreatesARequestToken() {
        let router = ALIVERouter()

        router.route(to: .startFocus)

        XCTAssertEqual(router.selectedTab, .focus)
        XCTAssertNotNil(router.focusStartRequestID)
    }

    func testCustomURLRoutesToQuestBoard() {
        let router = ALIVERouter()

        router.handle(url: URL(string: "alive://open?route=quests")!)

        XCTAssertEqual(router.selectedTab, .quests)
    }

    func testPendingIntentRouteIsConsumedOnce() {
        let router = ALIVERouter()
        ALIVEIntentRouteStore.request(.academics)

        router.consumePendingIntentRoute()

        XCTAssertEqual(router.selectedTab, .academics)
        XCTAssertNil(ALIVEIntentRouteStore.takePendingRoute())
    }
}
