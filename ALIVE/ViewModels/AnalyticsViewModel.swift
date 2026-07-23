import SwiftUI
import SwiftData
import Combine

public final class AnalyticsViewModel: ObservableObject {
    
    public init() {}
    
    public func totalStudyHours(sessions: [StudySession]) -> Double {
        let totalSec = sessions.reduce(0) { $0 + $1.durationSeconds }
        return Double(totalSec) / 3600.0
    }
    
    public func averageFocusScore(sessions: [StudySession]) -> Double {
        guard !sessions.isEmpty else { return 0 }
        let totalScore = sessions.reduce(0) { $0 + $1.focusScore }
        return Double(totalScore) / Double(sessions.count)
    }
    
    public func overallAttendanceHealth(courses: [Course]) -> Double {
        guard !courses.isEmpty else { return 100.0 }
        let totalPct = courses.reduce(0.0) { $0 + $1.currentAttendancePercentage }
        return totalPct / Double(courses.count)
    }
    
    public func isBurnoutRiskHigh(sessions: [StudySession], courses: [Course]) -> Bool {
        let hours = totalStudyHours(sessions: sessions)
        let lowAttendanceCount = courses.filter { !$0.isSafe }.count
        return hours > 25.0 && lowAttendanceCount > 1
    }
}
