import SwiftUI

/// Visual dashboard sections receive already-derived data from `DashboardView`.
/// Keeping the query layer out of these views makes each section easy to reason
/// about and prevents unrelated SwiftData updates from leaking into its API.
struct DashboardContent: View {
    let profile: UserProfile
    let pendingDailyQuests: [Quest]
    let completedDailyQuestCount: Int
    let coursesAtRisk: [Course]
    let sessions: [StudySession]
    let focusMinutesToday: Int
    let onShowLevelUp: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            CharacterHUDHeader(profile: profile, onAllocateTap: onShowLevelUp)

            DashboardTodayCommandCenter(
                completedQuestCount: completedDailyQuestCount,
                totalQuestCount: completedDailyQuestCount + pendingDailyQuests.count,
                coursesAtRisk: coursesAtRisk.count,
                focusMinutesToday: focusMinutesToday
            )

            DashboardHealthProgressCard()

            if !coursesAtRisk.isEmpty {
                DashboardAttendanceWarning(coursesAtRisk: coursesAtRisk)
            }

            DashboardDailyQuestSection(profile: profile, quests: pendingDailyQuests)
            DashboardModuleShortcuts()
            DashboardRecentStudySessions(sessions: sessions)
        }
    }
}

private struct DashboardAttendanceWarning: View {
    let coursesAtRisk: [Course]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(ALIVEColor.healthRed)

            VStack(alignment: .leading, spacing: 2) {
                Text("BUNK WARNING TRIGGERED")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ALIVEColor.healthRed)
                Text("\(coursesAtRisk.count) course(s) below safe attendance threshold (\(coursesAtRisk.first?.courseCode ?? "")).")
                    .font(.footnote)
                    .foregroundStyle(ALIVEColor.textPrimary)
            }

            Spacer()
        }
        .glassCard(borderColor: ALIVEColor.healthRed.opacity(0.3))
    }
}

private struct DashboardDailyQuestSection: View {
    let profile: UserProfile
    let quests: [Quest]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ACTIVE DAILY QUESTS")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(ALIVEColor.rpgGold)
                Spacer()
                NavigationLink(destination: QuestListView()) {
                    Text("VIEW ALL (\(quests.count))")
                        .font(.caption)
                        .foregroundStyle(ALIVEColor.neonCyan)
                }
            }

            if quests.isEmpty {
                Text("All daily quests completed! Outstanding work, hero.")
                    .font(.subheadline)
                    .foregroundStyle(ALIVEColor.textSecondary)
                    .padding()
                    .glassCard()
            } else {
                ForEach(quests.prefix(2)) { quest in
                    QuestCardView(quest: quest, profile: profile)
                }
            }
        }
    }
}

private struct DashboardModuleShortcuts: View {
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MODULE SHORTCUTS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(ALIVEColor.neonCyan)

            LazyVGrid(columns: columns, spacing: 14) {
                NavigationLink(destination: SkillTreeCanvasView()) {
                    DashboardShortcutCard(title: "Skill Tree", subtitle: "Unlock Buffs", icon: "tree.fill", color: ALIVEColor.xpViolet)
                }
                NavigationLink(destination: AttendanceTrackerView()) {
                    DashboardShortcutCard(title: "Bunk Tracker", subtitle: "Safe Margin", icon: "percent", color: ALIVEColor.neonCyan)
                }
                NavigationLink(destination: FocusSessionView()) {
                    DashboardShortcutCard(title: "Focus Timer", subtitle: "Earn XP", icon: "timer", color: ALIVEColor.rpgGold)
                }
                NavigationLink(destination: AnalyticsView()) {
                    DashboardShortcutCard(title: "Insights", subtitle: "Study Heatmap", icon: "chart.bar.fill", color: ALIVEColor.staminaGreen)
                }
                NavigationLink(destination: WellnessView()) {
                    DashboardShortcutCard(title: "Wellness", subtitle: "Health & Rituals", icon: "heart.text.square.fill", color: ALIVEColor.staminaGreen)
                }
                NavigationLink(destination: BadgeVaultView()) {
                    DashboardShortcutCard(title: "Badge Vault", subtitle: "Track Growth", icon: "crown.fill", color: ALIVEColor.xpViolet)
                }
            }
        }
    }
}

private struct DashboardRecentStudySessions: View {
    let sessions: [StudySession]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT STUDY BATTLES")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(ALIVEColor.textMuted)

