import Foundation

@MainActor
extension Metric {
    
    @inlinable
    public func record(_ value: T, in store: AnyMetricStore = MetricManager.global) throws {
        try store.record(self, value: value)
    }
    
    @inlinable
    public func retrieveAll(
        between startDate: Date = Date.distantPast,
        and endDate: Date = Date.distantFuture,
        in store: AnyMetricStore = MetricManager.global
    ) throws -> [ResolvedMetric<T>] {
        try store.retrieveAll(for: self, between: startDate, and: endDate)
    }
}
