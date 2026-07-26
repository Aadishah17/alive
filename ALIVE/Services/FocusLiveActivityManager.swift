import ActivityKit
import Foundation

@MainActor
public final class FocusLiveActivityManager {
    public static let shared = FocusLiveActivityManager()

    private var activity: Activity<FocusLiveActivityAttributes>?

    private init() {}

    public func start(courseName: String, durationSeconds: Int, focusScore: Int) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        if let existing = activity ?? Activity<FocusLiveActivityAttributes>.activities.first {
            await existing.end(nil, dismissalPolicy: .immediate)
        }

        let attributes = FocusLiveActivityAttributes(
            courseName: courseName,
            totalDurationMinutes: max(1, durationSeconds / 60),
            xpRewardPotential: durationSeconds / 6
        )
        let state = FocusLiveActivityAttributes.ContentState(
            timeRemainingSeconds: durationSeconds,
            focusScore: focusScore,
            endDate: Date().addingTimeInterval(TimeInterval(durationSeconds))
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            activity = nil
        }
    }

    public func pause(timeRemainingSeconds: Int, focusScore: Int) async {
        await update(
            timeRemainingSeconds: timeRemainingSeconds,
            focusScore: focusScore,
            isPaused: true,
            endDate: nil
        )
    }

    public func resume(timeRemainingSeconds: Int, focusScore: Int) async {
        await update(
            timeRemainingSeconds: timeRemainingSeconds,
            focusScore: focusScore,
            isPaused: false,
            endDate: Date().addingTimeInterval(TimeInterval(timeRemainingSeconds))
        )
    }

    public func end(focusScore: Int) async {
        guard let current = activity ?? Activity<FocusLiveActivityAttributes>.activities.first else { return }

        let state = FocusLiveActivityAttributes.ContentState(
            timeRemainingSeconds: 0,
            focusScore: focusScore,
            endDate: nil
        )
        await current.end(
            ActivityContent(state: state, staleDate: nil),
            dismissalPolicy: .immediate
        )
        activity = nil
    }

    private func update(
        timeRemainingSeconds: Int,
        focusScore: Int,
        isPaused: Bool,
        endDate: Date?
    ) async {
        guard let current = activity ?? Activity<FocusLiveActivityAttributes>.activities.first else { return }

        let state = FocusLiveActivityAttributes.ContentState(
            timeRemainingSeconds: timeRemainingSeconds,
            focusScore: focusScore,
            isPaused: isPaused,
            endDate: endDate
        )
        await current.update(ActivityContent(state: state, staleDate: nil))
        activity = current
    }
}
