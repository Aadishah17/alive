import Foundation
import XCTest
@testable import ALIVE

final class AnalyticsViewModelTests: XCTestCase {
    func testWeeklyStudyMetricsIncludesSevenDaysAndAggregatesMatchingSessions() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 7, day: 27, hour: 12))!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!

        let sessions = [
            StudySession(courseName: "Math", durationSeconds: 25 * 60, xpEarned: 50, date: now),
            StudySession(courseName: "Physics", durationSeconds: 35 * 60, xpEarned: 70, date: now),
            StudySession(courseName: "Writing", durationSeconds: 45 * 60, xpEarned: 90, date: twoDaysAgo)
        ]

        let metrics = AnalyticsViewModel().weeklyStudyMetrics(
            sessions: sessions,
            now: now,
            calendar: calendar
        )

        XCTAssertEqual(metrics.count, 7)
        XCTAssertEqual(metrics.suffix(1).first?.minutes, 60)
        XCTAssertEqual(metrics[4].minutes, 45)
        XCTAssertEqual(metrics.map(\.minutes).reduce(0, +), 105)
    }
}
