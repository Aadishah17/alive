#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import Foundation

/// Shared by the app and widget extension so a running focus session can render
/// consistently on the Lock Screen and Dynamic Island.
public struct FocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var courseName: String
        public var timeRemainingSeconds: Int
        public var endDate: Date?
        public var focusScore: Int
        public var isPaused: Bool
        public var isCompleted: Bool

        public init(
            courseName: String,
            timeRemainingSeconds: Int,
            endDate: Date? = nil,
            focusScore: Int = 100,
            isPaused: Bool = false,
            isCompleted: Bool = false
        ) {
            self.courseName = courseName
            self.timeRemainingSeconds = timeRemainingSeconds
            self.endDate = endDate
            self.focusScore = focusScore
            self.isPaused = isPaused
            self.isCompleted = isCompleted
        }
    }

    public var sessionName: String
    public var startedAt: Date
    public var targetMinutes: Int

    public init(sessionName: String, startedAt: Date = Date(), targetMinutes: Int) {
        self.sessionName = sessionName
        self.startedAt = startedAt
        self.targetMinutes = targetMinutes
    }
}
#endif
