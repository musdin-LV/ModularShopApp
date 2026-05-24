import DesignSystem
import ProductFeature
import SwiftUI

public struct CartView: View {
    @State private var viewModel: CartViewModel
    private let selectedClientName: String?
    private let onCheckout: @MainActor @Sendable ([CartItem], Double) -> Void

    public init(
        viewModel: CartViewModel,
        selectedClientName: String? = nil,
        onCheckout: @escaping @MainActor @Sendable ([CartItem], Double) -> Void = { _, _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.selectedClientName = selectedClientName
        self.onCheckout = onCheckout
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "Cart is empty",
                        systemImage: "cart",
                        description: Text("Products you add appear here.")
                    )
                } else {
                    List {
                        Section("Client") {
                            if let selectedClientName {
                                Label(selectedClientName, systemImage: "person.fill")
                            } else {
                                Label("Select a client before checkout", systemImage: "person.crop.circle.badge.exclamationmark")
                                    .foregroundStyle(.secondary)
                            }
                        }

                        ForEach(viewModel.items) { item in
                            HStack(alignment: .top, spacing: ShopSpacing.medium) {
                                VStack(alignment: .leading, spacing: ShopSpacing.xSmall) {
                                    Text(item.product.title)
                                        .font(.headline)
                                    Text("Quantity: \(item.quantity)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(item.subtotal.formatted(.currency(code: "USD")))
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for index in indexSet {
                                    await viewModel.remove(productID: viewModel.items[index].product.id)
                                }
                            }
                        }

                        Section {
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(viewModel.total.formatted(.currency(code: "USD")))
                                    .font(.headline)
                            }

                            Button {
                                onCheckout(viewModel.items, viewModel.total)
                            } label: {
                                Label("Checkout", systemImage: "creditcard")
                            }
                            .disabled(viewModel.items.isEmpty || selectedClientName == nil)
                        }
                    }
                }
            }
            .navigationTitle("Cart")
        }
        .task {
            await viewModel.loadCart()
        }
    }
}
