import Foundation
import SwiftData

@Model
public final class Course {
    public var id: UUID
    public var courseCode: String
    public var courseName: String
    public var instructor: String
    public var minimumAttendancePercentage: Double // e.g. 75.0%
    public var totalClassesHeld: Int
    public var totalClassesAttended: Int
    public var colorHex: String
    
    public var currentAttendancePercentage: Double {
        guard totalClassesHeld > 0 else { return 100.0 }
        return (Double(totalClassesAttended) / Double(totalClassesHeld)) * 100.0
    }
    
    // Bunk Safety Logic: how many classes can student miss without dropping below threshold
    public var maxSafeBunksRemaining: Int {
        let reqFraction = minimumAttendancePercentage / 100.0
        // Attended / (Held + Bunks) >= reqFraction
        // Attended >= reqFraction * (Held + Bunks)
        // (Attended / reqFraction) - Held >= Bunks
        let maxTotalHeld = Double(totalClassesAttended) / reqFraction
        let possibleBunks = Int(floor(maxTotalHeld - Double(totalClassesHeld)))
        return max(0, possibleBunks)
    }
    
    // Classes needed to recover if below threshold
    public var classesNeededToRecover: Int {
        guard currentAttendancePercentage < minimumAttendancePercentage else { return 0 }
        let reqFraction = minimumAttendancePercentage / 100.0
        // (Attended + N) / (Held + N) >= reqFraction
        // Attended + N >= reqFraction * Held + reqFraction * N
        // N * (1 - reqFraction) >= reqFraction * Held - Attended
        // N >= (reqFraction * Held - Attended) / (1 - reqFraction)
        let numerator = (reqFraction * Double(totalClassesHeld)) - Double(totalClassesAttended)
        let denominator = 1.0 - reqFraction
        return Int(ceil(numerator / denominator))
    }
    
    public var isSafe: Bool {
        return currentAttendancePercentage >= minimumAttendancePercentage
    }
    
    public init(
        courseCode: String,
        courseName: String,
        instructor: String = "Prof. Unknown",
        minimumAttendancePercentage: Double = 75.0,
        totalClassesHeld: Int = 0,
        totalClassesAttended: Int = 0,
        colorHex: String = "#00F0FF"
    ) {
        self.id = UUID()
        self.courseCode = courseCode
        self.courseName = courseName
        self.instructor = instructor
        self.minimumAttendancePercentage = minimumAttendancePercentage
        self.totalClassesHeld = totalClassesHeld
        self.totalClassesAttended = totalClassesAttended
        self.colorHex = colorHex
    }
}
