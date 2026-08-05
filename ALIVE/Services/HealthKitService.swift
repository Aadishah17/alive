import Combine
import Foundation

#if os(iOS) && canImport(HealthKit)
import HealthKit

/// The single source of truth for ALIVE's optional step-count integration.
/// Consent is tracked locally because HealthKit intentionally does not expose
/// a reliable read-authorization status to the app.
@MainActor
public final class HealthKitService: ObservableObject {
    @Published public private(set) var stepCount = 0
    @Published public private(set) var isLoading = false
    @Published public private(set) var statusMessage = "Connect Apple Health to power movement quests."
    @Published public private(set) var isHealthDataAvailable: Bool
    @Published public private(set) var hasRequestedStepAccess: Bool

    public let dailyStepGoal = 5_000

    private static let requestedAccessKey = "alive.health.stepAccessRequested"
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)

    public init() {
        isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        hasRequestedStepAccess = UserDefaults.standard.bool(forKey: Self.requestedAccessKey)
    }

    public var stepProgress: Double {
        min(Double(stepCount) / Double(dailyStepGoal), 1)
    }

    public func requestAccess() async {
        guard isHealthDataAvailable, let stepType else {
            statusMessage = "Apple Health is not available on this device."
            return
        }

        isLoading = true
        statusMessage = "Requesting Apple Health access…"
        defer { isLoading = false }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepType])
            hasRequestedStepAccess = true
            UserDefaults.standard.set(true, forKey: Self.requestedAccessKey)
            await refreshToday()
        } catch {
            statusMessage = "Apple Health access could not be requested."
        }
    }

    public func refreshToday() async {
        guard isHealthDataAvailable, let stepType else {
            statusMessage = "Step count is not available on this device."
            return
        }

        guard hasRequestedStepAccess else {
            statusMessage = "Connect Apple Health to load today’s movement."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            stepCount = try await fetchTodayStepCount(for: stepType)
            statusMessage = stepCount >= dailyStepGoal
                ? "Movement quest ready—claim your Stamina Maintenance quest from the board."
                : "Your movement is helping build today’s stamina."
        } catch {
            statusMessage = "Unable to load today’s steps. Check Apple Health permissions."
        }
    }

    private func fetchTodayStepCount(for stepType: HKQuantityType) async throws -> Int {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let steps = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            healthStore.execute(query)
        }
    }
}
#else
@MainActor
public final class HealthKitService: ObservableObject {
    @Published public private(set) var stepCount = 0
    @Published public private(set) var isLoading = false
    @Published public private(set) var statusMessage = "Apple Health is available in the iPhone app."
    @Published public private(set) var isHealthDataAvailable = false
    @Published public private(set) var hasRequestedStepAccess = false

    public let dailyStepGoal = 5_000

    public init() {}

    public var stepProgress: Double { 0 }

    public func requestAccess() async {}

    public func refreshToday() async {}
}
#endif
