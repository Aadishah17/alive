import SwiftUI
import SwiftData

public struct BadgeVaultView: View {
    @Query private var achievements: [Achievement]
    @State private var appeared = false
    
    public init() {}
    
    private var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("ACHIEVEMENT VAULT")
                            .font(.system(size: 20, weight: .black, design: .monospaced))
                            .foregroundColor(ALIVEColor.rpgGold)
                        
                        Text("Unlock rare badges by achieving study milestones and perfect attendance.")
                            .font(.caption)
                            .foregroundColor(ALIVEColor.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        // Progress indicator
                        HStack(spacing: 6) {
                            Text("\(unlockedCount)/\(achievements.count)")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                                .foregroundColor(ALIVEColor.rpgGold)
                            Text("UNLOCKED")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(ALIVEColor.textMuted)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.top, 10)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : -10)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Array(achievements.enumerated()), id: \.element.id) { index, badge in
                            BadgeCardView(badge: badge)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.08),
                                    value: appeared
                                )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("BADGES")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }
}

struct BadgeCardView: View {
    let badge: Achievement
    @State private var isFlipped = false
    @State private var legendarySparkle = false
    
    var body: some View {
        Button {
            if badge.isUnlocked {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isFlipped.toggle()
                }
                HapticManager.shared.triggerImpact(style: .light)
            }
        } label: {
            ZStack {
                // Front face
                frontFace
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                
                // Back face (details)
                backFace
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .buttonStyle(.plain)
    }
    
    private var frontFace: some View {
        VStack(spacing: 12) {
            ZStack {
                // Sparkle effect for legendary badges
                if badge.isUnlocked && badge.rarity == .legendary {
                    Circle()
                        .fill(badge.rarity.badgeColor.opacity(legendarySparkle ? 0.25 : 0.05))
                        .frame(width: 80, height: 80)
                        .blur(radius: 10)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                legendarySparkle = true
                            }
                        }
                }
                
                Circle()
                    .fill(badge.isUnlocked ? badge.rarity.badgeColor.opacity(0.15) : ALIVEColor.glassSurface)
                    .frame(width: 64, height: 64)
                
                Circle()
                    .stroke(badge.isUnlocked ? badge.rarity.badgeColor : ALIVEColor.textMuted.opacity(0.3), lineWidth: 2)
                    .frame(width: 68, height: 68)
                
                Image(systemName: badge.badgeIcon)
                    .font(.title)
                    .foregroundColor(badge.isUnlocked ? badge.rarity.badgeColor : ALIVEColor.textMuted)
            }
            .shadow(color: badge.isUnlocked ? badge.rarity.badgeColor.opacity(0.3) : .clear, radius: 8)
            
            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.headline)
                    .foregroundColor(badge.isUnlocked ? ALIVEColor.textPrimary : ALIVEColor.textMuted)
                
                Text(badge.rarity.rawValue.uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(badge.rarity.badgeColor.opacity(0.12))
                    .foregroundColor(badge.rarity.badgeColor)
                    .cornerRadius(4)
                
                Text(badge.achievementDescription)
                    .font(.caption2)
                    .foregroundColor(ALIVEColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding()
        .glassCard(borderColor: badge.isUnlocked ? badge.rarity.badgeColor.opacity(0.3) : ALIVEColor.glassSurface)
    }
    
    private var backFace: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.badgeIcon)
                .font(.largeTitle)
                .foregroundColor(badge.rarity.badgeColor)
            
            Text(badge.title)
                .font(.headline)
                .foregroundColor(ALIVEColor.textPrimary)
            
            Divider()
                .background(badge.rarity.badgeColor.opacity(0.3))
            
            Text(badge.achievementDescription)
                .font(.caption)
                .foregroundColor(ALIVEColor.textSecondary)
                .multilineTextAlignment(.center)
            
            if let date = badge.unlockedDate {
                Text("UNLOCKED \(date.formatted(.dateTime.month(.abbreviated).day()))")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(badge.rarity.badgeColor)
                    .padding(.top, 4)
            }
            
            Text("TAP TO FLIP BACK")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(ALIVEColor.textMuted)
        }
        .padding()
        .glassCard(borderColor: badge.rarity.badgeColor.opacity(0.4))
    }
}
