import Foundation

public enum MetricManager {
    private nonisolated(unsafe) static var uncheckedGlobal: AnyMetricStore?
    
    public static var global: AnyMetricStore {
        guard let checkedGlobal = uncheckedGlobal else {
            assertionFailure("Global MetricStore was accessed before being installed. Metrics will not be recorded.")
            return AnyMetricStore(MetricNoopStore())
        }
        return checkedGlobal
    }
    
    @MainActor
    public static func installGlobal(_ store: sending some MetricStore) {
        Self.uncheckedGlobal = AnyMetricStore(store)
    }
}
