import SwiftUI
import SwiftData

/// Optional native integrations that turn wellbeing habits into RPG progress.
/// Nothing is requested until the player explicitly connects Health or enables a reminder.
public struct WellnessView: View {
    @Query private var skills: [SkillNode]
    @EnvironmentObject private var healthService: HealthKitService
    @AppStorage("alive.focusReminderEnabled") private var focusReminderEnabled = false
    @AppStorage("alive.focusReminderHour") private var focusReminderHour = 19
    @State private var reminderErrorMessage: String?

    public init() {}

    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    WellnessHeader()

                    MovementQuestCard(
                        stepCount: healthService.stepCount,
                        stepGoal: healthService.dailyStepGoal,
                        stepProgress: healthService.stepProgress,
                        isLoading: healthService.isLoading,
                        isAvailable: healthService.isHealthDataAvailable,
                        isConnected: healthService.hasRequestedStepAccess,
                        statusMessage: healthService.statusMessage,
                        connectHealth: connectHealth,
                        refreshHealth: refreshHealth
                    )

                    FocusReminderCard(
                        isEnabled: $focusReminderEnabled,
                        selectedHour: $focusReminderHour,
                        updateReminder: updateReminder
                    )

                    if ProgressionModifierEngine.isUnlocked(
                        ProgressionModifierEngine.circadianMastery,
                        in: skills
                    ) {
                        RecoveryRitualCard()
                    } else {
                        LockedRecoveryRitualCard()
                    }
                }
                .padding()
            }
        }
        .navigationTitle("WELLNESS")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            if healthService.hasRequestedStepAccess {
                await healthService.refreshToday()
            }
        }
        .alert(
            "Reminder unavailable",
            isPresented: Binding(
                get: { reminderErrorMessage != nil },
                set: { if !$0 { reminderErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                reminderErrorMessage = nil
            }
        } message: {
            Text(reminderErrorMessage ?? "Please try again.")
        }
    }

    private func connectHealth() {
        Task {
            await healthService.requestAccess()
        }
    }

    private func refreshHealth() {
        Task {
            await healthService.refreshToday()
        }
    }

    private func updateReminder() {
        Task {
            if focusReminderEnabled {
                let granted = await FocusNotificationService.shared.requestAuthorization()
                guard granted else {
                    focusReminderEnabled = false
                    reminderErrorMessage = "Enable notifications for ALIVE in Settings to receive your daily focus quest reminder."
                    return
                }

                let scheduled = await FocusNotificationService.shared.scheduleDailyReminder(
                    hour: focusReminderHour,
                    minute: 0
                )
                guard scheduled else {
                    focusReminderEnabled = false
                    reminderErrorMessage = "ALIVE couldn’t schedule this reminder. Please try again."
                    return
                }
            } else {
                await FocusNotificationService.shared.cancelDailyReminder()
            }
        }
    }
}

private struct WellnessHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("BUILD A LIFE THAT LASTS")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(ALIVEColor.neonCyan)
            Text("Connect optional wellbeing signals to keep your study plan sustainable—not punishing.")
                .font(.title3.weight(.bold))
                .foregroundStyle(ALIVEColor.textPrimary)
            Text("ALIVE asks only for data you choose to use.")
                .font(.subheadline)
                .foregroundStyle(ALIVEColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MovementQuestCard: View {
    let stepCount: Int
    let stepGoal: Int
    let stepProgress: Double
    let isLoading: Bool
    let isAvailable: Bool
    let isConnected: Bool
    let statusMessage: String
    let connectHealth: () -> Void
    let refreshHealth: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Movement quest", systemImage: "figure.walk")
                    .font(.headline)
                    .foregroundStyle(ALIVEColor.textPrimary)
                Spacer()
                Text("STAMINA SUPPORT")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ALIVEColor.staminaGreen)
            }

            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text("\(stepCount.formatted())")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                Text("/ \(stepGoal.formatted()) steps")
                    .font(.subheadline)
                    .foregroundStyle(ALIVEColor.textSecondary)
            }

            ProgressView(value: stepProgress)
                .tint(ALIVEColor.staminaGreen)

            Text(statusMessage)
                .font(.footnote)
                .foregroundStyle(ALIVEColor.textSecondary)

            HStack(spacing: 10) {
                if isConnected {
                    Label("Apple Health connected", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ALIVEColor.staminaGreen)
                } else {
                    Button(isAvailable ? "Connect Apple Health" : "Apple Health unavailable", action: connectHealth)
                        .buttonStyle(.borderedProminent)
                        .tint(ALIVEColor.staminaGreen)
                        .disabled(!isAvailable || isLoading)
                }

                Button(action: refreshHealth) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(!isAvailable || !isConnected || isLoading)
                .accessibilityLabel("Refresh Apple Health steps")
            }
        }
        .glassCard(cornerRadius: 20, borderColor: ALIVEColor.staminaGreen.opacity(0.3))
    }
}

private struct FocusReminderCard: View {
    @Binding var isEnabled: Bool
    @Binding var selectedHour: Int
    let updateReminder: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Daily focus quest", systemImage: "bell.badge.fill")
                    .font(.headline)
                    .foregroundStyle(ALIVEColor.textPrimary)
                Spacer()
                Toggle("Daily focus reminder", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(ALIVEColor.neonCyan)
                    .onChange(of: isEnabled) { _, _ in
                        updateReminder()
                    }
            }

            Text("Get one calm reminder when you want to begin your next deep-work battle.")
                .font(.footnote)
                .foregroundStyle(ALIVEColor.textSecondary)

            Picker("Reminder hour", selection: $selectedHour) {
                ForEach(6...22, id: \.self) { hour in
                    Text(Self.hourLabel(hour)).tag(hour)
                }
            }
            .pickerStyle(.menu)
            .disabled(!isEnabled)
            .onChange(of: selectedHour) { _, _ in
                if isEnabled {
                    updateReminder()
                }
            }
        }
        .glassCard(cornerRadius: 20, borderColor: ALIVEColor.neonCyan.opacity(0.25))
    }

    private static func hourLabel(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.string(from: Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now)
    }
}

private struct RecoveryRitualCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(ALIVEColor.xpViolet)

            VStack(alignment: .leading, spacing: 4) {
                Text("Recovery is part of the build")
                    .font(.headline)
                    .foregroundStyle(ALIVEColor.textPrimary)
                Text("Use a short walk, water break, or screen-free reset between study sessions. Sustainable streaks beat heroic burnout.")
                    .font(.footnote)
                    .foregroundStyle(ALIVEColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20, borderColor: ALIVEColor.xpViolet.opacity(0.25))
    }
}

private struct LockedRecoveryRitualCard: View {
    var body: some View {
        Label(
            "Unlock Circadian Mastery in the skill tree to add a guided recovery ritual here.",
            systemImage: "lock.fill"
        )
        .font(.footnote)
        .foregroundStyle(ALIVEColor.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20, borderColor: ALIVEColor.xpViolet.opacity(0.22))
    }
}
