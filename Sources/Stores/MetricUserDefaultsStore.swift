import Foundation

public class MetricUserDefaultsStore: MetricStore {
    public let backingStorage: UserDefaults
    public let userDefaultKey: String
    
    public var inMemoryRepresentation: [MetricEntry] = [] {
        didSet {
            guard let codedEntries = try? JSONEncoder().encode(inMemoryRepresentation) else { return }
            backingStorage.setValue(codedEntries, forKey: userDefaultKey)
        }
    }
    
    public init(userDefaults: UserDefaults, userDefaultKey: String) {
        self.backingStorage = userDefaults
        self.userDefaultKey = userDefaultKey
        try? self.sync()
    }
    
    @inlinable
    public func record<T>(_ metric: Metric<T>, value: T) throws where T: MetricValue {
        let entry = MetricEntry(metric: metric, value: value)
        self.inMemoryRepresentation.append(entry)
    }
    
    @inlinable
    public func retrieveAll(from startDate: Date, until endDate: Date) throws -> [MetricEntry] {
        inMemoryRepresentation.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
    }
    
    @inlinable
    public func sync() throws {
        self.inMemoryRepresentation = {
            if let data = backingStorage.data(forKey: userDefaultKey),
               let cache = try? JSONDecoder().decode([MetricEntry].self, from: data) {
                cache
            } else {
                []
            }
        }()
    }
}

extension MetricStore where Self == MetricUserDefaultsStore {
    public static func userDefaults(_ userDefaults: UserDefaults, key: String) -> MetricUserDefaultsStore {
        MetricUserDefaultsStore(userDefaults: userDefaults, userDefaultKey: key)
    }
}
