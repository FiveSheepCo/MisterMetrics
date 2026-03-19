import Foundation

/// A metric namespace grouping multiple related metrics.
public struct Bucket: Equatable, Hashable, Sendable {
    let name: String
    
    public init(_ name: String) {
        self.name = name
    }
}

extension Bucket: Identifiable {
    public var id: String {
        name
    }
}

extension Bucket: Codable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.name = try container.decode(String.self)
    }
}
