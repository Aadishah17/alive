import SwiftUI

public enum ALIVEColor {
    // Minimalist Light Backgrounds
    public static let backgroundDark = Color(red: 0.97, green: 0.98, blue: 0.99) // #F8FAFC Soft off-white canvas
    public static let cardBackground = Color.white
    public static let glassSurface = Color(red: 0.93, green: 0.95, blue: 0.98) // #EEF2F6 Soft light slate
    
    // Typography Colors
    public static let textPrimary = Color(red: 0.06, green: 0.09, blue: 0.16) // #0F172A Dark Slate
    public static let textSecondary = Color(red: 0.39, green: 0.45, blue: 0.55) // #64748B Slate Gray
    public static let textMuted = Color(red: 0.58, green: 0.64, blue: 0.72) // #94A3B8 Caption Gray
    
    // Minimalist Vibrant Accents
    public static let neonCyan = Color(red: 0.14, green: 0.44, blue: 0.96) // #2470F5 Royal Indigo Blue
    public static let rpgGold = Color(red: 0.85, green: 0.48, blue: 0.02) // #D97A02 Warm Honey Gold
    public static let xpViolet = Color(red: 0.48, green: 0.23, blue: 0.93) // #7A3BF0 Deep Violet
    public static let healthRed = Color(red: 0.93, green: 0.23, blue: 0.23) // #EF3B3B Coral Red
    public static let staminaGreen = Color(red: 0.05, green: 0.65, blue: 0.43) // #0DA66E Emerald Green
    public static let manaBlue = Color(red: 0.01, green: 0.52, blue: 0.78) // #0384C7 Sky Blue
    
    // Gradients
    public static let xpGradient = LinearGradient(
        colors: [xpViolet, neonCyan],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    public static let goldGradient = LinearGradient(
        colors: [rpgGold, Color(red: 0.95, green: 0.60, blue: 0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardBorderGradient = LinearGradient(
        colors: [neonCyan.opacity(0.3), xpViolet.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

