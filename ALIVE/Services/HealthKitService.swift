import Combine
import Foundation

#if os(iOS) && canImport(HealthKit)
import HealthKit

@MainActor
public final class HealthKitService: ObservableObject {
    @Published public private(set) var stepCount: Int = 0
    @Published public private(set) var isLoading = false
    @Published public private(set) var statusMessage = "Connect Apple Health to power movement quests."
    @Published public private(set) var isHealthDataAvailable: Bool

    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)

    public init() {
        isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
    }

    public func requestAccess() async {
        guard isHealthDataAvailable, let stepType else {
            statusMessage = "Apple Health is not available on this device."
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepType])
            statusMessage = "Health access requested. Refresh to load today’s movement."
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

        isLoading = true
        defer { isLoading = false }

        do {
            stepCount = try await fetchTodayStepCount(for: stepType)
            statusMessage = stepCount > 0
                ? "Your movement is helping build today’s stamina."
                : "No steps yet today. A short walk can complete your movement quest."
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
    @Published public private(set) var stepCount: Int = 0
    @Published public private(set) var isLoading = false
    @Published public private(set) var statusMessage = "Apple Health is available in the iPhone app."
    @Published public private(set) var isHealthDataAvailable = false

    public init() {}

    public func requestAccess() async {}

    public func refreshToday() async {}
}
#endif
