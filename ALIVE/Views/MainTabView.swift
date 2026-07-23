import SwiftUI
import SwiftData

public struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    
    public init() {}
    
    public var body: some View {
        TabView {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Label("Hero HUD", systemImage: "shield.fill")
            }
            
            NavigationView {
                QuestListView()
            }
            .tabItem {
                Label("Quests", systemImage: "scroll.fill")
            }
            
            NavigationView {
                SkillTreeCanvasView()
            }
            .tabItem {
                Label("Skills", systemImage: "tree.fill")
            }
            
            NavigationView {
                AttendanceTrackerView()
            }
            .tabItem {
                Label("Academics", systemImage: "percent")
            }
            
            NavigationView {
                FocusSessionView()
            }
            .tabItem {
                Label("Focus", systemImage: "timer")
            }
            
            NavigationView {
                BadgeVaultView()
            }
            .tabItem {
                Label("Badges", systemImage: "crown.fill")
            }
        }
        .tint(ALIVEColor.neonCyan)
    }
}
