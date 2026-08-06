import SwiftUI

public enum ALIVEColor {
    // Crisp Light Backgrounds
    public static let backgroundDark = Color(red: 0.97, green: 0.98, blue: 0.99) // #F8FAFC Canvas
    public static let cardBackground = Color.white
    public static let glassSurface = Color(red: 0.94, green: 0.96, blue: 0.98) // #F1F5F9 Light Slate
    
    // High-Contrast Light Mode Typography
    public static let textPrimary = Color(red: 0.06, green: 0.09, blue: 0.16) // #0F172A Sharp Slate Dark
    public static let textSecondary = Color(red: 0.28, green: 0.34, blue: 0.44) // #475569 Slate Gray
    public static let textMuted = Color(red: 0.58, green: 0.64, blue: 0.72) // #94A3B8 Caption Gray
    
    // Vibrant Accents tailored for Light Canvas
    public static let neonCyan = Color(red: 0.09, green: 0.45, blue: 0.96) // #1773F6 Vivid Royal Blue
    public static let rpgGold = Color(red: 0.85, green: 0.47, blue: 0.02) // #D97706 Amber Gold
    public static let xpViolet = Color(red: 0.49, green: 0.23, blue: 0.93) // #7C3AED Electric Violet
    public static let healthRed = Color(red: 0.88, green: 0.11, blue: 0.28) // #E11D48 Rose Red
    public static let staminaGreen = Color(red: 0.02, green: 0.59, blue: 0.41) // #059669 Emerald Green
    public static let manaBlue = Color(red: 0.01, green: 0.52, blue: 0.78) // #0284C7 Sky Blue
    
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
        colors: [neonCyan.opacity(0.25), xpViolet.opacity(0.15)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

