import Foundation

public struct Metric<T>: Equatable, Hashable, Sendable where T: MetricValue {
    public let name: String
    public let bucket: Bucket?
    
    public init(name: String, in bucket: Bucket? = nil) {
        self.name = name
        self.bucket = bucket
    }
}

extension Metric {
    public var erased: AnyMetric {
        AnyMetric(self)
    }
}
