import SwiftUI

public struct CharacterHUDHeader: View {
    let profile: UserProfile
    let onAllocateTap: () -> Void
    
    public var body: some View {
        VStack(spacing: 16) {
            // Top Row: Avatar + Username + Class + Streak
            HStack(spacing: 14) {
                // Avatar Frame
                ZStack {
                    Circle()
                        .fill(profile.characterClass.themeColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .stroke(profile.characterClass.themeColor, lineWidth: 2)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: profile.avatarIdentifier)
                        .font(.system(size: 30))
                        .foregroundColor(profile.characterClass.themeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(profile.username)
                            .font(.title3)
                            .fontWeight(.black)
                            .foregroundColor(ALIVEColor.textPrimary)
                        
                        Text("LVL \(profile.level)")
                            .font(.system(size: 11, weight: .heavy))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(ALIVEColor.goldGradient)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Text(profile.characterClass.rawValue)
                        .font(.subheadline)
                        .foregroundColor(ALIVEColor.neonCyan)
                }
                
                Spacer()
                
                // Streak Counter Badge
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(ALIVEColor.rpgGold)
                        Text("\(profile.streakDays)")
                            .font(.headline)
                            .fontWeight(.black)
                            .foregroundColor(ALIVEColor.textPrimary)
                    }
                    Text("DAY STREAK")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(ALIVEColor.textMuted)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(ALIVEColor.glassSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ALIVEColor.rpgGold.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Middle Row: XP Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("XP PROGRESS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(ALIVEColor.xpViolet)
                    
                    Spacer()
                    
                    Text("\(profile.currentXP) / \(profile.requiredXPForNextLevel) XP")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(ALIVEColor.textSecondary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.88, green: 0.91, blue: 0.95))
                            .frame(height: 12)
                        
                        Capsule()
                            .fill(ALIVEColor.xpGradient)
                            .frame(width: max(0, min(geo.size.width * CGFloat(profile.xpProgressFraction), geo.size.width)), height: 12)
                            .shadow(color: ALIVEColor.neonCyan.opacity(0.3), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 12)
            }
            
            // Bottom Row: Primary RPG Stat Bar & Unallocated Points Alert
            HStack(spacing: 8) {
                StatPill(icon: "brain.head.profile", label: "INT", val: profile.intelligence, color: ALIVEColor.manaBlue)
                StatPill(icon: "bolt.fill", label: "STM", val: profile.stamina, color: ALIVEColor.staminaGreen)
                StatPill(icon: "eye.fill", label: "FOC", val: profile.focus, color: ALIVEColor.xpViolet)
                StatPill(icon: "shield.fill", label: "DIS", val: profile.discipline, color: ALIVEColor.rpgGold)
            }
            
            if profile.unallocatedStatPoints > 0 {
                Button(action: onAllocateTap) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("\(profile.unallocatedStatPoints) STAT POINTS AVAILABLE")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(ALIVEColor.rpgGold)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .glassCard()
    }
}

struct StatPill: View {
    let icon: String
    let label: String
    let val: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(ALIVEColor.textMuted)
            Text("\(val)")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(ALIVEColor.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.08))
        .cornerRadius(8)
    }
}
