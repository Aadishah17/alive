import SwiftUI
import SwiftData

public struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var quests: [Quest]
    @Query private var courses: [Course]
    @Query private var sessions: [StudySession]
    
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
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .glassCard(borderColor: ALIVEColor.healthRed)
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
                                    .foregroundColor(.gray)
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
                            }
                        }
                        
                        // Recent Study History
                        VStack(alignment: .leading, spacing: 12) {
                            Text("RECENT STUDY BATTLES")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.gray)
                            
                            if sessions.isEmpty {
                                Text("No study sessions logged yet. Start a focus timer!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(sessions.prefix(3)) { session in
                                    HStack {
                                        Image(systemName: "book.fill")
                                            .foregroundColor(ALIVEColor.neonCyan)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(session.courseName)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("\(session.sessionType) • \(session.formattedDuration)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
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
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showLevelUpModal) {
            if let profile = userProfile {
                LevelUpModalView(profile: profile) {
                    showLevelUpModal = false
                }
            }
        }
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
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(borderColor: color.opacity(0.4))
    }
}
