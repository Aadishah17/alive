import SwiftUI
import SwiftData

public struct AnalyticsView: View {
    @Query private var sessions: [StudySession]
    @Query private var courses: [Course]
    @Query private var skills: [SkillNode]
    private let viewModel = AnalyticsViewModel()
    
    public init() {}

    private var weeklyMetrics: [WeeklyStudyMetric] {
        viewModel.weeklyStudyMetrics(sessions: sessions)
    }

    private var weeklyPeakMinutes: Int {
        max(weeklyMetrics.map(\.minutes).max() ?? 0, 1)
    }
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header Stats Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("STUDY & HEALTH ANALYTICS")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(ALIVEColor.neonCyan)
                        
                        HStack(spacing: 12) {
                            MetricBox(
                                title: "TOTAL STUDY",
                                value: String(format: "%.1fh", viewModel.totalStudyHours(sessions: sessions)),
                                icon: "clock.fill",
                                color: ALIVEColor.rpgGold
                            )
                            MetricBox(
                                title: "AVG FOCUS",
                                value: "\(Int(viewModel.averageFocusScore(sessions: sessions)))%",
                                icon: "brain.head.profile",
                                color: ALIVEColor.xpViolet
                            )
                            MetricBox(
                                title: "ATTENDANCE",
                                value: "\(Int(viewModel.overallAttendanceHealth(courses: courses)))%",
                                icon: "shield.fill",
                                color: ALIVEColor.staminaGreen
                            )
                        }
                    }
                    
                    // Burnout Warning Banner
                    if viewModel.isBurnoutRiskHigh(sessions: sessions, courses: courses) {
                        HStack {
                            Image(systemName: "flame.circle.fill")
                                .font(.title)
                                .foregroundColor(ALIVEColor.healthRed)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("HIGH BURNOUT RISK DETECTED")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(ALIVEColor.healthRed)
                                Text("You logged heavy study hours while missing attendance. Take a 15-minute restorative rest break.")
                                    .font(.footnote)
                                    .foregroundColor(ALIVEColor.textPrimary)
                            }
                        }
                        .glassCard(borderColor: ALIVEColor.healthRed.opacity(0.3))
                    }
                    
                    // Study Time Distribution Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WEEKLY STUDY DISTRIBUTION")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ALIVEColor.textMuted)
                        
                        if !ProgressionModifierEngine.isUnlocked(
                            ProgressionModifierEngine.examClairvoyance,
                            in: skills
                        ) {
                            Label(
                                "Unlock Exam Clairvoyance in the skill tree to reveal your seven-day study pattern.",
                                systemImage: "lock.fill"
                            )
                            .font(.footnote)
                            .foregroundStyle(ALIVEColor.textSecondary)
                        } else if weeklyMetrics.allSatisfy({ $0.minutes == 0 }) {
                            Text("Your completed focus sessions will appear here over the next seven days.")
                                .font(.footnote)
                                .foregroundStyle(ALIVEColor.textSecondary)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(Array(weeklyMetrics.enumerated()), id: \.element.id) { index, metric in
                                    BarRow(
                                        label: metric.label,
                                        value: "\(metric.minutes)m",
                                        fraction: Double(metric.minutes) / Double(weeklyPeakMinutes),
                                        color: chartColor(for: index)
                                    )
                                }
                            }
                        }
                    }
                    .glassCard()
                }
                .padding()
            }
        }
        .navigationTitle("INSIGHTS")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func chartColor(for index: Int) -> Color {
        let colors = [
            ALIVEColor.neonCyan,
            ALIVEColor.xpViolet,
            ALIVEColor.rpgGold,
            ALIVEColor.staminaGreen,
            ALIVEColor.manaBlue
        ]
        return colors[index % colors.count]
    }
}

struct MetricBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .fontWeight(.black)
                .foregroundColor(ALIVEColor.textPrimary)
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(ALIVEColor.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct BarRow: View {
    let label: String
    let value: String
    let fraction: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(ALIVEColor.textSecondary)
                .frame(width: 35, alignment: .leading)

            Text(value)
                .font(.caption2.monospacedDigit())
                .foregroundColor(ALIVEColor.textMuted)
                .frame(width: 35, alignment: .trailing)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(red: 0.88, green: 0.91, blue: 0.95))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * min(max(fraction, 0), 1))
                }
            }
            .frame(height: 10)
        }
    }
}
