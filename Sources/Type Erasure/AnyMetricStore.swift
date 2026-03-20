import Foundation

public struct AnyMetricStore: MetricStore, Sendable {
    private let box: any MetricStore
    
    public init(_ store: some MetricStore) {
        self.box = store
    }
    
    public func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue {
        try await box.record(metric, value: value)
    }
    
    public func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry] {
        try await box.retrieveAll(from: startDate, until: endDate)
    }
    
    public func sync() async throws {
        try await box.sync()
    }
}
