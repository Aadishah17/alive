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
            return "Theory-first build with the strongest starting Intelligence stat."
        case .engineer:
            return "Systems-minded build with the strongest starting Focus stat."
        case .creative:
            return "Idea-driven build with high starting Stamina and Discipline."
        case .strategist:
            return "Planning-oriented build with the strongest starting Discipline stat."
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
