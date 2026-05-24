import Foundation

public struct PaymentRequest: Equatable, Sendable {
    public let amount: Decimal
    public let currencyCode: String
    public let reference: String
    public let purchasedItems: [PurchasedItem]

    public init(
        amount: Decimal,
        currencyCode: String,
        reference: String,
        purchasedItems: [PurchasedItem] = []
    ) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.reference = reference
        self.purchasedItems = purchasedItems
    }
}

public struct PurchasedItem: Identifiable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let quantity: Int
    public let subtotal: Decimal

    public init(
        id: Int,
        title: String,
        quantity: Int,
        subtotal: Decimal
    ) {
        self.id = id
        self.title = title
        self.quantity = quantity
        self.subtotal = subtotal
    }
}
