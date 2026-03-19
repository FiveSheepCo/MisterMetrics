import Foundation

public protocol MetricStore {
    func record<T>(_ metric: Metric<T>, value: T) throws where T: MetricValue
    func retrieveAll(from startDate: Date, until endDate: Date) throws -> [MetricEntry]
    func sync() throws
}
