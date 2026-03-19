import Foundation

public protocol MetricStore {
    func record<T>(_ metric: Metric<T>, value: T) throws where T: MetricValue
    func retrieveAll(between startDate: Date, and endDate: Date) throws -> [MetricEntry]
}
