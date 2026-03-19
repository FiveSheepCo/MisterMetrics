import Foundation

public struct MetricQuery<T>
where T: Codable & Hashable & Sendable {
    let store: MetricStore
}
