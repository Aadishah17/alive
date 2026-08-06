import Foundation
import ActivityKit
import SwiftUI

/// Shared Live Activity attributes used by both the widget extension and the main
/// app's `FocusLiveActivityManager`. The canonical definition lives in
/// `ALIVE/Shared/FocusActivityAttributes.swift`; this file re-exports the same
/// type so the widget extension resolves it without importing the full app target.
///
/// NOTE: When building through XcodeGen the widget target pulls in
/// `ALIVE/Shared/FocusActivityAttributes.swift` directly instead of this file.
/// This stub exists only as a fallback for standalone SPM widget builds.
public struct FocusLiveActivityAttributes: ActivityAttributes {
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

    public var courseName: String
    public var totalDurationMinutes: Int
    public var xpRewardPotential: Int

    public init(courseName: String, totalDurationMinutes: Int, xpRewardPotential: Int) {
        self.courseName = courseName
        self.totalDurationMinutes = totalDurationMinutes
        self.xpRewardPotential = xpRewardPotential
    }
}
