import Foundation

public protocol MetricStore: Sendable {
    func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue
    func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry]
    func sync() async throws
}
