import Combine
import Foundation
import SwiftData

public enum FocusSessionStatus: String, Equatable, Sendable {
    case idle
    case running
    case paused
    case completed
}

public struct FocusSessionReward: Equatable, Sendable {
    public let xpGained: Int
    public let durationSeconds: Int
    public let sessionType: String
}

/// Owns the transient focus-timer state. Persistence and XP are deliberately
/// gated behind `completed` so a paused or in-progress timer can never claim a
/// full reward.
public final class FocusViewModel: ObservableObject {
    @Published public var selectedCourseName: String = "General Study"
    @Published public private(set) var targetMinutes: Int = 25
    @Published public private(set) var timeRemainingSeconds: Int = 25 * 60
    @Published public private(set) var status: FocusSessionStatus = .idle
    @Published public private(set) var saveErrorMessage: String?

    public var focusScore: Int = 100
    public var ambientSoundMode: String = "Rain & Lo-Fi RPG"

    public var isRunning: Bool { status == .running }
    public var isPaused: Bool { status == .paused }
    public var isClaimable: Bool { status == .completed }
    public var isReadyToClaimXP: Bool { isClaimable }
    public var canAdjustDuration: Bool { status == .idle }
    public var elapsedSeconds: Int { max(0, (targetMinutes * 60) - timeRemainingSeconds) }
    public var baseRewardEstimate: Int {
        Self.xpAward(forMinutes: targetMinutes, focusScore: focusScore)
    }

    public func rewardEstimate(forStreak streakDays: Int, skills: [SkillNode]) -> Int {
        let modifiedBaseXP = ProgressionModifierEngine.modifiedFocusBaseXP(
            baseXP: baseRewardEstimate,
            minutes: targetMinutes,
            skills: skills
        )
        return Self.xpAwardWithStreak(baseXP: modifiedBaseXP, streakDays: streakDays)
    }

    private var timer: Timer?

    public init() {}

    deinit {
        timer?.invalidate()
    }

    public func startSession() {
        guard status != .running, status != .completed else {
            return
        }

        saveErrorMessage = nil
        status = .running
        scheduleTimer()
        beginOrResumeLiveActivity()
    }

    public func pauseSession() {
        guard status == .running else {
            return
        }

        timer?.invalidate()
        timer = nil
        status = .paused
        updateLiveActivity(isPaused: true)
    }

    public func resetSession() {
        timer?.invalidate()
        timer = nil
        status = .idle
        timeRemainingSeconds = targetMinutes * 60
        saveErrorMessage = nil
        Task {
            await FocusLiveActivityManager.shared.end()
        }
    }

    public func setDuration(minutes: Int) {
        guard minutes > 0, canAdjustDuration else {
            return
        }

        targetMinutes = minutes
        resetSession()
    }

    public func clearSaveError() {
        saveErrorMessage = nil
    }

    public func completeTimerSession() {
        guard status == .running else {
            return
        }

        timer?.invalidate()
        timer = nil
        timeRemainingSeconds = 0
        status = .completed
        HapticManager.shared.levelUpHaptic()
        updateLiveActivity(isCompleted: true)
    }

    /// Persists a fully completed session and its XP reward. Calling this before
    /// the countdown completes is a no-op by design.
    @discardableResult
    public func claimCompletedSession(
        profile: UserProfile,
        context: ModelContext
    ) -> FocusSessionReward? {
        guard isClaimable else {
            return nil
        }

        let durationSeconds = targetMinutes * 60
        let skills = (try? context.fetch(FetchDescriptor<SkillNode>())) ?? []
        let baseXP = ProgressionModifierEngine.modifiedFocusBaseXP(
            baseXP: baseRewardEstimate,
            minutes: targetMinutes,
            skills: skills
        )
        let sessionType = targetMinutes >= 45 ? "Deep Work" : "Pomodoro"
        let xpResult = XPEngine.addXP(
            amount: baseXP,
            to: profile,
            source: "Focus Session (\(targetMinutes)m)",
            context: context
        )

        let session = StudySession(
            courseName: selectedCourseName,
            durationSeconds: durationSeconds,
            xpEarned: xpResult.xpGained,
            focusScore: focusScore,
            sessionType: sessionType
        )
        context.insert(session)

        profile.focus += 1

        do {
            try PersistenceService.save(context)
        } catch {
            saveErrorMessage = "Your completed session is still ready to claim. Please try again."
            return nil
        }

        let pendingQuestCount = (try? context.fetch(FetchDescriptor<Quest>()))?
            .filter { !$0.isCompleted }
            .count ?? 0
        WidgetSnapshotService.refresh(profile: profile, pendingQuestCount: pendingQuestCount)

        let reward = FocusSessionReward(
            xpGained: xpResult.xpGained,
            durationSeconds: durationSeconds,
            sessionType: sessionType
        )
        resetSession()
        return reward
    }

    public static func xpAward(forMinutes minutes: Int, focusScore: Int) -> Int {
        let safeMinutes = max(0, minutes)
        let baseXP = safeMinutes * 5
        let clampedFocusScore = min(max(focusScore, 0), 100)
        let focusBonus = Int(Double(baseXP) * (Double(clampedFocusScore) / 100.0))
        return baseXP + focusBonus
    }

    public static func xpAwardWithStreak(baseXP: Int, streakDays: Int) -> Int {
        Int(Double(baseXP) * XPEngine.streakMultiplier(forStreak: streakDays))
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else {
                return
            }

            guard self.timeRemainingSeconds > 1 else {
                self.completeTimerSession()
                return
            }

            self.timeRemainingSeconds -= 1
            if self.timeRemainingSeconds.isMultiple(of: 60) {
                self.updateLiveActivity()
            }
        }
    }

    private func beginOrResumeLiveActivity() {
        let courseName = selectedCourseName
        let targetMinutes = targetMinutes
        let timeRemainingSeconds = timeRemainingSeconds
        let focusScore = focusScore
        Task {
            await FocusLiveActivityManager.shared.beginOrResume(
                courseName: courseName,
                targetMinutes: targetMinutes,
                timeRemainingSeconds: timeRemainingSeconds,
                focusScore: focusScore
            )
        }
    }

    private func updateLiveActivity(isPaused: Bool = false, isCompleted: Bool = false) {
        let courseName = selectedCourseName
        let timeRemainingSeconds = timeRemainingSeconds
        let focusScore = focusScore
        Task {
            await FocusLiveActivityManager.shared.update(
                courseName: courseName,
                timeRemainingSeconds: timeRemainingSeconds,
                focusScore: focusScore,
                isPaused: isPaused,
                isCompleted: isCompleted
            )
        }
    }
}
