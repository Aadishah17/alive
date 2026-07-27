import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Query private var profiles: [UserProfile]
    @Query private var quests: [Quest]
    @Query private var courses: [Course]
    @Query(sort: \StudySession.date, order: .reverse) private var sessions: [StudySession]
    
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var showLevelUpModal: Bool = false
    
    public init() {}
    
    private var userProfile: UserProfile? {
        profiles.first
    }
    
    private var pendingDailyQuests: [Quest] {
        quests.filter { $0.category == .daily && !$0.isCompleted }
    }
    
    private var coursesAtRisk: [Course] {
        courses.filter { !$0.isSafe }
    }

    private var completedDailyQuestCount: Int {
        quests.filter { $0.category == .daily && $0.isCompleted }.count
    }
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    if let profile = userProfile {
                        // Character HUD Header
                        CharacterHUDHeader(profile: profile) {
                            showLevelUpModal = true
                        }

                        TodayCommandCenter(
                            completedQuestCount: completedDailyQuestCount,
                            totalQuestCount: completedDailyQuestCount + pendingDailyQuests.count,
                            coursesAtRisk: coursesAtRisk.count,
                            focusMinutesToday: sessions
                                .filter { Calendar.current.isDateInToday($0.date) }
                                .reduce(0) { $0 + ($1.durationSeconds / 60) }
                        )

                        HealthProgressCard(manager: healthKitManager) {
                            Task {
                                await healthKitManager.requestStepAccess()
                            }
                        }
                        
                        // Academic Danger Banner (if any course below threshold)
                        if !coursesAtRisk.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundColor(ALIVEColor.healthRed)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("BUNK WARNING TRIGGERED")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(ALIVEColor.healthRed)
                                    Text("\(coursesAtRisk.count) course(s) below safe attendance threshold (\(coursesAtRisk.first?.courseCode ?? "")).")
                                        .font(.footnote)
                                        .foregroundColor(ALIVEColor.textPrimary)
                                }
                                Spacer()
                            }
                            .glassCard(borderColor: ALIVEColor.healthRed.opacity(0.3))
                        }
                        
                        // Active Daily Quests Quick Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ACTIVE DAILY QUESTS")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(ALIVEColor.rpgGold)
                                Spacer()
                                NavigationLink(destination: QuestListView()) {
                                    Text("VIEW ALL (\(pendingDailyQuests.count))")
                                        .font(.caption)
                                        .foregroundColor(ALIVEColor.neonCyan)
                                }
                            }
                            
                            if pendingDailyQuests.isEmpty {
                                Text("All daily quests completed! Outstanding work, hero.")
                                    .font(.subheadline)
                                    .foregroundColor(ALIVEColor.textSecondary)
                                    .padding()
                                    .glassCard()
                            } else {
                                ForEach(pendingDailyQuests.prefix(2)) { quest in
                                    QuestCardView(quest: quest, profile: profile)
                                }
                            }
                        }
                        
                        // Quick Action RPG Modules Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("MODULE SHORTCUTS")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(ALIVEColor.neonCyan)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                NavigationLink(destination: SkillTreeCanvasView()) {
                                    ShortcutCard(title: "Skill Tree", subtitle: "Unlock Buffs", icon: "tree.fill", color: ALIVEColor.xpViolet)
                                }
                                NavigationLink(destination: AttendanceTrackerView()) {
                                    ShortcutCard(title: "Bunk Tracker", subtitle: "Safe Margin", icon: "percent", color: ALIVEColor.neonCyan)
                                }
                                NavigationLink(destination: FocusSessionView()) {
                                    ShortcutCard(title: "Focus Timer", subtitle: "Earn XP", icon: "timer", color: ALIVEColor.rpgGold)
                                }
                                NavigationLink(destination: AnalyticsView()) {
                                    ShortcutCard(title: "Insights", subtitle: "Study Heatmap", icon: "chart.bar.fill", color: ALIVEColor.staminaGreen)
                                }
                                NavigationLink(destination: WellnessView()) {
                                    ShortcutCard(title: "Wellness", subtitle: "Health & Rituals", icon: "heart.text.square.fill", color: ALIVEColor.staminaGreen)
                                }
                                NavigationLink(destination: BadgeVaultView()) {
                                    ShortcutCard(title: "Badge Vault", subtitle: "Track Growth", icon: "crown.fill", color: ALIVEColor.xpViolet)
                                }
                            }
                        }
                        
                        // Recent Study History
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RECENT STUDY BATTLES")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(ALIVEColor.textMuted)
                            
                            if sessions.isEmpty {
                                Text("No study sessions logged yet. Start a focus timer!")
                                    .font(.caption)
                                    .foregroundColor(ALIVEColor.textSecondary)
                            } else {
                                ForEach(sessions.prefix(3)) { session in
                                    HStack {
                                        Image(systemName: "book.fill")
                                            .foregroundColor(ALIVEColor.neonCyan)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(session.courseName)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(ALIVEColor.textPrimary)
                                            Text("\(session.sessionType) • \(session.formattedDuration)")
                                                .font(.caption)
                                                .foregroundColor(ALIVEColor.textSecondary)
                                        }
                                        Spacer()
                                        Text("+\(session.xpEarned) XP")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(ALIVEColor.rpgGold)
                                    }
                                    .glassCard()
                                }
                            }
                        }
                    } else {
                        ProgressView("Loading Hero Profile...")
                            .foregroundColor(ALIVEColor.textPrimary)
                    }
                }
                .padding()
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showLevelUpModal) {
            if let profile = userProfile {
                LevelUpModalView(profile: profile) {
                    showLevelUpModal = false
                }
            }
        }
        #endif
        .task {
            if healthKitManager.hasRequestedStepAccess {
                await healthKitManager.refreshTodayStepCount()
            }
        }
    }
}

