import Foundation

public struct MetricNoopStore: MetricStore, Sendable {
    public init() {}
    
    public func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue {
    }
    
    public func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry] {
        return []
    }
    
    public func sync() async throws {
    }
}

extension MetricStore where Self == MetricNoopStore {
    public static func noop() -> MetricNoopStore {
        MetricNoopStore()
    }
}
