import SwiftUI
import SwiftData

public struct MainTabView: View {
    @Environment(ALIVERouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    public init() {}
    
    public var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Today", systemImage: "shield.lefthalf.filled")
            }
            .tag(ALIVETab.today)
            
            NavigationStack {
                QuestListView()
            }
            .tabItem {
                Label("Quests", systemImage: "scroll.fill")
            }
            .tag(ALIVETab.quests)
            
            NavigationStack {
                SkillTreeCanvasView()
            }
            .tabItem {
                Label("Skills", systemImage: "tree.fill")
            }
            .tag(ALIVETab.skills)
            
            NavigationStack {
                AttendanceTrackerView()
            }
            .tabItem {
                Label("Academics", systemImage: "percent")
            }
            .tag(ALIVETab.academics)
            
            NavigationStack {
                FocusSessionView()
            }
            .tabItem {
                Label("Focus", systemImage: "timer")
            }
            .tag(ALIVETab.focus)
            
            NavigationStack {
                BadgeVaultView()
            }
            .tabItem {
                Label("Badges", systemImage: "crown.fill")
            }
            .tag(ALIVETab.badges)
        }
        .tint(ALIVEColor.neonCyan)
        .task {
            refreshDailyQuests()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshDailyQuests()
            }
        }
    }

    private func refreshDailyQuests() {
        _ = try? DailyQuestService.refreshIfNeeded(context: modelContext)
    }
}