struct HealthProgressCard: View {
    @ObservedObject var manager: HealthKitManager
    let onConnect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("STAMINA QUEST", systemImage: "figure.walk")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(ALIVEColor.staminaGreen)
                Spacer()
                if manager.hasRequestedStepAccess {
                    Button {
                        Task { await manager.refreshTodayStepCount() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(manager.isLoading)
                    .accessibilityLabel("Refresh step count")
                }
            }

            if !manager.isAvailable {
                Text("Apple Health is unavailable on this device.")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else if manager.hasRequestedStepAccess {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(manager.todayStepCount.formatted())")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("/ \(manager.dailyStepGoal.formatted()) steps")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(manager.stepProgress >= 1 ? "QUEST READY" : "KEEP MOVING")
                        .font(.caption2.bold())
                        .foregroundColor(manager.stepProgress >= 1 ? ALIVEColor.rpgGold : ALIVEColor.neonCyan)
                }

                ProgressView(value: manager.stepProgress)
                    .tint(ALIVEColor.staminaGreen)
            } else {
                Text("Connect Apple Health to track your walking quest. ALIVE reads only today’s step count.")
                    .font(.caption)
                    .foregroundColor(.gray)

                Button("CONNECT APPLE HEALTH", action: onConnect)
                    .font(.caption.bold())
                    .foregroundColor(ALIVEColor.staminaGreen)
                    .disabled(manager.isLoading)
            }

            if manager.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .tint(ALIVEColor.neonCyan)
            }

            if let error = manager.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(ALIVEColor.healthRed)
            }
        }
        .glassCard(borderColor: ALIVEColor.staminaGreen.opacity(0.35))
    }
}

private struct TodayCommandCenter: View {
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
                MomentumMetric(
                    value: "\(focusMinutesToday)m",
                    label: "FOCUS TODAY",
                    icon: "timer",
                    color: ALIVEColor.xpViolet
                )
                MomentumMetric(
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

private struct MomentumMetric: View {
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

struct ShortcutCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(ALIVEColor.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(ALIVEColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(borderColor: color.opacity(0.25))
    }
}
