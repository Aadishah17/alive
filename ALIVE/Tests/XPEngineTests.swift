import Foundation
import XCTest

final class XPEngineTests: XCTestCase {
    
    func testRequiredXPForLevel1() {
        let xpLevel1 = XPEngine.requiredXP(forLevel: 1)
        XCTAssertEqual(xpLevel1, 100, "Level 1 required XP should be 100")
    }
    
    func testRequiredXPIncreasesMonotonically() {
        let level1 = XPEngine.requiredXP(forLevel: 1)
        let level2 = XPEngine.requiredXP(forLevel: 2)
        let level5 = XPEngine.requiredXP(forLevel: 5)
        
        XCTAssertGreaterThan(level2, level1)
        XCTAssertGreaterThan(level5, level2)
    }
    
    func testStreakMultiplierCap() {
        let mult1 = XPEngine.streakMultiplier(forStreak: 1)
        let mult5 = XPEngine.streakMultiplier(forStreak: 5)
        let mult20 = XPEngine.streakMultiplier(forStreak: 20)
        
        XCTAssertEqual(mult1, 1.05, accuracy: 0.001)
        XCTAssertEqual(mult5, 1.25, accuracy: 0.001)
        XCTAssertEqual(mult20, 1.50, accuracy: 0.001, "Streak multiplier capped at 1.50x (+50%)")
    }
    
    func testXPAddSingleLevelUp() {
        let profile = UserProfile(username: "TestHero", characterClass: .engineer, level: 1, currentXP: 0, streakDays: 1)
        let result = XPEngine.addXP(amount: 120, to: profile, source: "Unit Test")
        
        XCTAssertTrue(result.didLevelUp, "120 XP should trigger level up from Level 1 (requires 100 XP)")
        XCTAssertEqual(profile.level, 2)
        XCTAssertEqual(profile.unallocatedStatPoints, 2)
    }
}
