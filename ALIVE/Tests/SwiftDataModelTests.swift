import Foundation
import XCTest

final class SwiftDataModelTests: XCTestCase {
    
    func testCharacterClassBaseStats() {
        let scholar = CharacterClass.scholar
        XCTAssertEqual(scholar.baseStats.intelligence, 18)
        
        let engineer = CharacterClass.engineer
        XCTAssertEqual(engineer.baseStats.focus, 18)
    }
    
    func testUserProfileInitialization() {
        let profile = UserProfile(username: "Aria", characterClass: .scholar)
        XCTAssertEqual(profile.username, "Aria")
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.currentXP, 0)
        XCTAssertEqual(profile.intelligence, 18)
        XCTAssertEqual(profile.stamina, 12)
    }
}
