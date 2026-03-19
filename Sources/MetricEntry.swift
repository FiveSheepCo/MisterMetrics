import Foundation

public struct MetricEntry: Codable {
    public let timestamp: Date
    public let metric: AnyMetric
    public let value: Data
    
    public init<T>(timestamp: Date = .now, metric: Metric<T>, value: T) {
        self.timestamp = timestamp
        self.metric = AnyMetric(metric)
        self.value = try! JSONEncoder().encode(value)
    }
}
