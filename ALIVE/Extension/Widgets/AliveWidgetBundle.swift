import WidgetKit
import SwiftUI
import ActivityKit

public struct AliveWidgetEntry: TimelineEntry {
    public let date: Date
    public let heroName: String
    let level: Int
    let streak: Int
    let currentXP: Int
    let requiredXP: Int
    let activeQuestsCount: Int
    let safeBunksRemaining: Int
}

public struct AliveWidgetProvider: TimelineProvider {
    public func placeholder(in context: Context) -> AliveWidgetEntry {
        AliveWidgetEntry(
            date: Date(),
            heroName: "Alex Vance",
            level: 8,
            streak: 6,
            currentXP: 450,
            requiredXP: 1000,
            activeQuestsCount: 3,
            safeBunksRemaining: 4
        )
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (AliveWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<AliveWidgetEntry>) -> Void) {
        let entry = placeholder(in: context)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

public struct AliveWidgetEntryView: View {
    var entry: AliveWidgetProvider.Entry
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("A L I V E")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(ALIVEColor.neonCyan)
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(ALIVEColor.rpgGold)
                        Text("\(entry.streak)d")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.heroName)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("LVL \(entry.level) HERO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ALIVEColor.rpgGold)
                    }
                    Spacer()
                }
                
                // Active Quests + Bunks Summary
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "scroll.fill")
                            .foregroundColor(ALIVEColor.xpViolet)
                        Text("\(entry.activeQuestsCount) Quests")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "shield.fill")
                            .foregroundColor(ALIVEColor.staminaGreen)
                        Text("\(entry.safeBunksRemaining) Bunks Safe")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
        }
    }
}

@main
struct AliveWidgetBundle: WidgetBundle {
    var body: some Widget {
        AliveHeroWidget()
        FocusLiveActivityWidget()
    }
}

struct AliveHeroWidget: Widget {
    let kind: String = "AliveHeroWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AliveWidgetProvider()) { entry in
            AliveWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("ALIVE Hero Status")
        .description("View your RPG student level, active quests, and safe bunks on your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FocusLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusLiveActivityAttributes.self) { context in
            HStack(spacing: 12) {
                Image(systemName: context.state.isPaused ? "pause.circle.fill" : "timer.circle.fill")
                    .foregroundColor(ALIVEColor.neonCyan)

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.courseName)
                        .font(.caption)
                        .lineLimit(1)
                    FocusTimerText(state: context.state)
                        .font(.headline.monospacedDigit())
                }

                Spacer()

                Text("\(context.state.focusScore)%")
                    .font(.caption2.bold())
                    .foregroundColor(ALIVEColor.rpgGold)
            }
            .padding(.horizontal)
            .activityBackgroundTint(ALIVEColor.backgroundDark)
            .activitySystemActionForegroundColor(ALIVEColor.neonCyan)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.courseName, systemImage: "timer")
                        .lineLimit(1)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    FocusTimerText(state: context.state)
                        .font(.headline.monospacedDigit())
                }

                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(
                        value: Double(max(0, context.state.timeRemainingSeconds)),
                        total: Double(max(1, context.attributes.totalDurationMinutes * 60))
                    )
                    .tint(ALIVEColor.neonCyan)
                }
            } compactLeading: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
            } compactTrailing: {
                FocusTimerText(state: context.state)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "timer")
            }
            .keylineTint(ALIVEColor.neonCyan)
        }
    }
}

private struct FocusTimerText: View {
    let state: FocusLiveActivityAttributes.ContentState

    var body: some View {
        if let endDate = state.endDate, !state.isPaused {
            Text(timerInterval: Date()...endDate, countsDown: true)
        } else {
            Text(formattedTime)
        }
    }

    private var formattedTime: String {
        String(format: "%02d:%02d", state.timeRemainingSeconds / 60, state.timeRemainingSeconds % 60)
    }
}
