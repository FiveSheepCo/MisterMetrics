import Foundation

public final actor MetricMemoryStore: MetricStore {
    private var backingStorage: [MetricEntry] = []
    
    public init() {}
    
    public func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue {
        let entry = MetricEntry(metric: metric, value: value)
        backingStorage.append(entry)
    }
    
    public func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry] {
        backingStorage.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
    }
    
    @inlinable
    public func sync() async throws {
        // no-op for in-memory store
    }
}

extension MetricStore where Self == MetricMemoryStore {
    public static func memory() -> MetricMemoryStore {
        MetricMemoryStore()
    }
}
