#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

public struct FirebaseLogger: AppLogger {
    public init() {}

    public func log(_ event: LogEvent) async {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event.name, parameters: analyticsParameters(for: event))
        #endif

        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(crashlyticsMessage(for: event))
        #endif
    }

    #if canImport(FirebaseAnalytics)
    private func analyticsParameters(for event: LogEvent) -> [String: Any] {
        var parameters = event.metadata.reduce(into: [String: Any]()) { result, item in
            result[item.key] = item.value
        }
        parameters["level"] = event.level.rawValue
        parameters["message"] = event.message
        return parameters
    }
    #endif

    #if canImport(FirebaseCrashlytics)
    private func crashlyticsMessage(for event: LogEvent) -> String {
        let metadata = event.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")

        guard !metadata.isEmpty else {
            return "[\(event.level.rawValue)] \(event.name): \(event.message)"
        }

        return "[\(event.level.rawValue)] \(event.name): \(event.message) \(metadata)"
    }
    #endif
}
