import SwiftUI
import SwiftData

public struct FocusSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var courses: [Course]
    @StateObject private var viewModel = FocusViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Course Selector Pill
                HStack {
                    Image(systemName: "book.fill")
                        .foregroundColor(ALIVEColor.neonCyan)
                    Picker("Select Course", selection: $viewModel.selectedCourseName) {
                        Text("General Study").tag("General Study")
                        ForEach(courses) { course in
                            Text("\(course.courseCode) - \(course.courseName)").tag(course.courseCode)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(ALIVEColor.textPrimary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ALIVEColor.glassSurface)
                .cornerRadius(20)
                
                // Focus Timer Ring
                ZStack {
                    Circle()
                        .stroke(Color(red: 0.88, green: 0.91, blue: 0.95), lineWidth: 16)
                        .frame(width: 240, height: 240)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.timeRemainingSeconds) / CGFloat(viewModel.targetMinutes * 60))
                        .stroke(
                            ALIVEColor.xpGradient,
                            style: StrokeStyle(lineWidth: 16, lineCap: .round)
                        )
                        .frame(width: 240, height: 240)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: ALIVEColor.neonCyan.opacity(0.3), radius: 8)
                    
                    VStack(spacing: 6) {
                        Text(formattedTime(seconds: viewModel.timeRemainingSeconds))
                            .font(.system(size: 44, weight: .black, design: .monospaced))
                            .foregroundColor(ALIVEColor.textPrimary)
                        
                        Text(viewModel.isRunning ? "FLOWSTATE ACTIVE" : "READY FOR BATTLE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ALIVEColor.rpgGold)
                    }
                }
                .padding(.vertical, 20)
                
                // Duration Selectors
                HStack(spacing: 12) {
                    DurationButton(mins: 15, isSelected: viewModel.targetMinutes == 15) { viewModel.setDuration(minutes: 15) }
                    DurationButton(mins: 25, isSelected: viewModel.targetMinutes == 25) { viewModel.setDuration(minutes: 25) }
                    DurationButton(mins: 45, isSelected: viewModel.targetMinutes == 45) { viewModel.setDuration(minutes: 45) }
                    DurationButton(mins: 60, isSelected: viewModel.targetMinutes == 60) { viewModel.setDuration(minutes: 60) }
                }
                
                // Controls
                HStack(spacing: 20) {
                    if viewModel.isReadyToClaimXP {
                        if let profile = profiles.first {
                            Button {
                                viewModel.saveCompletedSession(profile: profile, context: modelContext)
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("CLAIM XP")
                                        .fontWeight(.bold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ALIVEColor.goldGradient)
                                .foregroundColor(.black)
                                .cornerRadius(14)
                            }
                        }
                    } else if !viewModel.isRunning {
                        Button {
                            viewModel.startSession()
                        } label: {
                            HStack {
                                Image(systemName: viewModel.isPaused ? "play.fill" : "bolt.fill")
                                Text(viewModel.isPaused ? "RESUME FOCUS" : "ENGAGE FOCUS")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ALIVEColor.neonCyan)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                    } else {
                        Button {
                            viewModel.pauseSession()
                        } label: {
                            Text("PAUSE")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ALIVEColor.glassSurface)
                                .foregroundColor(ALIVEColor.textPrimary)
                                .cornerRadius(14)
                        }
                    }
                }
                .padding(.horizontal)

                if let error = viewModel.saveErrorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(ALIVEColor.healthRed)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
        }
        .navigationTitle("FOCUS TIMER")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func formattedTime(seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

struct DurationButton: View {
    let mins: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("\(mins)M")
                .font(.system(size: 12, weight: .bold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? ALIVEColor.xpViolet : ALIVEColor.glassSurface)
                .foregroundColor(isSelected ? .white : ALIVEColor.textSecondary)
                .cornerRadius(10)
        }
    }
}
