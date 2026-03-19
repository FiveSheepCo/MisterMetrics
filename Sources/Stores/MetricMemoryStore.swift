import Foundation

public class MetricMemoryStore: MetricStore {
    public var backingStorage: [MetricEntry] = []
    
    public init() {}
    
    @inlinable
    public func record<T>(_ metric: Metric<T>, value: T) throws where T: MetricValue {
        let entry = MetricEntry(metric: metric, value: value)
        backingStorage.append(entry)
    }
    
    @inlinable
    public func retrieveAll(between startDate: Date, and endDate: Date) -> [MetricEntry] {
        backingStorage.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
    }
}

extension MetricStore where Self == MetricMemoryStore {
    public static func memory() -> MetricMemoryStore {
        MetricMemoryStore()
    }
}
