import SwiftUI
import SwiftData

public struct CharacterCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var authService: AuthService
    @StateObject private var viewModel = AuthViewModel()
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("FORGE YOUR HERO")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(ALIVEColor.neonCyan)
                        
                        Text("Choose your student class archetype to unlock tailored passive buffs.")
                            .font(.subheadline)
                            .foregroundColor(ALIVEColor.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Username Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HERO NAME")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ALIVEColor.rpgGold)
                        
                        TextField("Enter your name...", text: $viewModel.usernameInput)
                            .padding()
                            .background(ALIVEColor.cardBackground)
                            .cornerRadius(12)
                            .foregroundColor(ALIVEColor.textPrimary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(ALIVEColor.neonCyan.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Character Class Carousel / Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SELECT CHARACTER CLASS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ALIVEColor.rpgGold)
                            .padding(.horizontal)
                        
                        ForEach(CharacterClass.allCases) { archetype in
                            ClassCardView(
                                archetype: archetype,
                                isSelected: viewModel.selectedClass == archetype
                            ) {
                                viewModel.selectedClass = archetype
                                HapticManager.shared.triggerImpact(style: .medium)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(ALIVEColor.healthRed)
                    }
                    
                    // Create Hero Button
                    Button {
                        viewModel.createCharacter(context: modelContext, authService: authService)
                    } label: {
                        HStack {
                            Image(systemName: "shield.fill")
                            Text("ENTER THE REALM")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ALIVEColor.goldGradient)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: ALIVEColor.rpgGold.opacity(0.3), radius: 8, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct ClassCardView: View {
    let archetype: CharacterClass
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(archetype.themeColor.opacity(0.15))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: archetype.iconName)
                        .font(.title2)
                        .foregroundColor(archetype.themeColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(archetype.rawValue)
                            .font(.headline)
                            .foregroundColor(ALIVEColor.textPrimary)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ALIVEColor.neonCyan)
                        }
                    }
                    
                    Text(archetype.description)
                        .font(.caption)
                        .foregroundColor(ALIVEColor.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Base Stat Badges
                    HStack(spacing: 12) {
                        StatMiniBadge(title: "INT", value: archetype.baseStats.intelligence, color: ALIVEColor.manaBlue)
                        StatMiniBadge(title: "STM", value: archetype.baseStats.stamina, color: ALIVEColor.staminaGreen)
                        StatMiniBadge(title: "FOC", value: archetype.baseStats.focus, color: ALIVEColor.xpViolet)
                        StatMiniBadge(title: "DIS", value: archetype.baseStats.discipline, color: ALIVEColor.rpgGold)
                    }
                    .padding(.top, 4)
                }
            }
            .glassCard(
                cornerRadius: 16,
                borderColor: isSelected ? archetype.themeColor : Color(red: 0.90, green: 0.92, blue: 0.95)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatMiniBadge: View {
    let title: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
            Text("\(value)")
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(ALIVEColor.textPrimary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}
