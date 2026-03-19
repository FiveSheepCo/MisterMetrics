import Foundation

public struct AnyMetric: Codable, Equatable, Hashable, Sendable {
    let name: String
    let bucket: Bucket?
    let valueTypeString: String
    
    public init<T>(_ metric: Metric<T>) where T: MetricValue {
        self.name = metric.name
        self.bucket = metric.bucket
        self.valueTypeString = String(describing: T.self)
    }
}
