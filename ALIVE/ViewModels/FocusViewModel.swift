import SwiftUI
import SwiftData
import Combine

public final class FocusViewModel: ObservableObject {
    @Published public var selectedCourseName: String = "General Study"
    @Published public var targetMinutes: Int = 25
    @Published public var timeRemainingSeconds: Int = 25 * 60
    @Published public var isRunning: Bool = false
    @Published public var isPaused: Bool = false
    @Published public private(set) var isReadyToClaimXP: Bool = false
    @Published public private(set) var saveErrorMessage: String?
    @Published public var focusScore: Int = 100
    @Published public var ambientSoundMode: String = "Rain & Lo-Fi RPG"
    
    private var timer: Timer?
    private var sessionEndDate: Date?
    
    public init() {}

    deinit {
        timer?.invalidate()
    }
    
    public func startSession() {
        guard !isReadyToClaimXP else { return }

        let wasPaused = isPaused
        let courseName = selectedCourseName
        let remainingSeconds = timeRemainingSeconds
        let score = focusScore
        isRunning = true
        isPaused = false
        saveErrorMessage = nil
        sessionEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRemainingTime()
        }

        Task { @MainActor in
            if wasPaused {
                await FocusLiveActivityManager.shared.resume(
                    timeRemainingSeconds: remainingSeconds,
                    focusScore: score
                )
            } else {
                await FocusLiveActivityManager.shared.start(
                    courseName: courseName,
                    durationSeconds: remainingSeconds,
                    focusScore: score
                )
            }
            await FocusReminderManager.shared.scheduleCompletion(
                after: remainingSeconds,
                courseName: courseName
            )
        }
    }
    
    public func pauseSession() {
        updateRemainingTime()
        guard !isReadyToClaimXP else { return }

        isPaused = true
        isRunning = false
        timer?.invalidate()
        sessionEndDate = nil

        let remainingSeconds = timeRemainingSeconds
        let score = focusScore
        Task { @MainActor in
            await FocusLiveActivityManager.shared.pause(
                timeRemainingSeconds: remainingSeconds,
                focusScore: score
            )
            FocusReminderManager.shared.cancelCompletionReminder()
        }
    }
    
    public func resetSession() {
        timer?.invalidate()
        isRunning = false
        isPaused = false
        timeRemainingSeconds = targetMinutes * 60
        sessionEndDate = nil
        isReadyToClaimXP = false
        saveErrorMessage = nil

        let score = focusScore
        Task { @MainActor in
            await FocusLiveActivityManager.shared.end(focusScore: score)
            FocusReminderManager.shared.cancelCompletionReminder()
        }
    }
    
    public func setDuration(minutes: Int) {
        targetMinutes = minutes
        resetSession()
    }
    
    public func completeTimerSession() {
        timer?.invalidate()
        isRunning = false
        isPaused = false
        timeRemainingSeconds = 0
        sessionEndDate = nil
        isReadyToClaimXP = true
        HapticManager.shared.levelUpHaptic()

        let score = focusScore
        Task { @MainActor in
            await FocusLiveActivityManager.shared.end(focusScore: score)
            FocusReminderManager.shared.cancelCompletionReminder()
        }
    }
    
    @discardableResult
    public func saveCompletedSession(profile: UserProfile, context: ModelContext) -> Bool {
        guard isReadyToClaimXP else { return false }

        let durationSec = targetMinutes * 60
        // Formula: 1 XP per minute studied + bonus for high focus score
        let baseXP = targetMinutes * 5
        let bonusXP = Int(Double(baseXP) * (Double(focusScore) / 100.0))
        let xpGained = baseXP + bonusXP
        
        let session = StudySession(
            courseName: selectedCourseName,
            durationSeconds: durationSec,
            xpEarned: xpGained,
            focusScore: focusScore,
            sessionType: targetMinutes >= 45 ? "Deep Work" : "Pomodoro"
        )
        
        context.insert(session)
        let previousState = (
            level: profile.level,
            currentXP: profile.currentXP,
            totalXPEarned: profile.totalXPEarned,
            unallocatedStatPoints: profile.unallocatedStatPoints,
            focus: profile.focus
        )
        let source = "Focus Session (\(targetMinutes)m)"
        let result = XPEngine.addXP(amount: xpGained, to: profile, source: source)
        let transaction = XPTransaction(source: source, amount: result.xpGained)
        context.insert(transaction)
        profile.focus += 1

        do {
            try context.save()
            resetSession()
            return true
        } catch {
            context.delete(session)
            context.delete(transaction)
            profile.level = previousState.level
            profile.currentXP = previousState.currentXP
            profile.totalXPEarned = previousState.totalXPEarned
            profile.unallocatedStatPoints = previousState.unallocatedStatPoints
            profile.focus = previousState.focus
            saveErrorMessage = "Could not save this focus session. Please try again."
            return false
        }
    }

    private func updateRemainingTime() {
        guard let sessionEndDate else { return }

        let remainingSeconds = max(0, Int(ceil(sessionEndDate.timeIntervalSinceNow)))
        timeRemainingSeconds = remainingSeconds

        if remainingSeconds == 0 {
            completeTimerSession()
        }
    }
}
