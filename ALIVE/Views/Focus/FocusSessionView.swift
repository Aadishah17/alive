import SwiftData
import SwiftUI

public struct FocusSessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ALIVERouter.self) private var router
    @Query private var profiles: [UserProfile]
    @Query private var courses: [Course]
    @Query private var skills: [SkillNode]
    @StateObject private var viewModel = FocusViewModel()
    @State private var claimedReward: FocusSessionReward?

    public init() {}

    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    FocusCoursePicker(
                        selectedCourseName: $viewModel.selectedCourseName,
                        courses: courses
                    )

                    FocusTimerRing(
                        timeRemainingSeconds: viewModel.timeRemainingSeconds,
                        targetMinutes: viewModel.targetMinutes,
                        status: viewModel.status
                    )

                    FocusDurationPicker(
                        selectedMinutes: viewModel.targetMinutes,
                        isEnabled: viewModel.canAdjustDuration,
                        selectDuration: viewModel.setDuration(minutes:)
                    )

                    FocusControlBar(
                        status: viewModel.status,
                        rewardEstimate: viewModel.rewardEstimate(
                            forStreak: profiles.first?.streakDays ?? 0,
                            skills: skills
                        ),
                        start: viewModel.startSession,
                        pause: viewModel.pauseSession,
                        reset: viewModel.resetSession,
                        claim: claimCompletedSession
                    )

                    FocusSessionGuidance(
                        status: viewModel.status,
                        selectedCourseName: viewModel.selectedCourseName,
                        perkSummary: ProgressionModifierEngine.focusPerkSummary(
                            forMinutes: viewModel.targetMinutes,
                            skills: skills
                        )
                    )
                }
                .padding()
            }
        }
        .navigationTitle("FOCUS SESSION")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task(id: router.focusStartRequestID) {
            startRequestedFocusSession()
        }
        .alert(
            "XP claimed",
            isPresented: Binding(
                get: { claimedReward != nil },
                set: { if !$0 { claimedReward = nil } }
            ),
            presenting: claimedReward
        ) { _ in
            Button("Keep going") {
                claimedReward = nil
            }
        } message: { reward in
            Text("+\(reward.xpGained) XP earned for your \(reward.sessionType.lowercased()) session.")
        }
        .alert(
            "Couldn’t save this session",
            isPresented: Binding(
                get: { viewModel.saveErrorMessage != nil },
                set: { if !$0 { viewModel.clearSaveError() } }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.clearSaveError()
            }
        } message: {
            Text(viewModel.saveErrorMessage ?? "Please try again.")
        }
    }

    private func startRequestedFocusSession() {
        guard router.focusStartRequestID != nil, viewModel.status == .idle else {
            return
        }

        viewModel.startSession()
    }

    private func claimCompletedSession() {
        guard let profile = profiles.first else {
            return
        }

        claimedReward = viewModel.claimCompletedSession(profile: profile, context: modelContext)
    }
}
