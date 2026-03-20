import Foundation

public final actor MetricFileStore: MetricStore {
    private let file: URL
    
    private var debounceTask: Task<Void, Error>?
    private var debouncedEntries: [MetricEntry] = []
    
    public init(file: URL) throws {
        self.file = file
    }
    
    private func recordBatch(_ batch: [MetricEntry]) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        
        var jsonLines: [Data] = []
        jsonLines.reserveCapacity(batch.count)
        
        for data in batch {
            var jsonData = try encoder.encode(data)
            jsonData.append(contentsOf: [0x0A])
            jsonLines.append(jsonData)
        }
        
        if !FileManager.default.fileExists(atPath: file.path(percentEncoded: false)) {
            FileManager.default.createFile(atPath: file.path(percentEncoded: false), contents: nil)
        }
        
        let handle = try FileHandle(forWritingTo: file)
        defer {
            try? handle.close()
        }
        
        try handle.seekToEnd()
        for jsonLine in jsonLines {
            try handle.write(contentsOf: jsonLine)
        }
    }
    
    public func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue {
        debounceTask?.cancel()
        debounceTask = Task {
            debouncedEntries.append(MetricEntry(metric: metric, value: value))
            try await Task.sleep(for: .milliseconds(250))
            try await recordBatch(debouncedEntries)
            debouncedEntries.removeAll()
        }
    }
    
    public func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry] {
        let handle = try FileHandle(forReadingFrom: file)
        defer {
            try? handle.close()
        }
        
        guard let data = try handle.readToEnd(),
              let dataString = String(data: data, encoding: .utf8)
        else {
            return []
        }
        
        
        let lines = dataString.split(separator: "\n")
        
        var entries: [MetricEntry] = []
        entries.reserveCapacity(lines.count)
        
        let decoder = JSONDecoder()
        for line in dataString.split(separator: "\n") {
            guard let lineData = line.data(using: .utf8),
                  let entry = try? decoder.decode(MetricEntry.self, from: lineData),
                  entry.timestamp >= startDate && entry.timestamp <= endDate
            else {
                continue
            }
            entries.append(entry)
        }
        
        return entries
    }
    
    public func sync() async throws {
        let handle = try FileHandle(forUpdating: file)
        defer {
            try? handle.close()
        }
        
        try handle.synchronize()
    }
}

extension MetricStore where Self == MetricFileStore {
    public static func file(url: URL) throws -> MetricFileStore {
        try MetricFileStore(file: url)
    }
}
