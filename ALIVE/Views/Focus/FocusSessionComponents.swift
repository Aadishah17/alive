import SwiftUI

struct FocusCoursePicker: View {
    @Binding var selectedCourseName: String
    let courses: [Course]

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "book.closed.fill")
                .foregroundStyle(ALIVEColor.neonCyan)

            Picker("Course", selection: $selectedCourseName) {
                Text("General Study").tag("General Study")
                ForEach(courses) { course in
                    Text("\(course.courseCode) · \(course.courseName)")
                        .tag(course.courseCode)
                }
            }
            .pickerStyle(.menu)
            .tint(ALIVEColor.textPrimary)
            .accessibilityIdentifier("focus.coursePicker")
        }
        .glassCard(cornerRadius: 22, borderColor: ALIVEColor.neonCyan.opacity(0.22))
    }
}

struct FocusTimerRing: View {
    let timeRemainingSeconds: Int
    let targetMinutes: Int
    let status: FocusSessionStatus
    @State private var breathePulse = false
    @State private var completionGlow = false

    private var progress: Double {
        let totalSeconds = max(1, targetMinutes * 60)
        return 1 - (Double(timeRemainingSeconds) / Double(totalSeconds))
    }

    private var statusLabel: String {
        switch status {
        case .idle:
            return "READY FOR DEEP WORK"
        case .running:
            return "FLOWSTATE ACTIVE"
        case .paused:
            return "SESSION PAUSED"
        case .completed:
            return "SESSION COMPLETE"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .idle: return ALIVEColor.rpgGold
        case .running: return ALIVEColor.neonCyan
        case .paused: return ALIVEColor.rpgGold
        case .completed: return ALIVEColor.staminaGreen
        }
    }

    var body: some View {
        ZStack {
            // Outer glow ring for active/completed states
            Circle()
                .stroke(statusColor.opacity(status == .running ? (breathePulse ? 0.2 : 0.05) : (status == .completed ? (completionGlow ? 0.4 : 0.1) : 0)), lineWidth: 28)
                .frame(width: 268, height: 268)
                .blur(radius: 8)
            
            // Background track
            Circle()
                .stroke(ALIVEColor.glassSurface, lineWidth: 18)

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    status == .completed
                        ? LinearGradient(colors: [ALIVEColor.staminaGreen, ALIVEColor.neonCyan], startPoint: .leading, endPoint: .trailing)
                        : ALIVEColor.xpGradient,
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.smooth, value: progress)
            
            // Tick marks on the ring
            ForEach(0..<12, id: \.self) { i in
                Rectangle()
                    .fill(ALIVEColor.textMuted.opacity(0.15))
                    .frame(width: 1, height: 8)
                    .offset(y: -120)
                    .rotationEffect(.degrees(Double(i) * 30))
            }

            VStack(spacing: 8) {
                Text(Self.formattedTime(timeRemainingSeconds))
                    .font(.system(size: 46, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(ALIVEColor.textPrimary)
                    .scaleEffect(status == .completed ? (completionGlow ? 1.05 : 1.0) : 1.0)

                Text(statusLabel)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(statusColor)
                
                if status == .completed {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(ALIVEColor.staminaGreen)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: 252, height: 252)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Focus timer, \(Self.formattedTime(timeRemainingSeconds)) remaining, \(statusLabel.lowercased())")
        .onChange(of: status) { _, newStatus in
            if newStatus == .running {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    breathePulse = true
                }
            } else {
                breathePulse = false
            }
            if newStatus == .completed {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    completionGlow = true
                }
            } else {
                completionGlow = false
            }
        }
    }

    private static func formattedTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}

struct FocusDurationPicker: View {
    let selectedMinutes: Int
    let isEnabled: Bool
    let selectDuration: (Int) -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach([15, 25, 45, 60], id: \.self) { minutes in
                Button("\(minutes)m") {
                    selectDuration(minutes)
                }
                .buttonStyle(FocusDurationButtonStyle(isSelected: selectedMinutes == minutes))
                .disabled(!isEnabled)
                .accessibilityIdentifier("focus.duration.\(minutes)")
            }
        }
    }
}

private struct FocusDurationButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? Color.white : ALIVEColor.textSecondary)
            .background(isSelected ? ALIVEColor.xpViolet : ALIVEColor.glassSurface, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

struct FocusControlBar: View {
    let status: FocusSessionStatus
    let rewardEstimate: Int
    let start: () -> Void
    let pause: () -> Void
    let reset: () -> Void
    let claim: () -> Void
    @State private var claimPulse = false

    var body: some View {
        HStack(spacing: 12) {
            switch status {
            case .idle:
                primaryButton(title: "Begin focus", icon: "play.fill", action: start)
            case .running:
                secondaryButton(title: "Pause", icon: "pause.fill", action: pause)
                destructiveButton(title: "End", icon: "xmark", action: reset)
            case .paused:
                primaryButton(title: "Resume", icon: "play.fill", action: start)
                destructiveButton(title: "Abandon", icon: "xmark", action: reset)
            case .completed:
                Button(action: claim) {
                    Label("Claim +\(rewardEstimate) XP", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(ALIVEColor.rpgGold)
                .scaleEffect(claimPulse ? 1.03 : 1.0)
                .shadow(color: ALIVEColor.rpgGold.opacity(claimPulse ? 0.4 : 0.1), radius: claimPulse ? 8 : 2)
                .accessibilityIdentifier("focus.claimReward")
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        claimPulse = true
                    }
                }
            }
        }
        .controlSize(.large)
    }

    private func primaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(ALIVEColor.neonCyan)
        .accessibilityIdentifier("focus.primaryControl")
    }

    private func secondaryButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(ALIVEColor.xpViolet)
    }

    private func destructiveButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(role: .destructive, action: action) {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}

struct FocusSessionGuidance: View {
    let status: FocusSessionStatus
    let selectedCourseName: String
    let perkSummary: String?

    private var message: String {
        switch status {
        case .idle:
            return "Choose a duration, remove distractions, and start your next study battle."
        case .running:
            return "Stay with \(selectedCourseName). Your reward unlocks only when the timer reaches zero."
        case .paused:
            return "Paused sessions do not earn XP. Resume when you are ready, or end this attempt."
        case .completed:
            return "Excellent work. Claim your XP to log this completed session and build your streak."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(message, systemImage: "lightbulb.fill")
                .font(.subheadline)
                .foregroundStyle(ALIVEColor.textSecondary)

            if let perkSummary {
                Label(perkSummary, systemImage: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ALIVEColor.neonCyan)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 18, borderColor: ALIVEColor.rpgGold.opacity(0.22))
    }
}