            if sessions.isEmpty {
                Text("No study sessions logged yet. Start a focus timer!")
                    .font(.caption)
                    .foregroundStyle(ALIVEColor.textSecondary)
            } else {
                ForEach(sessions.prefix(3)) { session in
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundStyle(ALIVEColor.neonCyan)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.courseName)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(ALIVEColor.textPrimary)
                            Text("\(session.sessionType) • \(session.formattedDuration)")
                                .font(.caption)
                                .foregroundStyle(ALIVEColor.textSecondary)
                        }
                        Spacer()
                        Text("+\(session.xpEarned) XP")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(ALIVEColor.rpgGold)
                    }
                    .glassCard()
                }
            }
        }
    }
}

private struct DashboardHealthProgressCard: View {
    @EnvironmentObject private var healthService: HealthKitService

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("STAMINA QUEST", systemImage: "figure.walk")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(ALIVEColor.staminaGreen)
                Spacer()
                if healthService.hasRequestedStepAccess {
                    Button {
                        Task { await healthService.refreshToday() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(healthService.isLoading)
                    .accessibilityLabel("Refresh step count")
                }
            }

            if !healthService.isHealthDataAvailable {
                Text("Apple Health is unavailable on this device.")
                    .font(.caption)
                    .foregroundStyle(.gray)
            } else if healthService.hasRequestedStepAccess {
                HStack(alignment: .firstTextBaseline) {
                    Text(healthService.stepCount.formatted())
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("/ \(healthService.dailyStepGoal.formatted()) steps")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text(healthService.stepProgress >= 1 ? "QUEST READY" : "KEEP MOVING")
                        .font(.caption2.bold())
                        .foregroundStyle(healthService.stepProgress >= 1 ? ALIVEColor.rpgGold : ALIVEColor.neonCyan)
                }

                ProgressView(value: healthService.stepProgress)
                    .tint(ALIVEColor.staminaGreen)
            } else {
                Text("Connect Apple Health to track your walking quest. ALIVE reads only today’s step count.")
                    .font(.caption)
                    .foregroundStyle(.gray)

                Button("CONNECT APPLE HEALTH") {
                    Task {
                        await healthService.requestAccess()
                    }
                }
                .font(.caption.bold())
                .foregroundStyle(ALIVEColor.staminaGreen)
                .disabled(healthService.isLoading)
            }

            if healthService.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .tint(ALIVEColor.neonCyan)
            }

            Text(healthService.statusMessage)
                .font(.caption2)
                .foregroundStyle(healthService.isHealthDataAvailable ? ALIVEColor.textSecondary : ALIVEColor.healthRed)
        }
        .glassCard(borderColor: ALIVEColor.staminaGreen.opacity(0.35))
        .task {
            if healthService.hasRequestedStepAccess {
                await healthService.refreshToday()
            }
        }
    }
}

private struct DashboardTodayCommandCenter: View {
    let completedQuestCount: Int
    let totalQuestCount: Int
    let coursesAtRisk: Int
    let focusMinutesToday: Int

    private var questProgress: Double {
        guard totalQuestCount > 0 else {
            return 0
        }

        return Double(completedQuestCount) / Double(totalQuestCount)
    }

    private var nextMove: String {
        if coursesAtRisk > 0 {
            return "Protect your attendance buffer first."
        }
        if completedQuestCount < totalQuestCount {
            return "One small quest can keep your streak alive."
        }
        return "Daily quest board cleared. Build tomorrow’s advantage."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TODAY’S MOMENTUM")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(ALIVEColor.neonCyan)
                    Text(nextMove)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ALIVEColor.textPrimary)
                }

                Spacer()

                Gauge(value: questProgress) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(completedQuestCount)/\(totalQuestCount)")
                        .font(.caption2.weight(.bold).monospacedDigit())
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(ALIVEColor.xpGradient)
                .frame(width: 50, height: 50)
            }

            HStack(spacing: 10) {
                DashboardMomentumMetric(
                    value: "\(focusMinutesToday)m",
                    label: "FOCUS TODAY",
                    icon: "timer",
                    color: ALIVEColor.xpViolet
                )
                DashboardMomentumMetric(
                    value: "\(coursesAtRisk)",
                    label: "COURSES AT RISK",
                    icon: coursesAtRisk > 0 ? "exclamationmark.triangle.fill" : "shield.checkmark.fill",
                    color: coursesAtRisk > 0 ? ALIVEColor.healthRed : ALIVEColor.staminaGreen
                )
            }
        }
        .glassCard(cornerRadius: 20, borderColor: ALIVEColor.neonCyan.opacity(0.24))
    }
}

private struct DashboardMomentumMetric: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(ALIVEColor.textPrimary)
                Text(label)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(ALIVEColor.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct DashboardShortcutCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ALIVEColor.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(ALIVEColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(borderColor: color.opacity(0.25))
    }
}
