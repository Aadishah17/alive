import SwiftUI
import SwiftData

@main
struct ALIVEApp: App {
    @StateObject private var authService = AuthService()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Quest.self,
            SkillNode.self,
            Course.self,
            StudySession.self,
            Achievement.self,
            XPTransaction.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authService)
                .modelContainer(sharedModelContainer)
        }
    }
}

struct AppRootView: View {
    @EnvironmentObject private var authService: AuthService
    
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
        .preferredColorScheme(.dark)
    }
}
