import Foundation

public struct StartTapToPayUseCase: Sendable {
    private let checkoutPreparationService: any CheckoutPreparationService
    private let paymentService: any PaymentService

    public init(
        checkoutPreparationService: any CheckoutPreparationService,
        paymentService: any PaymentService
    ) {
        self.checkoutPreparationService = checkoutPreparationService
        self.paymentService = paymentService
    }

    public func execute(request: PaymentRequest) async throws -> PaymentResult {
        guard request.amount > 0 else {
            throw PaymentError.invalidAmount
        }

        let preparedCheckout = try await checkoutPreparationService.prepareCheckout(
            request: CheckoutPreparationRequest(paymentRequest: request)
        )

        return try await paymentService.startTapToPay(request: preparedCheckout.paymentRequest)
    }
}
