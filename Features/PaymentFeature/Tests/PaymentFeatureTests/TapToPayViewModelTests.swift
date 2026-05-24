import Testing
@testable import PaymentFeature

@MainActor
@Test
func tapToPayViewModelHandlesApprovedPayment() async {
    let service = StubPaymentService(
        result: .success(PaymentResult(transactionID: "txn_123", status: .approved))
    )
    let viewModel = TapToPayViewModel(
        startTapToPayUseCase: StartTapToPayUseCase(
            checkoutPreparationService: StubCheckoutPreparationService(),
            paymentService: service
        ),
        request: PaymentRequest(
            amount: 19.99,
            currencyCode: "EUR",
            reference: "test",
            purchasedItems: [PurchasedItem(id: 1, title: "Test product", quantity: 1, subtotal: 19.99)]
        )
    )

    await viewModel.startPayment()

    #expect(viewModel.resultMessage == "Payment approved: txn_123")
    #expect(viewModel.errorMessage == nil)
    #expect(viewModel.isLoading == false)
}

@MainActor
@Test
func tapToPayViewModelRejectsInvalidAmount() async {
    let viewModel = TapToPayViewModel(
        startTapToPayUseCase: StartTapToPayUseCase(
            checkoutPreparationService: StubCheckoutPreparationService(),
            paymentService: StubPaymentService(result: .failure(PaymentError.invalidAmount))
        ),
        request: PaymentRequest(amount: 0, currencyCode: "EUR", reference: "test")
    )

    await viewModel.startPayment()

    #expect(viewModel.resultMessage == nil)
    #expect(viewModel.errorMessage == "Cart total must be greater than zero.")
    #expect(viewModel.isLoading == false)
}

@MainActor
@Test
func tapToPayViewModelHandlesCheckoutPreparationError() async {
    let viewModel = TapToPayViewModel(
        startTapToPayUseCase: StartTapToPayUseCase(
            checkoutPreparationService: StubCheckoutPreparationService(result: .failure(CheckoutPreparationError.emptyCart)),
            paymentService: StubPaymentService(result: .success(PaymentResult(transactionID: "txn_123", status: .approved)))
        ),
        request: PaymentRequest(amount: 19.99, currencyCode: "EUR", reference: "test")
    )

    await viewModel.startPayment()

    #expect(viewModel.resultMessage == nil)
    #expect(viewModel.errorMessage == "Cart must contain at least one product.")
    #expect(viewModel.isLoading == false)
}

private struct StubCheckoutPreparationService: CheckoutPreparationService {
    let result: Result<CheckoutPreparationResult, Error>?

    init(result: Result<CheckoutPreparationResult, Error>? = nil) {
        self.result = result
    }

    func prepareCheckout(request: CheckoutPreparationRequest) async throws -> CheckoutPreparationResult {
        if let result {
            return try result.get()
        }

        return CheckoutPreparationResult(
            paymentRequest: request.paymentRequest,
            orderReference: request.paymentRequest.reference
        )
    }
}

private struct StubPaymentService: PaymentService {
    let result: Result<PaymentResult, Error>

    func startTapToPay(request: PaymentRequest) async throws -> PaymentResult {
        try result.get()
    }
}
