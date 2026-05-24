public struct LogEvent: Equatable, Sendable {
    public let name: String
    public let level: LogLevel
    public let message: String
    public let metadata: [String: String]

    public init(
        name: String,
        level: LogLevel,
        message: String,
        metadata: [String: String] = [:]
    ) {
        self.name = name
        self.level = level
        self.message = message
        self.metadata = metadata
    }
}
