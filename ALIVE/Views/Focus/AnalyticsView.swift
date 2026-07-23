import SwiftUI
import SwiftData

public struct AnalyticsView: View {
    @Query private var sessions: [StudySession]
    @Query private var courses: [Course]
    @StateObject private var viewModel = AnalyticsViewModel()
    
    public init() {}
    
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
                                    .foregroundColor(.white)
                            }
                        }
                        .glassCard(borderColor: ALIVEColor.healthRed)
                    }
                    
                    // Study Time Distribution Chart Mock/Visual
                    VStack(alignment: .leading, spacing: 12) {
                        Text("WEEKLY STUDY DISTRIBUTION")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 10) {
                            BarRow(label: "Mon", fraction: 0.8, color: ALIVEColor.neonCyan)
                            BarRow(label: "Tue", fraction: 0.5, color: ALIVEColor.xpViolet)
                            BarRow(label: "Wed", fraction: 0.95, color: ALIVEColor.rpgGold)
                            BarRow(label: "Thu", fraction: 0.4, color: ALIVEColor.staminaGreen)
                            BarRow(label: "Fri", fraction: 0.7, color: ALIVEColor.manaBlue)
                            BarRow(label: "Sat", fraction: 0.3, color: ALIVEColor.neonCyan)
                            BarRow(label: "Sun", fraction: 0.6, color: ALIVEColor.rpgGold)
                        }
                    }
                    .glassCard()
                }
                .padding()
            }
        }
        .navigationTitle("INSIGHTS")
        .navigationBarTitleDisplayMode(.inline)
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
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct BarRow: View {
    let label: String
    let fraction: CGFloat
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .frame(width: 35, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 10)
        }
    }
}
