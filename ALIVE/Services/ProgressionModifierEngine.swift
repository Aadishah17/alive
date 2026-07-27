import Foundation

/// Named progression milestones keep gameplay effects decoupled from view copy.
/// Skill nodes stay user-editable while the reward engine only depends on their
/// stable, seeded names.
public enum ProgressionModifierEngine {
    public static let deepConcentration = "Deep Concentration I"
    public static let examClairvoyance = "Exam Clairvoyance"
    public static let hyperFocus = "Hyper-Focus Flowstate"
    public static let circadianMastery = "Circadian Mastery"

    public static func isUnlocked(_ skillName: String, in skills: [SkillNode]) -> Bool {
        skills.contains { $0.name == skillName && $0.isUnlocked }
    }

    public static func focusRewardMultiplier(forMinutes minutes: Int, skills: [SkillNode]) -> Double {
        var multiplier = 1.0

        if isUnlocked(deepConcentration, in: skills) {
            multiplier *= 1.10
        }
        if minutes >= 60, isUnlocked(hyperFocus, in: skills) {
            multiplier *= 2.0
        }

        return multiplier
    }

    public static func modifiedFocusBaseXP(
        baseXP: Int,
        minutes: Int,
        skills: [SkillNode]
    ) -> Int {
        Int(Double(max(0, baseXP)) * focusRewardMultiplier(forMinutes: minutes, skills: skills))
    }

    public static func focusPerkSummary(forMinutes minutes: Int, skills: [SkillNode]) -> String? {
        let multiplier = focusRewardMultiplier(forMinutes: minutes, skills: skills)
        guard multiplier > 1 else {
            return nil
        }

        return String(format: "Active focus perks: %.1fx base XP", multiplier)
    }
}
