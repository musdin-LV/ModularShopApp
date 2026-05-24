public protocol AppLogger: Sendable {
    func log(_ event: LogEvent) async
}
