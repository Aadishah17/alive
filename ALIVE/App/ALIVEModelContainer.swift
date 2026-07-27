import SwiftData

/// Single source of truth for ALIVE's persistent model container.
/// The app scene and App Intents both use this container so system actions affect
/// the same player state that the foreground UI renders.
public enum ALIVEModelContainer {
    public static let shared: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            Quest.self,
            SkillNode.self,
            Course.self,
            StudySession.self,
            Achievement.self,
            XPTransaction.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ALIVE's model container: \(error)")
        }
    }()
}
