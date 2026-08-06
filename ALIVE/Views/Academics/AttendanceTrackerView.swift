import SwiftUI
import SwiftData

public struct AttendanceTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]
    @Query private var profiles: [UserProfile]
    @StateObject private var viewModel = AttendanceViewModel()
    @State private var appeared = false
    
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
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : -10)
                
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
                                ForEach(Array(courses.enumerated()), id: \.element.id) { index, course in
                                    CourseAttendanceCard(course: course, profile: profile)
                                        .opacity(appeared ? 1 : 0)
                                        .offset(y: appeared ? 0 : 20)
                                        .animation(
                                            .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1),
                                            value: appeared
                                        )
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
            "Couldn't save your update",
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
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }
}

struct CourseAttendanceCard: View {
    @Environment(\.modelContext) private var modelContext
    let course: Course
    let profile: UserProfile
    @StateObject private var viewModel = AttendanceViewModel()
    @State private var dangerPulse = false
    
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
                
                // Circular Attendance Gauge
                ZStack {
                    Circle()
                        .stroke(ALIVEColor.glassSurface, lineWidth: 6)
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .trim(from: 0, to: min(course.currentAttendancePercentage / 100, 1))
                        .stroke(
                            course.isSafe ? ALIVEColor.staminaGreen : ALIVEColor.healthRed,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: course.currentAttendancePercentage)
                    
                    VStack(spacing: 0) {
                        Text("\(String(format: "%.0f", course.currentAttendancePercentage))")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundColor(course.isSafe ? ALIVEColor.staminaGreen : ALIVEColor.healthRed)
                        Text("%")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(ALIVEColor.textMuted)
                    }
                }
                .shadow(
                    color: !course.isSafe ? ALIVEColor.healthRed.opacity(dangerPulse ? 0.4 : 0.1) : .clear,
                    radius: dangerPulse ? 8 : 2
                )
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
                        .scaleEffect(dangerPulse ? 1.2 : 1.0)
                    Text("DANGER! Must attend next **\(course.classesNeededToRecover)** class(es)")
                        .font(.caption)
                        .foregroundColor(ALIVEColor.healthRed)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(course.isSafe ? ALIVEColor.staminaGreen.opacity(0.12) : ALIVEColor.healthRed.opacity(0.15))
            .cornerRadius(8)
            
            // Requirement label
            Text("REQ: \(Int(course.minimumAttendancePercentage))%")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(ALIVEColor.textMuted)
            
            // Quick 1-Tap Log Buttons
            HStack(spacing: 12) {
                Button {
                    viewModel.logAttendance(course: course, attended: true, profile: profile, context: modelContext)
                    HapticManager.shared.triggerImpact(style: .medium)
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
                    HapticManager.shared.triggerImpact(style: .light)
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
        .onAppear {
            if !course.isSafe {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    dangerPulse = true
                }
            }
        }
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
