import SwiftUI

public enum ALIVEColor {
    // Backgrounds
    public static let backgroundDark = Color(red: 0.05, green: 0.07, blue: 0.10)
    public static let cardBackground = Color(red: 0.09, green: 0.12, blue: 0.17).opacity(0.85)
    public static let glassSurface = Color(red: 0.15, green: 0.18, blue: 0.25).opacity(0.60)
    
    // RPG Accent Neons
    public static let neonCyan = Color(red: 0.0, green: 0.94, blue: 1.0)
    public static let rpgGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    public static let xpViolet = Color(red: 0.62, green: 0.31, blue: 0.87)
    public static let healthRed = Color(red: 1.0, green: 0.27, blue: 0.27)
    public static let staminaGreen = Color(red: 0.2, green: 0.88, blue: 0.55)
    public static let manaBlue = Color(red: 0.18, green: 0.55, blue: 1.0)
    
    // Gradients
    public static let xpGradient = LinearGradient(
        colors: [xpViolet, neonCyan],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    public static let goldGradient = LinearGradient(
        colors: [rpgGold, Color(red: 1.0, green: 0.5, blue: 0.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let cardBorderGradient = LinearGradient(
        colors: [neonCyan.opacity(0.5), xpViolet.opacity(0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
