import Foundation
import XCTest
@testable import ALIVE

final class QuestEngineTests: XCTestCase {
    
    func testDefaultDailyQuestsGenerated() {
        let dailies = QuestEngine.defaultDailyQuests()
        XCTAssertEqual(dailies.count, 4)
        XCTAssertTrue(dailies.allSatisfy { $0.category == .daily })
        XCTAssertFalse(dailies.contains { $0.isCompleted })
    }
    
    func testWeeklyQuestsGenerated() {
        let weeklies = QuestEngine.defaultWeeklyQuests()
        XCTAssertGreaterThan(weeklies.count, 0)
        XCTAssertTrue(weeklies.allSatisfy { $0.category == .weekly })
    }
}
