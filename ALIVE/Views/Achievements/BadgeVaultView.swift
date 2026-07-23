import SwiftUI
import SwiftData

public struct BadgeVaultView: View {
    @Query private var achievements: [Achievement]
    
    public init() {}
    
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
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(achievements) { badge in
                            BadgeCardView(badge: badge)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("BADGES")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BadgeCardView: View {
    let badge: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badge.isUnlocked ? badge.rarity.badgeColor.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 64, height: 64)
                
                Circle()
                    .stroke(badge.isUnlocked ? badge.rarity.badgeColor : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 68, height: 68)
                
                Image(systemName: badge.badgeIcon)
                    .font(.title)
                    .foregroundColor(badge.isUnlocked ? badge.rarity.badgeColor : .gray)
            }
            .shadow(color: badge.isUnlocked ? badge.rarity.badgeColor.opacity(0.6) : .clear, radius: 10)
            
            VStack(spacing: 4) {
                Text(badge.title)
                    .font(.headline)
                    .foregroundColor(badge.isUnlocked ? .white : .gray)
                
                Text(badge.rarity.rawValue.uppercased())
                    .font(.system(size: 8, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(badge.rarity.badgeColor.opacity(0.15))
                    .foregroundColor(badge.rarity.badgeColor)
                    .cornerRadius(4)
                
                Text(badge.achievementDescription)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding()
        .glassCard(borderColor: badge.isUnlocked ? badge.rarity.badgeColor.opacity(0.4) : Color.gray.opacity(0.2))
    }
}
