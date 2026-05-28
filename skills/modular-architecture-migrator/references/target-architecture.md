# Target Architecture Reference

Use this reference when applying the `modular-architecture-migrator` skill.

## Target Shape

```text
ModularShopLab
  Composition
    AppDependencies.swift
  Root
    AppRootView.swift
    MainTabs.swift
    IPadMainView.swift

Core
  DesignSystem
  Networking
  FeatureFlags
  ProductCatalog
  StoreContext
  Observability

Features
  ProductFeature
  ProductShowroomFeature
  CartFeature
  FavoritesFeature
  ClientFeature
```

## Responsibility Rules

### App Target

The app target is allowed to import every feature because it assembles the product.

Responsibilities:

- create concrete repositories, stores, clients, SDK adapters;
- choose mock, remote, local, or fake implementations;
- create view models and coordinators;
- wire callbacks between features;
- choose platform-specific experiences;
- expose app capabilities.

Avoid:

- business rules that belong to a feature;
- networking logic that belongs to data/integration modules;
- feature internals leaking into root views.

### Feature Package

A feature owns a user-facing workflow.

Common internal folders:

```text
FeatureName
  Domain
  Data
  UI
  Resources
```

Responsibilities:

- UI state and flow;
- feature-specific domain rules;
- feature-specific repository protocols;
- feature-specific data implementations;
- localizable strings and resources.

Avoid:

- creating global app dependencies;
- importing another feature only to reuse a model;
- deciding runtime environment such as mock vs remote.

### Core Package

Core contains stable shared contracts and technical capabilities.

Good Core candidates:

- design system components;
- API client abstractions;
- feature flags and capabilities;
- product catalog domain shared by several product experiences;
- observability contracts;
- shared persistence adapter only when genuinely cross-feature.

Avoid:

- dumping unrelated business logic into a `Shared` bucket;
- making Core import features;
- moving unstable feature internals to Core too early.

## Dependency Injection Pattern

Prefer initializer injection:

```swift
@MainActor
@Observable
final class AppDependencies {
    private let apiClient: any APIClient
    private let productRepository: any ProductRepository
    private let searchProductsUseCase: SearchProductsUseCase

    init(configuration: AppConfiguration) {
        let apiClient = URLSessionAPIClient()
        self.apiClient = apiClient

        switch configuration {
        case .remote:
            self.productRepository = RemoteProductRepository(apiClient: apiClient)
        case .mock:
            self.productRepository = MockProductRepository()
        }

        self.searchProductsUseCase = SearchProductsUseCase(repository: productRepository)
    }

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(searchProductsUseCase: searchProductsUseCase)
    }
}
```

Use a feature dependencies object when construction becomes more than one dependency:

```swift
public struct ClientFeatureDependencies: Sendable {
    private let repository: any ClientRepository
    private let recentClientStore: any RecentClientStore
    private let saveClientUseCase: SaveClientUseCase

    public init(
        repository: any ClientRepository,
        recentClientStore: any RecentClientStore
    ) {
        self.repository = repository
        self.recentClientStore = recentClientStore
        self.saveClientUseCase = SaveClientUseCase(
            repository: repository,
            recentClientStore: recentClientStore
        )
    }

    @MainActor
    public func makeSearchViewModel() -> ClientSearchViewModel {
        ClientSearchViewModel(
            repository: repository,
            recentClientStore: recentClientStore
        )
    }
}
```

## Shared Domain Extraction

Use this when feature-to-feature imports exist only for a shared model.

Bad:

```text
CartFeature -> ProductFeature  // only for Product
FavoritesFeature -> ProductFeature  // only for Product
```

Better:

```text
ProductFeature -> Core/ProductCatalog
CartFeature -> Core/ProductCatalog
FavoritesFeature -> Core/ProductCatalog
```

`Core/ProductCatalog` may contain:

- `Product`;
- `ProductRepository`;
- shared use cases such as `SearchProductsUseCase`.

## AppCapabilities

Use capabilities to express what the app permits at runtime:

```swift
public enum AppCapability: Sendable {
    case cart
    case checkout
    case clientManagement
    case favorites
    case productSearch
    case startSale
}

public struct AppCapabilities: Equatable, Sendable {
    private let platform: AppPlatform
    private let flags: FeatureFlagSet

    public func allows(_ capability: AppCapability) -> Bool {
        switch capability {
        case .cart:
            platform == .iPhone && flags.isEnabled(.cart)
        case .favorites:
            flags.isEnabled(.favorites)
        default:
            true
        }
    }
}
```

Capabilities should not create dependencies. They describe availability.

## Migration Heuristics

Create a package when:

- responsibility is clear;
- it is reused by multiple modules;
- it can be tested independently;
- it changes at a different rhythm;
- it removes a real import smell.

Keep folders when:

- the boundary is still emerging;
- only one feature uses the code;
- packages would add ceremony without clarity.

