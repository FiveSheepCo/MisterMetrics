import Foundation

extension MetricStore {
    
    @inlinable
    public func retrieveAll<T>(
        for metric: Metric<T>,
        from startDate: Date = .distantPast,
        until endDate: Date = .distantFuture
    ) throws -> [ResolvedMetric<T>] {
        let targetMetric = AnyMetric(metric)
        let allMetrics = try retrieveAll(from: startDate, until: endDate)
        return allMetrics
            .filter { entry in entry.metric == targetMetric }
            .map { compatibleEntry in ResolvedMetric<T>(from: compatibleEntry) }
    }
}
