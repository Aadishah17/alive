import Foundation
import XCTest

final class AttendanceCalculatorTests: XCTestCase {
    
    func testSafeBunkMarginCalculation() {
        // Attended 20 out of 20 classes (100%). Req threshold: 75%
        // Max total held = 20 / 0.75 = 26.66. Bunks = floor(26.66 - 20) = 6 bunks
        let course = Course(
            courseCode: "CS101",
            courseName: "Computer Science",
            minimumAttendancePercentage: 75.0,
            totalClassesHeld: 20,
            totalClassesAttended: 20
        )
        
        XCTAssertTrue(course.isSafe)
        XCTAssertEqual(course.currentAttendancePercentage, 100.0)
        XCTAssertEqual(course.maxSafeBunksRemaining, 6, "Student can safely miss 6 classes")
    }
    
    func testRecoveryClassesWhenBelowThreshold() {
        // Attended 10 out of 16 classes = 62.5%. Req threshold: 75%
        let course = Course(
            courseCode: "MATH201",
            courseName: "Calculus",
            minimumAttendancePercentage: 75.0,
            totalClassesHeld: 16,
            totalClassesAttended: 10
        )
        
        XCTAssertFalse(course.isSafe)
        XCTAssertEqual(course.currentAttendancePercentage, 62.5, accuracy: 0.1)
        XCTAssertGreaterThan(course.classesNeededToRecover, 0)
    }
}
