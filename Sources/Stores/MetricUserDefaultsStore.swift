import Foundation

public final actor MetricUserDefaultsStore: MetricStore {
    @MainActor private var backingStorage: UserDefaults!
    @MainActor private var inMemoryRepresentation: [MetricEntry] = []
    
    private let userDefaultKey: String
    
    @MainActor
    public init(userDefaults: sending UserDefaults, userDefaultKey: String) throws {
        self.backingStorage = userDefaults
        self.userDefaultKey = userDefaultKey
        self.syncSync()
    }
    
    public func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue {
        let entry = MetricEntry(metric: metric, value: value)
        let inMemoryData: [MetricEntry] = await MainActor.run {
            inMemoryRepresentation.append(entry)
            return inMemoryRepresentation
        }
        let data = try JSONEncoder().encode(inMemoryData)
        await MainActor.run {
            backingStorage.setValue(data, forKey: userDefaultKey)
        }
    }
    
    public func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry] {
        let inMemoryData: [MetricEntry] = await MainActor.run {
            inMemoryRepresentation
        }
        return inMemoryData.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
    }
    
    @MainActor
    private func syncSync() {
        let data = backingStorage.data(forKey: userDefaultKey)
        inMemoryRepresentation = if let data, let cache = try? JSONDecoder().decode([MetricEntry].self, from: data) {
            cache
        } else {
            []
        }
    }
    
    public func sync() async throws {
        let data = await Task { @MainActor in
            backingStorage.data(forKey: userDefaultKey)
        }.value
        let decodedData: [MetricEntry] = {
            if let data, let cache = try? JSONDecoder().decode([MetricEntry].self, from: data) {
                cache
            } else {
                []
            }
        }()
        await MainActor.run {
            inMemoryRepresentation = decodedData
        }
    }
}

extension MetricStore where Self == MetricUserDefaultsStore {
    public static func userDefaults(_ userDefaults: sending UserDefaults, key: String) async throws -> MetricUserDefaultsStore {
        try await MetricUserDefaultsStore(userDefaults: userDefaults, userDefaultKey: key)
    }
}
