import Foundation
import HealthKit
import SwiftUI

@MainActor
public final class HealthKitManager: ObservableObject {
    @Published public private(set) var todayStepCount: Int = 0
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var hasRequestedStepAccess: Bool

    public let dailyStepGoal = 5_000

    private let healthStore = HKHealthStore()
    private let requestedAccessKey = "alive.health.stepAccessRequested"

    public init() {
        hasRequestedStepAccess = UserDefaults.standard.bool(forKey: requestedAccessKey)
    }

    public var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    public var stepProgress: Double {
        min(Double(todayStepCount) / Double(dailyStepGoal), 1)
    }

    public func requestStepAccess() async {
        guard isAvailable, let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            errorMessage = "Apple Health is unavailable on this device."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: [stepType])
            hasRequestedStepAccess = true
            UserDefaults.standard.set(true, forKey: requestedAccessKey)
            await refreshTodayStepCount()
        } catch {
            errorMessage = "Could not request Apple Health access."
        }
    }

    public func refreshTodayStepCount() async {
        guard isAvailable, let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )

        do {
            todayStepCount = try await withCheckedThrowingContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        let steps = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                        continuation.resume(returning: Int(steps))
                    }
                }
                healthStore.execute(query)
            }
        } catch {
            errorMessage = "Could not load today’s step count."
        }
    }
}
