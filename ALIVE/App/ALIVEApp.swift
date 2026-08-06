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
            router.consumePendingIntentRoute()
        }
    }
}
