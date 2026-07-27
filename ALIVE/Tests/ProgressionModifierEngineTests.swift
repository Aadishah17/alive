import XCTest
@testable import ALIVE

final class ProgressionModifierEngineTests: XCTestCase {
    func testFocusPerksStackForASixtyMinuteSession() {
        let deepConcentration = makeSkill(
            name: ProgressionModifierEngine.deepConcentration,
            isUnlocked: true
        )
        let hyperFocus = makeSkill(
            name: ProgressionModifierEngine.hyperFocus,
            isUnlocked: true
        )

        let multiplier = ProgressionModifierEngine.focusRewardMultiplier(
            forMinutes: 60,
            skills: [deepConcentration, hyperFocus]
        )

        XCTAssertEqual(multiplier, 2.2, accuracy: 0.001)
        XCTAssertEqual(
            ProgressionModifierEngine.modifiedFocusBaseXP(
                baseXP: 600,
                minutes: 60,
                skills: [deepConcentration, hyperFocus]
            ),
            1_320
        )
    }

    func testHyperFocusDoesNotApplyBeforeSixtyMinutes() {
        let hyperFocus = makeSkill(
            name: ProgressionModifierEngine.hyperFocus,
            isUnlocked: true
        )

        XCTAssertEqual(
            ProgressionModifierEngine.focusRewardMultiplier(forMinutes: 45, skills: [hyperFocus]),
            1
        )
    }

    private func makeSkill(name: String, isUnlocked: Bool) -> SkillNode {
        SkillNode(
            name: name,
            skillDescription: "Test skill",
            category: "Focus",
            tier: 1,
            iconName: "sparkles",
            xpCost: 0,
            buffDescription: "Test benefit",
            isUnlocked: isUnlocked
        )
    }
}
