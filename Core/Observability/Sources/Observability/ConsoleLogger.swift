public struct ConsoleLogger: AppLogger {
    public init() {}

    public func log(_ event: LogEvent) async {
        print(format(event))
    }

    private func format(_ event: LogEvent) -> String {
        let metadata = event.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")

        let prefix = "[ModularShopLab][\(event.level.rawValue.uppercased())] \(event.name)"

        guard !metadata.isEmpty else {
            return "\(prefix) - \(event.message)"
        }

        return "\(prefix) - \(event.message) \(metadata)"
    }
}
