import DesignSystem
import SwiftUI

public struct ClientFormView: View {
    @State private var viewModel: ClientFormViewModel
    private let onSaved: @MainActor @Sendable (Client) -> Void

    public init(
        viewModel: ClientFormViewModel,
        onSaved: @escaping @MainActor @Sendable (Client) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSaved = onSaved
    }

    public var body: some View {
        Form {
            Section("Identity") {
                TextField("First name", text: $viewModel.firstName)
                TextField("Last name", text: $viewModel.lastName)
                TextField("Email", text: $viewModel.email)
                TextField("Phone", text: $viewModel.phone)
            }

            Section("Origin") {
                Picker("Country", selection: $viewModel.country) {
                    ForEach(ClientCountry.allCases) { country in
                        Text(country.rawValue)
                            .tag(country)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                PrimaryButton(viewModel.submitTitle, isLoading: viewModel.isLoading) {
                    Task {
                        if let client = await viewModel.save() {
                            onSaved(client)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.title)
    }
}
