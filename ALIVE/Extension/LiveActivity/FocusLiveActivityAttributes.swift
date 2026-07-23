import Foundation
import ActivityKit
import SwiftUI

public struct FocusLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var timeRemainingSeconds: Int
        public var focusScore: Int
        public var isPaused: Bool
        
        public init(timeRemainingSeconds: Int, focusScore: Int = 100, isPaused: Bool = false) {
            self.timeRemainingSeconds = timeRemainingSeconds
            self.focusScore = focusScore
            self.isPaused = isPaused
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
