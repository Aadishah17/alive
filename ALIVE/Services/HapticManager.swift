import SwiftUI

#if os(iOS)
import UIKit
#endif

public enum HapticImpactStyle {
    case light, medium, heavy, soft, rigid
    
    #if os(iOS)
    var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        case .soft: return .soft
        case .rigid: return .rigid
        }
    }
    #endif
}

public enum HapticNotificationType {
    case success, warning, error
    
    #if os(iOS)
    var uiType: UINotificationFeedbackGenerator.FeedbackType {
        switch self {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }
    #endif
}

public final class HapticManager {
    public static let shared = HapticManager()
    private init() {}
    
    public func triggerNotification(type: HapticNotificationType) {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type.uiType)
        #endif
    }
    
    public func triggerImpact(style: HapticImpactStyle = .medium) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: style.uiStyle)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    public func levelUpHaptic() {
        triggerNotification(type: .success)
        #if os(iOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.triggerImpact(style: .heavy)
        }
        #endif
    }
}

