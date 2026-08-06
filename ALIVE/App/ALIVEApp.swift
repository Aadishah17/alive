import SwiftUI
import SwiftData

@main
struct ALIVEApp: App {
    @StateObject private var authService = AuthService()
    #if os(iOS)
    @UIApplicationDelegateAdaptor(ALIVEApplicationDelegate.self) private var applicationDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authService)
                .modelContainer(ALIVEModelContainer.shared)
        }
    }
}

struct AppRootView: View {
    @EnvironmentObject private var authService: AuthService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var router = ALIVERouter()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                NavigationView {
                    AuthView()
                }
            }
        }
        .environment(router)
        .preferredColorScheme(.light)
        .onOpenURL { router.handle(url: $0) }
        .onReceive(NotificationCenter.default.publisher(for: ALIVEIntentRouteStore.didRequestRoute)) { _ in
            router.consumePendingIntentRoute()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                router.consumePendingIntentRoute()
            }
        }
        .task {
            MockDataGenerator.seedInitialData(context: modelContext)
            if let seeded = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first {
                authService.loginMockUser(profile: seeded)
            }
            applyLaunchArgumentRouting()
            router.consumePendingIntentRoute()
        }
    }
    
    private func applyLaunchArgumentRouting() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-AutoTabMode") {
            Task { @MainActor in
                let sequence: [ALIVETab] = [.today, .quests, .skills, .academics, .focus, .badges]
                for tab in sequence {
                    router.selectedTab = tab
                    try? await Task.sleep(for: .seconds(3.0))
                }
            }
        } else if args.contains("-TabToday") {
            router.selectedTab = .today
        } else if args.contains("-TabQuests") {
            router.selectedTab = .quests
        } else if args.contains("-TabSkills") {
            router.selectedTab = .skills
        } else if args.contains("-TabAcademics") {
            router.selectedTab = .academics
        } else if args.contains("-TabFocus") {
            router.selectedTab = .focus
        } else if args.contains("-TabBadges") {
            router.selectedTab = .badges
        }
    }
}
