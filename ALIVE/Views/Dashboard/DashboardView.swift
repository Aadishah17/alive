import SwiftData
import SwiftUI

/// Coordinates dashboard data and navigation state. Individual dashboard
/// sections live in `DashboardSections.swift` so changes to a single card do
/// not force this screen's data plumbing to grow with it.
public struct DashboardView: View {
    @Query private var profiles: [UserProfile]
    @Query private var quests: [Quest]
    @Query private var courses: [Course]
    @Query(sort: \StudySession.date, order: .reverse) private var sessions: [StudySession]

    @State private var showLevelUpModal = false

    public init() {}

    private var userProfile: UserProfile? {
        profiles.first
    }

    private var pendingDailyQuests: [Quest] {
        quests.filter { $0.category == .daily && !$0.isCompleted }
    }

    private var completedDailyQuestCount: Int {
        quests.filter { $0.category == .daily && $0.isCompleted }.count
    }

    private var coursesAtRisk: [Course] {
        courses.filter { !$0.isSafe }
    }

    private var focusMinutesToday: Int {
        sessions
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + ($1.durationSeconds / 60) }
    }

    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()

            ScrollView {
                if let profile = userProfile {
                    DashboardContent(
                        profile: profile,
                        pendingDailyQuests: pendingDailyQuests,
                        completedDailyQuestCount: completedDailyQuestCount,
                        coursesAtRisk: coursesAtRisk,
                        sessions: sessions,
                        focusMinutesToday: focusMinutesToday,
                        onShowLevelUp: { showLevelUpModal = true }
                    )
                    .padding()
                } else {
                    ProgressView("Loading Hero Profile...")
                        .foregroundStyle(ALIVEColor.textPrimary)
                        .padding()
                }
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
    }
}
