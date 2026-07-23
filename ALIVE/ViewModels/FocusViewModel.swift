import SwiftUI
import SwiftData
import Combine

public final class FocusViewModel: ObservableObject {
    @Published public var selectedCourseName: String = "General Study"
    @Published public var targetMinutes: Int = 25
    @Published public var timeRemainingSeconds: Int = 25 * 60
    @Published public var isRunning: Bool = false
    @Published public var isPaused: Bool = false
    @Published public var focusScore: Int = 100
    @Published public var ambientSoundMode: String = "Rain & Lo-Fi RPG"
    
    private var timer: Timer?
    
    public init() {}
    
    public func startSession() {
        isRunning = true
        isPaused = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemainingSeconds > 0 {
                self.timeRemainingSeconds -= 1
            } else {
                self.completeTimerSession()
            }
        }
    }
    
    public func pauseSession() {
        isPaused = true
        isRunning = false
        timer?.invalidate()
    }
    
    public func resetSession() {
        timer?.invalidate()
        isRunning = false
        isPaused = false
        timeRemainingSeconds = targetMinutes * 60
    }
    
    public func setDuration(minutes: Int) {
        targetMinutes = minutes
        resetSession()
    }
    
    public func completeTimerSession() {
        timer?.invalidate()
        isRunning = false
        isPaused = false
        timeRemainingSeconds = targetMinutes * 60
        HapticManager.shared.levelUpHaptic()
    }
    
    public func saveCompletedSession(profile: UserProfile, context: ModelContext) {
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
        
        // Award XP and focus stats
        _ = XPEngine.addXP(amount: xpGained, to: profile, source: "Focus Session (\(targetMinutes)m)", context: context)
        profile.focus += 1
        
        try? context.save()
    }
}
