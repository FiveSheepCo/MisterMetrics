# MisterMetrics

`MisterMetrics` is a small typed metrics package for app-local instrumentation.

You define metrics once, install a store early in app startup, and then record values with:

```swift
Metrics.startupTimeMs.record(startupTime)
```

Metrics are strongly typed, can be grouped into buckets, and can be backed by different stores such as a file, `UserDefaults`, memory, or a noop sink.

## Requirements

- Swift 6
- iOS 17+
- macOS 13+

## Core idea

The package revolves around four types:

- `Metric<T>`: a typed metric definition
- `Bucket`: an optional namespace for related metrics
- `MetricStore`: a storage backend
- `MetricManager`: installs a global store used by the convenience recording API

`T` can be any `Codable & Sendable` type, not just primitives.

## Basic setup

Define your metrics in one place:

```swift
import Foundation
import MisterMetrics

@MainActor
enum Metrics {
}

extension Metrics {
    static func setup() {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup
        ), let store = try? MetricFileStore(
            file: containerURL.appendingPathComponent("metrics.jsonl")
        ) else {
            return
        }

        MetricManager.installGlobal(store)
    }
}

extension Metrics {
    static let app = Bucket("app")

    static let startupTimeMs = app.doubleMetric("startup_time_ms")
    static let languageHelperSetupTimeMs = app.doubleMetric("language_helper_setup_time_ms")
    static let launchedFromColdStart = app.boolMetric("launched_from_cold_start")
}
```

Call setup as early as possible:

```swift
Metrics.setup()
```

Then record values anywhere:

```swift
let startupTime = 428.5
Metrics.startupTimeMs.record(startupTime)
Metrics.launchedFromColdStart.record(true)
```

## Defining metrics

### Bucketed metrics

Buckets are lightweight namespaces:

```swift
let app = Bucket("app")

let startupTimeMs = app.doubleMetric("startup_time_ms")
let launchCount = app.intMetric("launch_count")
let locale = app.stringMetric("locale")
let wasColdStart = app.boolMetric("was_cold_start")
```

The DSL helpers are:

- `metric(_:)`
- `boolMetric(_:)`
- `stringMetric(_:)`
- `intMetric(_:)`
- `doubleMetric(_:)`

### Custom value types

Any `Codable & Sendable` type can be recorded:

```swift
struct StartupBreakdown: Codable, Sendable {
    let totalMs: Double
    let languageSetupMs: Double
    let databaseOpenMs: Double
}

let app = Bucket("app")
let startupBreakdown: Metric<StartupBreakdown> = app.metric("startup_breakdown")
```

### Metrics without a bucket

If you do not want a namespace, create the metric directly:

```swift
let buildNumber = Metric<Int>(name: "build_number")
```

## Installing a store

The convenience `metric.record(...)` API uses `MetricManager.global`.

Install a global store on the main actor:

```swift
@MainActor
func setupMetrics() {
    let store = MetricMemoryStore()
    MetricManager.installGlobal(store)
}
```

If you call `record(...)` before installing a global store, the package falls back to a noop store and the metric is discarded.

## Store types

### `MetricFileStore`

Persists metrics as JSON Lines in a file.

```swift
let store = try MetricFileStore(
    file: fileURL.appendingPathComponent("metrics.jsonl")
)
MetricManager.installGlobal(store)
```

Use this when you want a durable append-only log, such as a file in an app group container.

Notes:

- Writes are debounced for about 250 ms before they are appended.
- Each line is one encoded `MetricEntry`.

### `MetricUserDefaultsStore`

Persists metrics in `UserDefaults` under a single key.

```swift
let store = try await MetricUserDefaultsStore(
    userDefaults: .standard,
    userDefaultKey: "metrics"
)
MetricManager.installGlobal(store)
```

Use this for small amounts of simple local persistence.

### `MetricMemoryStore`

Stores metrics in memory only.

```swift
let store = MetricMemoryStore()
```

Useful for tests, previews, or temporary instrumentation.

### `MetricNoopStore`

Drops all metrics.

```swift
let store = MetricNoopStore()
```

Useful when you want to keep instrumentation call sites without persisting anything.

## Recording metrics

The simplest API is fire-and-forget:

```swift
Metrics.startupTimeMs.record(428.5)
```

You can also provide a specific type-erased store:

```swift
let store = MetricMemoryStore()
Metrics.startupTimeMs.record(428.5, in: store.erased)
```

If you need deterministic persistence, use the store directly instead of the convenience method:

```swift
let store = MetricMemoryStore()
try await store.record(Metrics.startupTimeMs, value: 428.5)
```

That matters because `Metric.record(...)` schedules work asynchronously and returns immediately.

## Reading metrics

### Read all samples for one metric

```swift
let samples = try await Metrics.startupTimeMs.retrieveAll()

for sample in samples {
    print(sample.timestamp, sample.value)
}
```

This returns `[ResolvedMetric<T>]`, which includes:

- `timestamp`
- `value`
- `name`
- `bucket`

### Filter by date range

```swift
let samples = try await Metrics.startupTimeMs.retrieveAll(
    from: startDate,
    until: endDate
)
```

### Read from a specific store

```swift
let store = MetricMemoryStore()
try await store.record(Metrics.startupTimeMs, value: 428.5)

let samples = try await store.retrieveAll(for: Metrics.startupTimeMs)
```

### Read raw entries

If you want the untyped stored data:

```swift
let entries = try await store.retrieveAll(from: .distantPast, until: .distantFuture)
```

This returns `[MetricEntry]`.

## `sync()`

Every store exposes:

```swift
try await store.sync()
```

`sync()` is store-specific:

- `MetricMemoryStore`: no-op
- `MetricNoopStore`: no-op
- `MetricUserDefaultsStore`: refreshes its in-memory cache from `UserDefaults`
- `MetricFileStore`: asks the file handle to synchronize

Do not treat `sync()` as a universal "flush all pending `record(...)` calls" operation. If you need strict ordering, record directly on the store with `try await store.record(...)`.

## Implementing a custom store

Custom backends conform to `MetricStore`:

```swift
public protocol MetricStore: Sendable {
    func record<T>(_ metric: Metric<T>, value: T) async throws where T: MetricValue
    func retrieveAll(from startDate: Date, until endDate: Date) async throws -> [MetricEntry]
    func sync() async throws
}
```

That is enough to plug your own persistence layer into the same metric definitions.

## Data model

Each recorded sample is stored as a `MetricEntry`:

- `timestamp`
- `metric`
- `value`

The metric metadata includes:

- metric name
- optional bucket
- recorded value type name

The value itself is JSON-encoded data.

## Behavior notes

- `Metric.record(...)` is non-blocking.
- Convenience recording uses a single internal queue so writes are serialized.
- Retrieval is typed: asking for `Metric<Double>` only resolves entries for that exact metric definition.
- Metrics are identified by metric name, bucket, and value type.
