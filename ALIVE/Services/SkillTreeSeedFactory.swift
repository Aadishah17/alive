import Foundation

/// Canonical first-pass progression tree shared by demo mode and real onboarding.
public enum SkillTreeSeedFactory {
    public static func defaultNodes() -> [SkillNode] {
        [
            SkillNode(
                name: "Deep Concentration I",
                skillDescription: "Increases study focus score threshold and reduces fatigue.",
                category: "Focus",
                tier: 1,
                iconName: "brain.head.profile",
                xpCost: 200,
                buffDescription: "+10% Focus XP Gain",
                isUnlocked: false
            ),
            SkillNode(
                name: "Exam Clairvoyance",
                skillDescription: "Reveals a seven-day study distribution in your insights dashboard.",
                category: "Academia",
                tier: 1,
                iconName: "eye.fill",
                xpCost: 250,
                buffDescription: "Unlocks seven-day study distribution insights",
                isUnlocked: false
            ),
            SkillNode(
                name: "Master Bunk Calculator",
                skillDescription: "Marks an attendance-planning milestone for students who actively manage thresholds.",
                category: "Time Magic",
                tier: 2,
                iconName: "calculator.fill",
                xpCost: 350,
                prerequisiteNodeNames: ["Exam Clairvoyance"],
                buffDescription: "Attendance strategist milestone"
            ),
            SkillNode(
                name: "Hyper-Focus Flowstate",
                skillDescription: "Boosts rewards for sustained 60-minute focus sessions.",
                category: "Focus",
                tier: 2,
                iconName: "bolt.shield.fill",
                xpCost: 500,
                prerequisiteNodeNames: ["Deep Concentration I"],
                buffDescription: "2x XP on 60m+ Focus sessions"
            ),
            SkillNode(
                name: "Circadian Mastery",
                skillDescription: "Unlocks a dedicated recovery ritual to support sustainable study habits.",
                category: "Health",
                tier: 3,
                iconName: "moon.stars.fill",
                xpCost: 750,
                prerequisiteNodeNames: ["Hyper-Focus Flowstate"],
                buffDescription: "Unlocks the recovery ritual"
            )
        ]
    }
}
