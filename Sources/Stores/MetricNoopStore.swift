import Foundation

public struct MetricNoopStore: MetricStore, Sendable {
    public init() {}
    
    @inlinable @inline(__always)
    public func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue {
    }
    
    @inlinable @inline(__always)
    public func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry] {
        return []
    }
    
    @inlinable @inline(__always)
    public func sync() async throws {
    }
    
    @inlinable @inline(__always)
    public func clear() async throws {
    }
}

extension MetricStore where Self == MetricNoopStore {
    public static func noop() -> MetricNoopStore {
        MetricNoopStore()
    }
}
