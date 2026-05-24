import Foundation
import Observation

public enum ClientFlowRoute: Hashable, Sendable {
    case detail(Client)
    case create
    case update(Client)
}

@MainActor
@Observable
public final class ClientFlowCoordinator: Identifiable {
    public let id = UUID()
    public var path: [ClientFlowRoute] = []

    public let searchViewModel: ClientSearchViewModel
    private let repository: any ClientRepository

    public init(repository: any ClientRepository) {
        self.repository = repository
        self.searchViewModel = ClientSearchViewModel(repository: repository)
    }

    public func showCreate() {
        path.append(.create)
    }

    public func showDetail(for client: Client) {
        path.append(.detail(client))
    }

    public func showUpdate(for client: Client) {
        path.append(.update(client))
    }

    public func makeCreateViewModel() -> ClientFormViewModel {
        ClientFormViewModel(mode: .create, saveClientUseCase: SaveClientUseCase(repository: repository))
    }

    public func makeUpdateViewModel(for client: Client) -> ClientFormViewModel {
        ClientFormViewModel(mode: .update(client), saveClientUseCase: SaveClientUseCase(repository: repository))
    }

    public func cancel() {
        searchViewModel.cancel()
    }

}
