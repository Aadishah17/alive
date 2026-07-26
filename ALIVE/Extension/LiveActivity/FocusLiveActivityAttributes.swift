import Foundation
import ActivityKit
import SwiftUI

public struct FocusLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var timeRemainingSeconds: Int
        public var focusScore: Int
        public var isPaused: Bool
        public var endDate: Date?
        
        public init(
            timeRemainingSeconds: Int,
            focusScore: Int = 100,
            isPaused: Bool = false,
            endDate: Date? = nil
        ) {
            self.timeRemainingSeconds = timeRemainingSeconds
            self.focusScore = focusScore
            self.isPaused = isPaused
            self.endDate = endDate
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
