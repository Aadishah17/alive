import SwiftUI

public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var borderColor: Color = ALIVEColor.neonCyan.opacity(0.3)
    
    public func body(content: Content) -> some View {
        content
            .padding()
            .background(ALIVEColor.cardBackground)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: ALIVEColor.neonCyan.opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 16, borderColor: Color = ALIVEColor.neonCyan.opacity(0.3)) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
}
