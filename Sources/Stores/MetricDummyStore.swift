import Foundation

public struct MetricDummyStore: MetricStore {
    public init() {}
    
    public func record<T>(_ metric: Metric<T>, value: T) throws where T: MetricValue {
    }
    
    public func retrieveAll(from startDate: Date, until endDate: Date) throws -> [MetricEntry] {
        return []
    }
}

extension MetricStore where Self == MetricDummyStore {
    public static func dummy() -> MetricDummyStore {
        MetricDummyStore()
    }
}
