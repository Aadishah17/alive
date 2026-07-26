import SwiftUI

public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var borderColor: Color = Color(red: 0.90, green: 0.92, blue: 0.95)
    
    public func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 16, borderColor: Color = Color(red: 0.90, green: 0.92, blue: 0.95)) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
}

