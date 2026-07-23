import Foundation
import SwiftData

@Model
public final class StudySession {
    public var id: UUID
    public var courseName: String
    public var durationSeconds: Int
    public var xpEarned: Int
    public var date: Date
    public var focusScore: Int // 0 to 100
    public var isCompleted: Bool
    public var sessionType: String // "Pomodoro", "Deep Work", "Exam Prep"
    
    public var formattedDuration: String {
        let minutes = durationSeconds / 60
        let hours = minutes / 60
        if hours > 0 {
            return "\(hours)h \(minutes % 60)m"
        }
        return "\(minutes) mins"
    }
    
    public init(
        courseName: String,
        durationSeconds: Int,
        xpEarned: Int,
        focusScore: Int = 90,
        sessionType: String = "Deep Work",
        date: Date = Date()
    ) {
        self.id = UUID()
        self.courseName = courseName
        self.durationSeconds = durationSeconds
        self.xpEarned = xpEarned
        self.focusScore = focusScore
        self.sessionType = sessionType
        self.date = date
        self.isCompleted = true
    }
}
