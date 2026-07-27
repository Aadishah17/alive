import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

public enum WidgetSnapshotService {
    public static func refresh(profile: UserProfile, pendingQuestCount: Int) {
        let snapshot = ALIVEWidgetSnapshot(
            heroName: profile.username,
            level: profile.level,
            currentXP: profile.currentXP,
            requiredXP: profile.requiredXPForNextLevel,
            streakDays: profile.streakDays,
            pendingQuestCount: pendingQuestCount
        )
        ALIVEWidgetSnapshotStore.save(snapshot)

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
