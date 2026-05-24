import Foundation
import Networking

public struct RemoteCheckoutPreparationWorker: CheckoutPreparationService {
    private let apiClient: any APIClient
    private let encoder: JSONEncoder

    public init(apiClient: any APIClient, encoder: JSONEncoder = JSONEncoder()) {
        self.apiClient = apiClient
        self.encoder = encoder
    }

    public func prepareCheckout(request: CheckoutPreparationRequest) async throws -> CheckoutPreparationResult {
        let paymentRequest = request.paymentRequest

        guard paymentRequest.amount > 0 else {
            throw CheckoutPreparationError.invalidAmount
        }

        guard !paymentRequest.purchasedItems.isEmpty else {
            throw CheckoutPreparationError.emptyCart
        }

        let payload = CheckoutPreparationRequestDTO(
            userId: 1,
            products: paymentRequest.purchasedItems.map { item in
                CheckoutPreparationProductDTO(id: item.id, quantity: item.quantity)
            }
        )
        let body = try encoder.encode(payload)
        let response: CheckoutPreparationResponseDTO = try await apiClient.send(
            APIRequest(
                path: "/carts/add",
                method: .post,
                headers: ["Content-Type": "application/json"],
                body: body
            )
        )
        let orderReference = "order-\(response.id)-\(paymentRequest.reference)"

        return CheckoutPreparationResult(
            paymentRequest: PaymentRequest(
                amount: paymentRequest.amount,
                currencyCode: paymentRequest.currencyCode,
                reference: orderReference,
                purchasedItems: paymentRequest.purchasedItems
            ),
            orderReference: orderReference
        )
    }
}

private struct CheckoutPreparationRequestDTO: Encodable, Sendable {
    let userId: Int
    let products: [CheckoutPreparationProductDTO]
}

private struct CheckoutPreparationProductDTO: Encodable, Sendable {
    let id: Int
    let quantity: Int
}

private struct CheckoutPreparationResponseDTO: Decodable, Sendable {
    let id: Int
}
