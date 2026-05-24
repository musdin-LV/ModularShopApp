import SwiftUI

public struct ClientDetailView: View {
    private let state: ClientDetailViewState
    private let onSelectClient: @MainActor @Sendable () -> Void
    private let onStartSale: @MainActor @Sendable () -> Void
    private let onUpdate: @MainActor @Sendable () -> Void

    public init(
        state: ClientDetailViewState,
        onSelectClient: @escaping @MainActor @Sendable () -> Void,
        onStartSale: @escaping @MainActor @Sendable () -> Void,
        onUpdate: @escaping @MainActor @Sendable () -> Void
    ) {
        self.state = state
        self.onSelectClient = onSelectClient
        self.onStartSale = onStartSale
        self.onUpdate = onUpdate
    }

    public var body: some View {
        Form {
            Section("Client") {
                LabeledContent("Name", value: state.displayName)
                LabeledContent("Email", value: state.email)
                if let phone = state.phone {
                    LabeledContent("Phone", value: phone)
                }
                LabeledContent("Country", value: state.countryName)
            }

            Section("Sale") {
                Button {
                    onSelectClient()
                } label: {
                    Label("Select client", systemImage: "person.fill.checkmark")
                }

                Button {
                    onStartSale()
                } label: {
                    Label("Start a sale", systemImage: "cart.badge.plus")
                }
            }

            Section {
                Button {
                    onUpdate()
                } label: {
                    Label("Update client", systemImage: "pencil")
                }
            }
        }
        .navigationTitle(state.title)
    }
}
