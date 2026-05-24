import Foundation

public struct PaymentResult: Equatable, Sendable {
    public let transactionID: String
    public let status: PaymentStatus

    public init(transactionID: String, status: PaymentStatus) {
        self.transactionID = transactionID
        self.status = status
    }
}

public enum PaymentStatus: Equatable, Sendable {
    case approved
    case declined(reason: String)
}

public enum PaymentError: Error, Equatable, Sendable {
    case invalidAmount
    case tapToPayUnavailable
    case cancelled
    case sdkFailure(message: String)
}
