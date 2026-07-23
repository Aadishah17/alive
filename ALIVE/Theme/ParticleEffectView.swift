import SwiftUI

public struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    let particleCount: Int
    let color: Color
    
    public init(particleCount: Int = 25, color: Color = ALIVEColor.rpgGold) {
        self.particleCount = particleCount
        self.color = color
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                }
            }
            .onAppear {
                spawnParticles(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func spawnParticles(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        particles = (0..<particleCount).map { _ in
            let angle = Double.random(in: 0...(.pi * 2))
            let speed = CGFloat.random(in: 40...160)
            let targetX = center.x + cos(angle) * speed
            let targetY = center.y + sin(angle) * speed
            
            return Particle(
                position: center,
                targetPosition: CGPoint(x: targetX, y: targetY),
                color: [ALIVEColor.rpgGold, ALIVEColor.neonCyan, ALIVEColor.xpViolet].randomElement()!,
                size: CGFloat.random(in: 4...10),
                opacity: 1.0,
                scale: 0.2
            )
        }
        
        withAnimation(.easeOut(duration: 1.2)) {
            for i in particles.indices {
                particles[i].position = particles[i].targetPosition
                particles[i].opacity = 0.0
                particles[i].scale = 1.5
            }
        }
    }
}

public struct Particle: Identifiable {
    public let id = UUID()
    var position: CGPoint
    var targetPosition: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
}
