import SwiftUI
import SwiftData

public struct AttendanceTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @Query private var profiles: [UserProfile]
    @StateObject private var viewModel = AttendanceViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header summary
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ACADEMIC BUNK FORTRESS")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(ALIVEColor.neonCyan)
                        
                        Text("Track attendance and calculate safe bunks before thresholds drop.")
                            .font(.caption)
                            .foregroundColor(ALIVEColor.textSecondary)
                    }
                    Spacer()
                    
                    Button {
                        viewModel.showAddCourseSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(ALIVEColor.rpgGold)
                    }
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if courses.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "book.closed.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(ALIVEColor.textMuted)
                                Text("No registered courses. Tap '+' to add your subjects.")
                                    .font(.subheadline)
                                    .foregroundColor(ALIVEColor.textSecondary)
                            }
                            .padding(.top, 40)
                        } else {
                            if let profile = profiles.first {
                                ForEach(courses) { course in
                                    CourseAttendanceCard(course: course, profile: profile)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddCourseSheet) {
            AddCourseSheetView(viewModel: viewModel)
        }
        .alert(
            "Couldn’t save your update",
            isPresented: Binding(
                get: { viewModel.saveErrorMessage != nil },
                set: { if !$0 { viewModel.saveErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.saveErrorMessage = nil
            }
        } message: {
            Text(viewModel.saveErrorMessage ?? "Please try again.")
        }
        .navigationTitle("ATTENDANCE ENGINE")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct CourseAttendanceCard: View {
    @Environment(\.modelContext) private var modelContext
    let course: Course
    let profile: UserProfile
    @StateObject private var viewModel = AttendanceViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(course.courseCode)
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundColor(ALIVEColor.neonCyan)
                    
                    Text(course.courseName)
                        .font(.subheadline)
                        .foregroundColor(ALIVEColor.textPrimary)
                }
                
                Spacer()
                
                // Attendance Percentage Badge
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.1f", course.currentAttendancePercentage))%")
                        .font(.title3)
                        .fontWeight(.black)
                        .foregroundColor(course.isSafe ? ALIVEColor.staminaGreen : ALIVEColor.healthRed)
                    
                    Text("REQ: \(Int(course.minimumAttendancePercentage))%")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(ALIVEColor.textMuted)
                }
            }
            
            // Bunk Margin Indicator Banner
            HStack {
                if course.isSafe {
                    Image(systemName: "shield.checkmark.fill")
                        .foregroundColor(ALIVEColor.staminaGreen)
                    Text("SAFE BUNK MARGIN: **\(course.maxSafeBunksRemaining)** class(es) remaining")
                        .font(.caption)
                        .foregroundColor(ALIVEColor.textPrimary)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(ALIVEColor.healthRed)
                    Text("DANGER! Must attend next **\(course.classesNeededToRecover)** class(es)")
                        .font(.caption)
                        .foregroundColor(ALIVEColor.healthRed)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(course.isSafe ? ALIVEColor.staminaGreen.opacity(0.12) : ALIVEColor.healthRed.opacity(0.15))
            .cornerRadius(8)
            
            // Quick 1-Tap Log Buttons
            HStack(spacing: 12) {
                Button {
                    viewModel.logAttendance(course: course, attended: true, profile: profile, context: modelContext)
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("ATTENDED (+40 XP)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(ALIVEColor.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button {
                    viewModel.logAttendance(course: course, attended: false, profile: profile, context: modelContext)
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                        Text("BUNKED CLASS")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(ALIVEColor.glassSurface)
                    .foregroundColor(ALIVEColor.healthRed)
                    .cornerRadius(8)
                }
            }
        }
        .glassCard(borderColor: course.isSafe ? ALIVEColor.neonCyan.opacity(0.2) : ALIVEColor.healthRed)
    }
}

struct AddCourseSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: AttendanceViewModel
    
    var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("ADD NEW COURSE")
                    .font(.headline)
                    .foregroundColor(ALIVEColor.rpgGold)
                
                TextField("Course Code (e.g. CS401)", text: $viewModel.newCourseCode)
                    .padding()
                    .background(ALIVEColor.cardBackground)
                    .cornerRadius(10)
                    .foregroundColor(ALIVEColor.textPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(ALIVEColor.glassSurface, lineWidth: 1)
                    )
                
                TextField("Course Full Name", text: $viewModel.newCourseName)
                    .padding()
                    .background(ALIVEColor.cardBackground)
                    .cornerRadius(10)
                    .foregroundColor(ALIVEColor.textPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(ALIVEColor.glassSurface, lineWidth: 1)
                    )
                
                TextField("Instructor Name", text: $viewModel.newInstructor)
                    .padding()
                    .background(ALIVEColor.cardBackground)
                    .cornerRadius(10)
                    .foregroundColor(ALIVEColor.textPrimary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(ALIVEColor.glassSurface, lineWidth: 1)
                    )
                
                VStack(alignment: .leading) {
                    Text("Minimum Attendance Required: \(Int(viewModel.newMinPercentage))%")
                        .font(.caption)
                        .foregroundColor(ALIVEColor.textSecondary)
                    
                    Slider(value: $viewModel.newMinPercentage, in: 50...90, step: 5)
                        .tint(ALIVEColor.neonCyan)
                }
                
                Button {
                    viewModel.addCourse(context: modelContext)
                } label: {
                    Text("REGISTER COURSE")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ALIVEColor.goldGradient)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
