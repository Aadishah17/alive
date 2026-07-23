import Foundation
import SwiftData

public final class MockDataGenerator {
    
    public static func seedInitialData(context: ModelContext) {
        // Fetch existing profile to prevent duplicate seed
        let descriptor = FetchDescriptor<UserProfile>()
        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return
        }
        
        // 1. User Profile
        let profile = UserProfile(
            username: "Alex Vance",
            characterClass: .engineer,
            level: 8,
            currentXP: 450,
            streakDays: 6,
            avatarIdentifier: "person.crop.square.fill.and.atmark"
        )
        profile.intelligence = 24
        profile.stamina = 18
        profile.focus = 28
        profile.discipline = 22
        profile.unallocatedStatPoints = 4
        context.insert(profile)
        
        // 2. Skill Tree Nodes
        let skills = [
            SkillNode(
                name: "Deep Concentration I",
                skillDescription: "Increases study focus score threshold and reduces fatigue.",
                category: "Focus",
                tier: 1,
                iconName: "brain.head.profile",
                xpCost: 200,
                buffDescription: "+10% Focus XP Gain",
                isUnlocked: true
            ),
            SkillNode(
                name: "Exam Clairvoyance",
                skillDescription: "Predicts high-priority revision topics based on course historical weight.",
                category: "Academia",
                tier: 1,
                iconName: "eye.fill",
                xpCost: 250,
                buffDescription: "Unlocks Advanced Study Analytics",
                isUnlocked: true
            ),
            SkillNode(
                name: "Master Bunk Calculator",
                skillDescription: "Allows exact safe bunk margin calculations with alert buffer.",
                category: "Time Magic",
                tier: 2,
                iconName: "calculator.fill",
                xpCost: 350,
                prerequisiteNodeNames: ["Exam Clairvoyance"],
                buffDescription: "+1 Bunk Shield per course",
                isUnlocked: true
            ),
            SkillNode(
                name: "Hyper-Focus Flowstate",
                skillDescription: "Double XP bonus during continuous 60-minute pomodoro sessions.",
                category: "Focus",
                tier: 2,
                iconName: "bolt.shield.fill",
                xpCost: 500,
                prerequisiteNodeNames: ["Deep Concentration I"],
                buffDescription: "2x XP on 60m+ Focus sessions",
                isUnlocked: false
            ),
            SkillNode(
                name: "Circadian Mastery",
                skillDescription: "Protects stamina stat from sleep schedule decay.",
                category: "Health",
                tier: 3,
                iconName: "moon.stars.fill",
                xpCost: 750,
                prerequisiteNodeNames: ["Hyper-Focus Flowstate"],
                buffDescription: "Stamina Protection & Sleep Insights",
                isUnlocked: false
            )
        ]
        skills.forEach { context.insert($0) }
        
        // 3. Courses & Attendance
        let courses = [
            Course(
                courseCode: "CS401",
                courseName: "Distributed Systems & Cloud",
                instructor: "Dr. Aris Thorne",
                minimumAttendancePercentage: 75.0,
                totalClassesHeld: 24,
                totalClassesAttended: 21,
                colorHex: "#00F0FF"
            ),
            Course(
                courseCode: "CS405",
                courseName: "Machine Learning Engineering",
                instructor: "Prof. Clara Wu",
                minimumAttendancePercentage: 75.0,
                totalClassesHeld: 20,
                totalClassesAttended: 19,
                colorHex: "#9D4EDD"
            ),
            Course(
                courseCode: "MATH302",
                courseName: "Stochastic Processes",
                instructor: "Dr. Marcus Vance",
                minimumAttendancePercentage: 80.0,
                totalClassesHeld: 18,
                totalClassesAttended: 13, // 72.2% - dangerous!
                colorHex: "#FF2D55"
            ),
            Course(
                courseCode: "ENG210",
                courseName: "Technical Communication",
                instructor: "Prof. Sarah Jenkins",
                minimumAttendancePercentage: 75.0,
                totalClassesHeld: 16,
                totalClassesAttended: 15,
                colorHex: "#FFD700"
            )
        ]
        courses.forEach { context.insert($0) }
        
        // 4. Daily & Weekly Quests
        let dailyQuests = QuestEngine.defaultDailyQuests()
        let weeklyQuests = QuestEngine.defaultWeeklyQuests()
        dailyQuests[0].currentProgress = 1
        dailyQuests[0].isCompleted = true
        dailyQuests[0].completionDate = Date()
        
        (dailyQuests + weeklyQuests).forEach { context.insert($0) }
        
        // 5. Past Study Sessions
        let sessions = [
            StudySession(courseName: "Distributed Systems", durationSeconds: 3600, xpEarned: 180, focusScore: 94, sessionType: "Deep Work", date: Date().addingTimeInterval(-86400 * 2)),
            StudySession(courseName: "Machine Learning", durationSeconds: 2700, xpEarned: 135, focusScore: 88, sessionType: "Pomodoro", date: Date().addingTimeInterval(-86400)),
            StudySession(courseName: "Stochastic Processes", durationSeconds: 5400, xpEarned: 300, focusScore: 96, sessionType: "Exam Prep", date: Date())
        ]
        sessions.forEach { context.insert($0) }
        
        // 6. Achievements / Badges
        let achievements = [
            Achievement(title: "First Blood", achievementDescription: "Complete your first study focus session.", badgeIcon: "flame.fill", rarity: .common, isUnlocked: true),
            Achievement(title: "Scholar Sentinel", achievementDescription: "Maintain a 5-day study streak.", badgeIcon: "shield.fill", rarity: .rare, isUnlocked: true),
            Achievement(title: "Bunk Tactician", achievementDescription: "Calculate safe bunks without dropping below 75%.", badgeIcon: "target", rarity: .epic, isUnlocked: true),
            Achievement(title: "Grand Archmage", achievementDescription: "Reach Level 10 in any character class.", badgeIcon: "crown.fill", rarity: .legendary, isUnlocked: false)
        ]
        achievements.forEach { context.insert($0) }
        
        try? context.save()
    }
}
