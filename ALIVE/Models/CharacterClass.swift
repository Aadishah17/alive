import Foundation
import SwiftUI

public enum CharacterClass: String, Codable, CaseIterable, Identifiable {
    case scholar = "Scholar"
    case engineer = "Tech Architect"
    case creative = "Creative Visionary"
    case strategist = "Academic Strategist"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .scholar: return "book.fill"
        case .engineer: return "cpu.fill"
        case .creative: return "paintpalette.fill"
        case .strategist: return "lightbulb.fill"
        }
    }
    
    public var description: String {
        switch self {
        case .scholar:
            return "Master of theory and deep literature research. +15% XP bonus on long reading and study sessions."
        case .engineer:
            return "Architect of complex systems and code logic. +15% XP bonus on lab assignments and project focus timers."
        case .creative:
            return "Designer of visual ideas and creative concepts. High Stamina and +20% bonus on streak retention."
        case .strategist:
            return "Tactician of exam planning and attendance optimization. Never misses a safe bunk calculation."
        }
    }
    
    public var baseStats: (intelligence: Int, stamina: Int, focus: Int, discipline: Int) {
        switch self {
        case .scholar: return (18, 12, 16, 14)
        case .engineer: return (16, 14, 18, 12)
        case .creative: return (14, 16, 14, 16)
        case .strategist: return (15, 13, 15, 17)
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .scholar: return ALIVEColor.manaBlue
        case .engineer: return ALIVEColor.neonCyan
        case .creative: return ALIVEColor.xpViolet
        case .strategist: return ALIVEColor.rpgGold
        }
    }
}
