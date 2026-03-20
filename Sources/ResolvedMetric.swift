import Foundation

public struct ResolvedMetric<T: Decodable>: Sendable where T: MetricValue {
    private let metric: AnyMetric
    
    public let timestamp: Date
    public let value: T
    
    public init(from entry: MetricEntry) {
        self.metric = entry.metric
        self.timestamp = entry.timestamp
        self.value = try! JSONDecoder().decode(T.self, from: entry.value)
    }
}

extension ResolvedMetric: Equatable where T: Equatable {}
extension ResolvedMetric: Hashable where T: Hashable {}

extension ResolvedMetric {
    
    public var name: String {
        metric.name
    }
    
    public var bucket: Bucket? {
        metric.bucket
    }
}
