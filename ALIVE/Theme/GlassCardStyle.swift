import SwiftUI

public struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var borderColor: Color = Color(red: 0.90, green: 0.92, blue: 0.95)
    var isInteractive: Bool = false
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content
                .padding()
                .glassEffect(
                    .regular
                        .tint(borderColor.opacity(0.12))
                        .interactive(isInteractive),
                    in: .rect(cornerRadius: cornerRadius)
                )
        } else {
            content
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
        }
    }
}

public extension View {
    func glassCard(
        cornerRadius: CGFloat = 16,
        borderColor: Color = Color(red: 0.90, green: 0.92, blue: 0.95),
        isInteractive: Bool = false
    ) -> some View {
        self.modifier(
            GlassCardModifier(
                cornerRadius: cornerRadius,
                borderColor: borderColor,
                isInteractive: isInteractive
            )
        )
    }
}
