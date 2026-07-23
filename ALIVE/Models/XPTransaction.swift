import Foundation
import SwiftData

@Model
public final class XPTransaction {
    public var id: UUID
    public var source: String // e.g., "Quest: Deep Focus", "Study Session: OS Lab", "Daily Streak Bonus"
    public var amount: Int
    public var timestamp: Date
    
    public init(source: String, amount: Int, timestamp: Date = Date()) {
        self.id = UUID()
        self.source = source
        self.amount = amount
        self.timestamp = timestamp
    }
}
