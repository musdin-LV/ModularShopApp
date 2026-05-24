import DesignSystem
import SwiftUI

public struct TapToPayView: View {
    @State private var viewModel: TapToPayViewModel

    public init(viewModel: TapToPayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Order") {
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(viewModel.formattedAmount)
                            .font(.headline)
                    }

                    ForEach(viewModel.purchasedItems) { item in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                Text("Quantity: \(item.quantity)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(viewModel.formattedSubtotal(for: item))
                        }
                    }
                }

                Section("Tap to Pay") {
                    if let resultMessage = viewModel.resultMessage {
                        Text(resultMessage)
                            .foregroundStyle(.secondary)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }

                    PrimaryButton("Start payment", isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.startPayment()
                        }
                    }
                }
            }
            .navigationTitle("Payment")
        }
    }
}
