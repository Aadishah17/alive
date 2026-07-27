import Foundation

public struct WeeklyStudyMetric: Identifiable, Equatable {
    public let date: Date
    public let label: String
    public let minutes: Int

    public var id: Date { date }
}

public final class AnalyticsViewModel {
    
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

    /// Returns the trailing seven calendar days, oldest first, so the chart is
    /// grounded in the player's actual focus sessions rather than fixture data.
    public func weeklyStudyMetrics(
        sessions: [StudySession],
        now: Date = Date(),
        calendar: Calendar = .autoupdatingCurrent
    ) -> [WeeklyStudyMetric] {
        let today = calendar.startOfDay(for: now)

        return (0..<7).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return nil
            }

            let minutes = sessions
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + ($1.durationSeconds / 60) }

            return WeeklyStudyMetric(
                date: date,
                label: date.formatted(.dateTime.weekday(.abbreviated)),
                minutes: minutes
            )
        }
    }
}
