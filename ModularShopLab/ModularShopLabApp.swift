import AuthFeature
import CartFeature
import ClientFeature
import FeatureFlags
import FavoritesFeature
import Foundation
import HomeFeature
import Networking
import Observation
import Observability
import PaymentFeature
import ProductFeature
import StoreContext
import SwiftUI

@main
struct ModularShopLabApp: App {
    @State private var dependencies = AppDependencies()

    init() {
        FirebaseObservability.configureIfAvailable()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(dependencies: dependencies)
        }
    }
}

@MainActor
@Observable
private final class AppDependencies {
    private let configuration: AppConfiguration
    private let apiClient: any APIClient
    private let authRepository: any AuthRepository
    private let clientRepository: any ClientRepository
    private let productRepository: any ProductRepository
    private let cartStore: any CartStore
    private let favoriteStore: any FavoriteStore
    private let checkoutPreparationService: any CheckoutPreparationService
    private let paymentService: any PaymentService
    private let logger: any AppLogger
    private let loadFeatureFlagsUseCase: LoadFeatureFlagsUseCase
    private let loadStoreContextUseCase: LoadStoreContextUseCase
    private var featureFlags: FeatureFlagSet
    private var storeContext: StoreContext

    init(configuration: AppConfiguration = .current()) {
        self.configuration = configuration

        let apiClient = URLSessionAPIClient()
        let localFeatureFlagRepository = JSONFeatureFlagRepository(dataProvider: Self.loadBundledFeatureFlagData)
        let featureFlagRepository: any FeatureFlagRepository
        let storeContextRepository: any StoreContextRepository

        switch configuration {
        case .remote:
            let remoteFeatureFlagRepository = RemoteFeatureFlagRepository(apiClient: apiClient)
            featureFlagRepository = FallbackFeatureFlagRepository(
                primary: remoteFeatureFlagRepository,
                fallback: localFeatureFlagRepository
            )
            storeContextRepository = FallbackStoreContextRepository(
                primary: RemoteStoreContextRepository(apiClient: apiClient),
                fallback: StaticStoreContextRepository()
            )
        case .mock:
            featureFlagRepository = localFeatureFlagRepository
            storeContextRepository = StaticStoreContextRepository(context: .mockRetailContext)
        }

        self.apiClient = apiClient
        self.cartStore = InMemoryCartStore()
        self.favoriteStore = InMemoryFavoriteStore()
        self.paymentService = AdyenTapToPayService()
        self.logger = CompositeLogger(loggers: [
            ConsoleLogger(),
            FirebaseLogger()
        ])
        self.loadFeatureFlagsUseCase = LoadFeatureFlagsUseCase(repository: featureFlagRepository)
        self.loadStoreContextUseCase = LoadStoreContextUseCase(repository: storeContextRepository)
        self.featureFlags = Self.loadBundledFeatureFlags()
        self.storeContext = configuration == .mock ? .mockRetailContext : .defaultRetailContext

        switch configuration {
        case .remote:
            self.authRepository = RemoteAuthRepository(apiClient: apiClient)
            self.clientRepository = RemoteClientRepository(apiClient: apiClient)
            self.productRepository = RemoteProductRepository(apiClient: apiClient)
            self.checkoutPreparationService = RemoteCheckoutPreparationWorker(apiClient: apiClient)
        case .mock:
            self.authRepository = MockAuthRepository()
            self.clientRepository = MockClientRepository()
            self.productRepository = MockProductRepository()
            self.checkoutPreparationService = MockCheckoutPreparationService()
        }
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(repository: authRepository)
    }

    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(repository: authRepository)
    }

    func makeForgotPasswordViewModel() -> ForgotPasswordViewModel {
        ForgotPasswordViewModel(repository: authRepository)
    }

    func makeClientFlowCoordinator() -> ClientFlowCoordinator {
        ClientFlowCoordinator(repository: clientRepository)
    }

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(repository: productRepository)
    }

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(store: cartStore)
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(store: favoriteStore)
    }

    func makeTapToPayViewModel() -> TapToPayViewModel {
        TapToPayViewModel(
            startTapToPayUseCase: StartTapToPayUseCase(
                checkoutPreparationService: checkoutPreparationService,
                paymentService: paymentService
            ),
            logger: logger
        )
    }

    func makeAppCapabilities() -> AppCapabilities {
        AppCapabilities(platform: AppExperience.current.platform, flags: featureFlags)
    }

    func makeStoreContextPresentation() -> StoreContextPresentation {
        StoreContextPresentation(
            employeeName: storeContext.employee.displayName,
            employeeRole: storeContext.employee.role.rawValue,
            storeName: storeContext.store.name,
            storeCode: storeContext.store.id
        )
    }

    func refreshAppContext() async {
        await log(
            LogEvent(
                name: "app_context_refresh_started",
                level: .debug,
                message: "App context refresh started."
            )
        )

        do {
            featureFlags = try await loadFeatureFlagsUseCase.execute()
            await log(
                LogEvent(
                    name: "feature_flags_loaded",
                    level: .info,
                    message: "Feature flags loaded.",
                    metadata: ["enabled_flags": featureFlags.enabledFlagNames.joined(separator: ",")]
                )
            )
        } catch {
            featureFlags = Self.loadBundledFeatureFlags()
            await log(
                LogEvent(
                    name: "feature_flags_load_failed",
                    level: .warning,
                    message: "Feature flags fallback loaded.",
                    metadata: ["reason": String(describing: error)]
                )
            )
        }

        do {
            storeContext = try await loadStoreContextUseCase.execute()
            await log(
                LogEvent(
                    name: "store_context_loaded",
                    level: .info,
                    message: "Store context loaded.",
                    metadata: [
                        "employee_id": storeContext.employee.id,
                        "store_id": storeContext.store.id
                    ]
                )
            )
        } catch {
            storeContext = configuration == .mock ? .mockRetailContext : .defaultRetailContext
            await log(
                LogEvent(
                    name: "store_context_load_failed",
                    level: .warning,
                    message: "Store context fallback loaded.",
                    metadata: ["reason": String(describing: error)]
                )
            )
        }
    }

    func log(_ event: LogEvent) async {
        await logger.log(enriched(event))
    }

    nonisolated private static func loadBundledFeatureFlags() -> FeatureFlagSet {
        do {
            return try FeatureFlagConfiguration.decode(from: loadBundledFeatureFlagData()).featureFlagSet
        } catch {
            return .allEnabled
        }
    }

    nonisolated private static func loadBundledFeatureFlagData() throws -> Data {
        guard let url = Bundle.main.url(forResource: "FeatureFlags", withExtension: "json") else {
            throw FeatureFlagLoadingError.missingLocalConfiguration
        }

        return try Data(contentsOf: url)
    }

    private func enriched(_ event: LogEvent) -> LogEvent {
        var metadata = event.metadata
        metadata["configuration"] = configuration.loggingValue
        metadata["platform"] = AppExperience.current.platform.loggingValue

        return LogEvent(
            name: event.name,
            level: event.level,
            message: event.message,
            metadata: metadata
        )
    }
}

