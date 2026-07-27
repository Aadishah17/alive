import SwiftData

/// Commits a gameplay mutation as one unit. SwiftData keeps failed changes in a
/// context by default, which could otherwise let a retry award the same XP twice.
public enum PersistenceService {
    public static func save(_ context: ModelContext) throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
