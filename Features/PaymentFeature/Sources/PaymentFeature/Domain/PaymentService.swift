public protocol PaymentService: Sendable {
    func startTapToPay(request: PaymentRequest) async throws -> PaymentResult
}
