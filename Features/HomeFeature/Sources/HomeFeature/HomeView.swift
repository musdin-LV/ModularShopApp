import DesignSystem
import SwiftUI

public struct HomeView: View {
    private let sellerName: String
    private let employeeRole: String
    private let storeName: String
    private let storeCode: String
    private let selectedClientName: String?
    private let canStartSale: Bool
    private let onStartSale: @MainActor @Sendable () -> Void
    private let onCreateClient: @MainActor @Sendable () -> Void
    private let onOpenTips: @MainActor @Sendable () -> Void
    private let onLogout: @MainActor @Sendable () -> Void

    public init(
        sellerName: String,
        employeeRole: String = "",
        storeName: String = "",
        storeCode: String = "",
        selectedClientName: String? = nil,
        canStartSale: Bool,
        onStartSale: @escaping @MainActor @Sendable () -> Void,
        onCreateClient: @escaping @MainActor @Sendable () -> Void,
        onOpenTips: @escaping @MainActor @Sendable () -> Void,
        onLogout: @escaping @MainActor @Sendable () -> Void
    ) {
        self.sellerName = sellerName
        self.employeeRole = employeeRole
        self.storeName = storeName
        self.storeCode = storeCode
        self.selectedClientName = selectedClientName
        self.canStartSale = canStartSale
        self.onStartSale = onStartSale
        self.onCreateClient = onCreateClient
        self.onOpenTips = onOpenTips
        self.onLogout = onLogout
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Bonjour \(sellerName)")
                        .font(.title2.weight(.semibold))

                    if !employeeRole.isEmpty {
                        Label(employeeRole, systemImage: "person.text.rectangle")
                            .foregroundStyle(.secondary)
                    }

                    Button(role: .destructive) {
                        onLogout()
                    } label: {
                        Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }

                if !storeName.isEmpty {
                    Section("Store") {
                        Label(storeName, systemImage: "storefront")

                        if !storeCode.isEmpty {
                            Label(storeCode, systemImage: "number")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Sale") {
                    if let selectedClientName {
                        Label(selectedClientName, systemImage: "person.fill")
                    } else {
                        Label("No client selected", systemImage: "person")
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        onStartSale()
                    } label: {
                        Label("Start sale", systemImage: "cart.badge.plus")
                    }
                    .disabled(!canStartSale)
                }

                Section("Client") {
                    Button {
                        onCreateClient()
                    } label: {
                        Label("Create client", systemImage: "person.badge.plus")
                    }
                }

                Section("Tips") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Learn a new language", systemImage: "lightbulb")
                            .font(.headline)

                        Text("Open a short web guide with practical tips for language learning.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button {
                            onOpenTips()
                        } label: {
                            Label("Open tips", systemImage: "safari")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Home")
        }
    }
}
