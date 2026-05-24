import Foundation

public struct AdyenTapToPayService: PaymentService {
    private let transactionIDProvider: @Sendable () -> String

    public init(transactionIDProvider: @escaping @Sendable () -> String = { UUID().uuidString }) {
        self.transactionIDProvider = transactionIDProvider
    }

    public func startTapToPay(request: PaymentRequest) async throws -> PaymentResult {
        guard request.amount > 0 else {
            throw PaymentError.invalidAmount
        }

        try await Task.sleep(for: .milliseconds(400))

        return PaymentResult(
            transactionID: transactionIDProvider(),
            status: .approved
        )
    }
}
