import Foundation

private final class TaskQueue: Sendable {
    
    @MainActor
    private var lastTask: Task<Void, Never>?
    
    @MainActor
    func spawnTask(_ action: @Sendable @escaping () async -> Void) {
        let previousTask = self.lastTask
        self.lastTask = Task(priority: .userInitiated) { [previousTask] in
            if let previousTask {
                await previousTask.value
            }
            
            await action()
        }
    }
    
    func waitForCurrentTaskToComplete() async {
        await self.lastTask?.value
    }
}

private let metricTaskQueue = TaskQueue()

extension Metric {
    
    public func record(_ value: T, in store: AnyMetricStore? = nil) throws {
        let store = store ?? MetricManager.global
        Task { @MainActor in
            metricTaskQueue.spawnTask {
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
