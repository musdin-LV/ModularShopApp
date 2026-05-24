import Observability
import Testing

@Test
func compositeLoggerForwardsEventsToEveryLogger() async {
    let firstLogger = CollectingLogger()
    let secondLogger = CollectingLogger()
    let logger = CompositeLogger(loggers: [firstLogger, secondLogger])
    let event = LogEvent(
        name: "test_event",
        level: .info,
        message: "Test message",
        metadata: ["source": "unit-test"]
    )

    await logger.log(event)

    await #expect(firstLogger.events == [event])
    await #expect(secondLogger.events == [event])
}

private actor CollectingLogger: AppLogger {
    private var storedEvents: [LogEvent] = []

    var events: [LogEvent] {
        storedEvents
    }

    func log(_ event: LogEvent) async {
        storedEvents.append(event)
    }
}
