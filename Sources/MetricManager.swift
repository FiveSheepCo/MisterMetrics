import Foundation

@MainActor
public enum MetricManager {
    private static var uncheckedGlobal: AnyMetricStore?
    
    public static var global: AnyMetricStore {
        guard let checkedGlobal = uncheckedGlobal else {
            assertionFailure("Global MetricStore was accessed before being installed. Metrics will not be recorded.")
            return AnyMetricStore(MetricDummyStore())
        }
        return checkedGlobal
    }
    
    public static func installGlobal(_ store: some MetricStore) {
        Self.uncheckedGlobal = AnyMetricStore(store)
    }
}
