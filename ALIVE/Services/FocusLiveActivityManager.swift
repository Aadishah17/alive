import Foundation

#if os(iOS) && canImport(ActivityKit)
import ActivityKit

public actor FocusLiveActivityManager {
    public static let shared = FocusLiveActivityManager()

    private var activity: Activity<FocusActivityAttributes>?

    public func beginOrResume(
        courseName: String,
        targetMinutes: Int,
        timeRemainingSeconds: Int,
        focusScore: Int
    ) async {
        let contentState = FocusActivityAttributes.ContentState(
            courseName: courseName,
            timeRemainingSeconds: timeRemainingSeconds,
            endDate: Date().addingTimeInterval(TimeInterval(timeRemainingSeconds)),
            focusScore: focusScore
        )

        if let activity {
            await activity.update(ActivityContent(
                state: contentState,
                staleDate: contentState.endDate?.addingTimeInterval(60)
            ))
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        let attributes = FocusActivityAttributes(
            sessionName: courseName,
            targetMinutes: targetMinutes
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(
                    state: contentState,
                    staleDate: contentState.endDate?.addingTimeInterval(60)
                ),
                pushType: nil
            )
        } catch {
            activity = nil
        }
    }

    public func update(
        courseName: String,
        timeRemainingSeconds: Int,
        focusScore: Int,
        isPaused: Bool = false,
        isCompleted: Bool = false
    ) async {
        guard let activity else {
            return
        }

        let state = FocusActivityAttributes.ContentState(
            courseName: courseName,
            timeRemainingSeconds: timeRemainingSeconds,
            endDate: isPaused || isCompleted
                ? nil
                : Date().addingTimeInterval(TimeInterval(timeRemainingSeconds)),
            focusScore: focusScore,
            isPaused: isPaused,
            isCompleted: isCompleted
        )
        await activity.update(ActivityContent(
            state: state,
            staleDate: state.endDate?.addingTimeInterval(60)
        ))
    }

    public func end() async {
        guard let activity else {
            return
        }

        await activity.end(nil, dismissalPolicy: .immediate)
        self.activity = nil
    }
}
#else
/// No-op implementation keeps the shared gameplay engine portable to tests and
/// non-iOS platforms while the real implementation is compiled into iOS builds.
public actor FocusLiveActivityManager {
    public static let shared = FocusLiveActivityManager()

    public func beginOrResume(
        courseName: String,
        targetMinutes: Int,
        timeRemainingSeconds: Int,
        focusScore: Int
    ) async {}

    public func update(
        courseName: String,
        timeRemainingSeconds: Int,
        focusScore: Int,
        isPaused: Bool = false,
        isCompleted: Bool = false
    ) async {}

    public func end() async {}
}
#endif
