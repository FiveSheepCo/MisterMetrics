import Foundation

public struct AnyMetricStore: MetricStore {
    private let box: any MetricStore
    
    public init(_ store: some MetricStore) {
        self.box = store
    }
    
    public func record<T>(_ metric: Metric<T>, value: T) throws where T: MetricValue {
        try box.record(metric, value: value)
    }
    
    public func retrieveAll(from startDate: Date, until endDate: Date) throws -> [MetricEntry] {
        try box.retrieveAll(from: startDate, until: endDate)
    }
    
    public func sync() throws {
        try box.sync()
    }
}