private struct StoreContextPresentation: Equatable, Sendable {
    let employeeName: String
    let employeeRole: String
    let storeName: String
    let storeCode: String
}

private struct AppRootView: View {
    let dependencies: AppDependencies

    @State private var session: UserSession?
    @State private var selectedClient: Client?
    @State private var cartViewModel: CartViewModel
    @State private var favoritesViewModel: FavoritesViewModel
    @State private var clientTabCoordinator: ClientFlowCoordinator
    @State private var presentedClientFlow: ClientFlowCoordinator?
    @State private var presentedTipsRoute: ExternalWebRoute?
    @State private var tapToPayViewModel: TapToPayViewModel
    @State private var isCheckoutPresented = false
    @State private var selectedTab = AppTab.home

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _cartViewModel = State(initialValue: dependencies.makeCartViewModel())
        _favoritesViewModel = State(initialValue: dependencies.makeFavoritesViewModel())
        _clientTabCoordinator = State(initialValue: dependencies.makeClientFlowCoordinator())
        _tapToPayViewModel = State(initialValue: dependencies.makeTapToPayViewModel())
    }

    var body: some View {
        Group {
            if let currentSession = session {
                let storeContext = dependencies.makeStoreContextPresentation()

                MainTabs(
                    capabilities: dependencies.makeAppCapabilities(),
                    sellerName: storeContext.employeeName.isEmpty ? currentSession.username : storeContext.employeeName,
                    employeeRole: storeContext.employeeRole,
                    storeName: storeContext.storeName,
                    storeCode: storeContext.storeCode,
                    selectedTab: $selectedTab,
                    productListViewModel: dependencies.makeProductListViewModel(),
                    cartViewModel: cartViewModel,
                    favoritesViewModel: favoritesViewModel,
                    clientTabCoordinator: clientTabCoordinator,
                    selectedClientName: selectedClient?.displayName,
                    onClientSelected: { client in
                        selectedClient = client
                        Task {
                            await dependencies.log(
                                LogEvent(
                                    name: "client_selected",
                                    level: .info,
                                    message: "Client selected for sale.",
                                    metadata: ["client_id": "\(client.id)"]
                                )
                            )
                        }
                    },
                    onRequestClientSelection: {
                        presentedClientFlow = dependencies.makeClientFlowCoordinator()
                        Task {
                            await dependencies.log(
                                LogEvent(
                                    name: "client_flow_presented",
                                    level: .debug,
                                    message: "Client flow presented."
                                )
                            )
                        }
                    },
                    onOpenTips: {
                        let url = URL(string: "https://www.duolingo.com/learn")!
                        presentedTipsRoute = ExternalWebRoute(url: url)
                        Task {
                            await dependencies.log(
                                LogEvent(
                                    name: "tips_webview_presented",
                                    level: .info,
                                    message: "Language learning tips webview presented.",
                                    metadata: ["url": url.absoluteString]
                                )
                            )
                        }
                    },
                    onLogout: {
                        let userID = currentSession.userID
                        selectedClient = nil
                        session = nil
                        Task {
                            await dependencies.log(
                                LogEvent(
                                    name: "logout",
                                    level: .info,
                                    message: "User logged out.",
                                    metadata: ["user_id": "\(userID)"]
                                )
                            )
                        }
                    },
                    onCheckout: { items, total in
                        tapToPayViewModel.updateRequest(
                            PaymentRequest(
                                amount: Decimal(total),
                                currencyCode: "USD",
                                reference: "modular-shop-\(UUID().uuidString)",
                                purchasedItems: items.map { item in
                                    PurchasedItem(
                                        id: item.product.id,
                                        title: item.product.title,
                                        quantity: item.quantity,
                                        subtotal: Decimal(item.subtotal)
                                    )
                                }
                            )
                        )
                        isCheckoutPresented = true
                        Task {
                            await dependencies.log(
                                LogEvent(
                                    name: "checkout_presented",
                                    level: .info,
                                    message: "Checkout presented.",
                                    metadata: [
                                        "has_client": selectedClient == nil ? "false" : "true",
                                        "items_count": "\(items.count)",
                                        "total": "\(total)"
                                    ]
                                )
                            )
                        }
                    }
                )
                .sheet(isPresented: $isCheckoutPresented) {
                    TapToPayView(viewModel: tapToPayViewModel)
                }
                .sheet(item: $presentedTipsRoute) { route in
                    ExternalWebView(url: route.url)
                        .ignoresSafeArea()
                }
                .fullScreenCover(item: $presentedClientFlow) { coordinator in
                    ClientFlowView(
                        coordinator: coordinator,
                        onClientSelected: { client in
                            coordinator.cancel()
                            selectedClient = client
                            presentedClientFlow = nil
                            Task {
                                await dependencies.log(
                                    LogEvent(
                                        name: "client_selected",
                                        level: .info,
                                        message: "Client selected from modal flow.",
                                        metadata: ["client_id": "\(client.id)"]
                                    )
                                )
                            }
                        },
                        onStartSale: { client in
                            coordinator.cancel()
                            selectedClient = client
                            selectedTab = .products
                            presentedClientFlow = nil
                            Task {
                                await dependencies.log(
                                    LogEvent(
                                        name: "sale_started",
                                        level: .info,
                                        message: "Sale started from client flow.",
                                        metadata: ["client_id": "\(client.id)"]
                                    )
                                )
                            }
                        },
                        onClose: {
                            presentedClientFlow = nil
                        }
                    )
                }
            } else {
                AuthView(
                    loginViewModel: dependencies.makeLoginViewModel(),
                    registerViewModel: dependencies.makeRegisterViewModel(),
                    forgotPasswordViewModel: dependencies.makeForgotPasswordViewModel(),
                    allowsPasswordReset: dependencies.makeAppCapabilities().allows(.passwordReset)
                ) { session in
                    self.session = session
                    Task {
                        await dependencies.log(
                            LogEvent(
                                name: "login_success",
                                level: .info,
                                message: "User logged in.",
                                metadata: [
                                    "user_id": "\(session.userID)",
                                    "username": session.username
                                ]
                            )
                        )
                    }
                }
            }
        }
        .task {
            await dependencies.refreshAppContext()
        }
    }
}

