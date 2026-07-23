import Foundation
import WatchConnectivity
import Combine

public final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    public static let shared = WatchConnectivityManager()
    
    @Published public var isWatchAppInstalled: Bool = false
    @Published public var receivedHeroLevel: Int = 1
    @Published public var receivedSafeBunks: Int = 0
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    public func sendHeroDataToWatch(level: Int, safeBunks: Int) {
        guard WCSession.default.isReachable else { return }
        let data: [String: Any] = [
            "level": level,
            "safeBunks": safeBunks,
            "timestamp": Date().timeIntervalSince1960
        ]
        WCSession.default.sendMessage(data, replyHandler: nil)
    }
    
    // WCSessionDelegate required methods
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }
    
    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    #endif
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let level = message["level"] as? Int {
                self.receivedHeroLevel = level
            }
            if let bunks = message["safeBunks"] as? Int {
                self.receivedSafeBunks = bunks
            }
        }
    }
}
