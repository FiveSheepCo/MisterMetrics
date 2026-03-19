import Foundation

extension Bucket {
    
    @inlinable
    public func metric<T>(_ name: String) -> Metric<T> {
        Metric(name: name, in: self)
    }
    
    @inlinable
    public func boolMetric(_ name: String) -> Metric<Bool> {
        self.metric(name)
    }
    
    @inlinable
    public func stringMetric(_ name: String) -> Metric<String> {
        self.metric(name)
    }
    
    @inlinable
    public func intMetric(_ name: String) -> Metric<Int> {
        self.metric(name)
    }
    
    @inlinable
    public func doubleMetric(_ name: String) -> Metric<Double> {
        self.metric(name)
    }
}
