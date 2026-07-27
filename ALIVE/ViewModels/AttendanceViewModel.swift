import SwiftUI
import SwiftData
import Combine

public final class AttendanceViewModel: ObservableObject {
    @Published public var showAddCourseSheet: Bool = false
    @Published public var newCourseCode: String = ""
    @Published public var newCourseName: String = ""
    @Published public var newInstructor: String = ""
    @Published public var newMinPercentage: Double = 75.0
    @Published public var saveErrorMessage: String?
    
    public init() {}
    
    public func logAttendance(course: Course, attended: Bool, profile: UserProfile, context: ModelContext) {
        course.totalClassesHeld += 1
        if attended {
            course.totalClassesAttended += 1
            // Award Discipline XP for attending class
            _ = XPEngine.addXP(amount: 40, to: profile, source: "Attended \(course.courseCode)", context: context)
        } else {
            HapticManager.shared.triggerImpact(style: .heavy)
        }
        
        do {
            try PersistenceService.save(context)
            let pendingQuestCount = (try? context.fetch(FetchDescriptor<Quest>()))?
                .filter { !$0.isCompleted }
                .count ?? 0
            WidgetSnapshotService.refresh(profile: profile, pendingQuestCount: pendingQuestCount)
        } catch {
            saveErrorMessage = "Attendance could not be saved. Please try again."
        }
    }
    
    public func addCourse(context: ModelContext) {
        guard !newCourseCode.isEmpty && !newCourseName.isEmpty else { return }
        
        let course = Course(
            courseCode: newCourseCode.uppercased(),
            courseName: newCourseName,
            instructor: newInstructor.isEmpty ? "Prof. Unknown" : newInstructor,
            minimumAttendancePercentage: newMinPercentage
        )
        
        context.insert(course)

        do {
            try PersistenceService.save(context)
            newCourseCode = ""
            newCourseName = ""
            newInstructor = ""
            showAddCourseSheet = false
        } catch {
            saveErrorMessage = "Course could not be registered. Please try again."
        }
    }
}
