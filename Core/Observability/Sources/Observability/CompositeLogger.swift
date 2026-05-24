public struct CompositeLogger: AppLogger {
    private let loggers: [any AppLogger]

    public init(loggers: [any AppLogger]) {
        self.loggers = loggers
    }

    public func log(_ event: LogEvent) async {
        for logger in loggers {
            await logger.log(event)
        }
    }
}
