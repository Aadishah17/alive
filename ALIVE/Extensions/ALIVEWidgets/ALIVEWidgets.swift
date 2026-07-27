import ActivityKit
import Foundation
import SwiftUI
import WidgetKit

@main
struct ALIVEWidgets: WidgetBundle {
    var body: some Widget {
        ALIVEHeroWidget()
        ALIVEFocusActivityWidget()
    }
}

private struct ALIVEHeroEntry: TimelineEntry {
    let date: Date
    let snapshot: ALIVEWidgetSnapshot
}

private struct ALIVEHeroTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ALIVEHeroEntry {
        ALIVEHeroEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (ALIVEHeroEntry) -> Void) {
        completion(ALIVEHeroEntry(date: .now, snapshot: ALIVEWidgetSnapshotStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ALIVEHeroEntry>) -> Void) {
        let entry = ALIVEHeroEntry(date: .now, snapshot: ALIVEWidgetSnapshotStore.load())
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }
}

private struct ALIVEHeroWidget: Widget {
    let kind = "ALIVEHeroWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ALIVEHeroTimelineProvider()) { entry in
            ALIVEHeroWidgetView(snapshot: entry.snapshot)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color.indigo, Color.blue.opacity(0.78)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("ALIVE Hero HUD")
        .description("Your level, quest load, and streak at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct ALIVEHeroWidgetView: View {
    let snapshot: ALIVEWidgetSnapshot

    private var progress: Double {
        guard snapshot.requiredXP > 0 else {
            return 0
        }
        return min(max(Double(snapshot.currentXP) / Double(snapshot.requiredXP), 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(snapshot.heroName)
                        .font(.headline)
                        .lineLimit(1)
                    Text("LEVEL \(snapshot.level) HERO")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "shield.fill")
                    .font(.title3)
                    .foregroundStyle(.yellow)
            }

            ProgressView(value: progress)
                .tint(.yellow)

            HStack(spacing: 10) {
                Label("\(snapshot.streakDays)d", systemImage: "flame.fill")
                Label("\(snapshot.pendingQuestCount)", systemImage: "scroll.fill")
                Spacer()
                Text("\(snapshot.currentXP)/\(snapshot.requiredXP) XP")
                    .font(.caption2.monospacedDigit())
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
        }
        .foregroundStyle(.white)
        .widgetURL(URL(string: "alive://open?route=today"))
    }
}

@available(iOSApplicationExtension 16.1, *)
private struct ALIVEFocusActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            FocusActivityLockScreenView(context: context)
                .activityBackgroundTint(Color.indigo.opacity(0.92))
                .activitySystemActionForegroundColor(.white)
                .widgetURL(URL(string: "alive://open?route=focus"))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.cyan)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    FocusActivityTimeLabel(state: context.state)
                        .font(.headline.monospacedDigit())
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.courseName)
                            .lineLimit(1)
                        Spacer()
                        Text(context.state.isCompleted ? "Claim XP" : "Focus +\(context.state.focusScore)")
                            .font(.caption.weight(.semibold))
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
                    .foregroundStyle(.cyan)
            } compactTrailing: {
                FocusActivityTimeLabel(state: context.state)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                Image(systemName: context.state.isCompleted ? "checkmark.circle.fill" : "timer")
                    .foregroundStyle(context.state.isCompleted ? .green : .cyan)
            }
            .widgetURL(URL(string: "alive://open?route=focus"))
        }
    }
}

@available(iOSApplicationExtension 16.1, *)
private struct FocusActivityLockScreenView: View {
    let context: ActivityViewContext<FocusActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: context.state.isCompleted ? "checkmark.seal.fill" : "timer")
                .font(.title2)
                .foregroundStyle(context.state.isCompleted ? .green : .cyan)

            VStack(alignment: .leading, spacing: 3) {
                Text(context.state.isCompleted ? "Focus complete" : context.state.courseName)
                    .font(.headline)
                    .lineLimit(1)
                Text(context.state.isPaused ? "Paused — resume in ALIVE" : "Deep work in progress")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.74))
            }

            Spacer()

            FocusActivityTimeLabel(state: context.state)
                .font(.title3.weight(.bold).monospacedDigit())
        }
        .padding(.horizontal)
    }
}

@available(iOSApplicationExtension 16.1, *)
private struct FocusActivityTimeLabel: View {
    let state: FocusActivityAttributes.ContentState

    var body: some View {
        Group {
            if let endDate = state.endDate, !state.isPaused, !state.isCompleted {
                Text(timerInterval: Date()...endDate, countsDown: true)
            } else {
                Text(Self.formattedTime(state.timeRemainingSeconds))
            }
        }
            .foregroundStyle(state.isCompleted ? .green : .white)
    }

    private static func formattedTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
