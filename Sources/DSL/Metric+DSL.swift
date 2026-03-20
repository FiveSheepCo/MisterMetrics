import Foundation

private let metricTaskQueue = TaskQueue()

extension Metric {
    
    public func record(_ value: T, in store: AnyMetricStore? = nil) throws {
        let store = store ?? MetricManager.global
        Task { @MainActor in
            await metricTaskQueue.spawnTask {
                try? await store.record(self, value: value)
            }
        }
    }
    
    @inlinable
    public func retrieveAll(
        from startDate: Date = Date.distantPast,
        until endDate: Date = Date.distantFuture,
        in store: AnyMetricStore? = nil
    ) async throws -> [ResolvedMetric<T>] {
        let store = store ?? MetricManager.global
        return try await store.retrieveAll(for: self, from: startDate, until: endDate)
    }
}
