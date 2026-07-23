import SwiftUI

#if os(iOS)
import UIKit
#endif

public final class HapticManager {
    public static let shared = HapticManager()
    private init() {}
    
    public func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
        #endif
    }
    
    public func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    public func levelUpHaptic() {
        triggerNotification(type: .success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.triggerImpact(style: .heavy)
        }
    }
}