private struct MainTabs: View {
    let capabilities: AppCapabilities
    let sellerName: String
    let employeeRole: String
    let storeName: String
    let storeCode: String
    @Binding var selectedTab: AppTab
    let productListViewModel: ProductListViewModel
    let cartViewModel: CartViewModel
    let favoritesViewModel: FavoritesViewModel
    let clientTabCoordinator: ClientFlowCoordinator
    let selectedClientName: String?
    let onClientSelected: @MainActor @Sendable (Client) -> Void
    let onRequestClientSelection: @MainActor @Sendable () -> Void
    let onOpenTips: @MainActor @Sendable () -> Void
    let onLogout: @MainActor @Sendable () -> Void
    let onCheckout: @MainActor @Sendable ([CartItem], Double) -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                sellerName: sellerName,
                employeeRole: employeeRole,
                storeName: storeName,
                storeCode: storeCode,
                selectedClientName: selectedClientName,
                canStartSale: capabilities.allows(.startSale),
                onStartSale: {
                    selectedTab = .products
                },
                onCreateClient: onRequestClientSelection,
                onOpenTips: onOpenTips,
                onLogout: onLogout
            )
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)

            ProductListView(
                viewModel: productListViewModel,
                onAddToCart: addToCartAction,
                onStartSale: startSaleAction,
                selectedClientName: selectedClientName,
                onSelectClient: capabilities.allows(.clientManagement) ? onRequestClientSelection : nil,
                allowsSearch: capabilities.allows(.productSearch),
                allowsFavorites: capabilities.allows(.favorites),
                isFavorite: { product in
                    favoritesViewModel.isFavorite(product: product)
                },
                onToggleFavorite: { product in
                    Task {
                        await favoritesViewModel.toggle(product: product)
                    }
                }
            )
            .tabItem {
                Label("Products", systemImage: "list.bullet")
            }
            .tag(AppTab.products)

            if capabilities.allows(.favorites) {
                FavoritesView(
                    viewModel: favoritesViewModel,
                    onAddToCart: addToCartAction
                )
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(AppTab.favorites)
            }

            if capabilities.allows(.clientManagement) {
                ClientFlowView(
                    coordinator: clientTabCoordinator,
                    onClientSelected: onClientSelected,
                    onStartSale: { client in
                        onClientSelected(client)
                        selectedTab = .products
                    },
                    onClose: {
                        selectedTab = .home
                    }
                )
                .tabItem {
                    Label("Clients", systemImage: "person.2")
                }
                .tag(AppTab.clients)
            }

            if capabilities.allows(.cart) {
                CartView(
                    viewModel: cartViewModel,
                    selectedClientName: selectedClientName,
                    onCheckout: checkoutAction
                )
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .tag(AppTab.cart)
            }
        }
    }

    private var addToCartAction: (@MainActor @Sendable (Product) -> Void)? {
        guard capabilities.allows(.cart) else {
            return nil
        }

        return { product in
            Task {
                await cartViewModel.add(product: product)
            }
        }
    }

    private var startSaleAction: (@MainActor @Sendable (Product) -> Void)? {
        guard capabilities.allows(.startSale) else {
            return nil
        }

        return { product in
            Task {
                await cartViewModel.add(product: product)
            }
        }
    }

    private var checkoutAction: @MainActor @Sendable ([CartItem], Double) -> Void {
        guard capabilities.allows(.checkout) else {
            return { _, _ in }
        }

        return onCheckout
    }
}

private enum AppTab: Hashable {
    case home
    case products
    case favorites
    case clients
    case cart
}

private extension AppConfiguration {
    var loggingValue: String {
        switch self {
        case .remote:
            "remote"
        case .mock:
            "mock"
        }
    }
}

private extension AppPlatform {
    var loggingValue: String {
        switch self {
        case .iPhone:
            "iphone"
        case .iPad:
            "ipad"
        }
    }
}

private extension FeatureFlagSet {
    var enabledFlagNames: [String] {
        FeatureFlag.allCases
            .filter { isEnabled($0) }
            .map(\.rawValue)
    }
}
