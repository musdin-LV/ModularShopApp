public protocol CheckoutPreparationService: Sendable {
    func prepareCheckout(request: CheckoutPreparationRequest) async throws -> CheckoutPreparationResult
}

public struct CheckoutPreparationRequest: Equatable, Sendable {
    public let paymentRequest: PaymentRequest

    public init(paymentRequest: PaymentRequest) {
        self.paymentRequest = paymentRequest
    }
}

public struct CheckoutPreparationResult: Equatable, Sendable {
    public let paymentRequest: PaymentRequest
    public let orderReference: String

    public init(paymentRequest: PaymentRequest, orderReference: String) {
        self.paymentRequest = paymentRequest
        self.orderReference = orderReference
    }
}

public enum CheckoutPreparationError: Error, Equatable, Sendable {
    case emptyCart
    case invalidAmount
}
