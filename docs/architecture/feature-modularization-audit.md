# Feature Modularization Audit Prompt

Use this prompt when you want an AI coding agent to inspect an existing iOS project, identify feature boundaries, and propose a modular architecture based on the current codebase.

## Prompt

You are a senior iOS architecture assistant. Your task is to analyze this existing Swift/SwiftUI/UIKit project and propose a pragmatic modular architecture.

Do not start by applying generic clean architecture. First read the repository and infer the architecture from the code that already exists.

### Goals

- Identify product features and feature boundaries.
- Identify core/shared modules.
- Identify data, domain, UI, and integration responsibilities.
- Propose a modularization plan that improves build times, ownership, testability, and dependency clarity.
- Avoid over-engineering and avoid creating too many packages too early.
- Prefer a package-per-feature architecture unless the codebase is large enough to justify deeper splits.

### Step 1: Inspect The Project

Read the project structure before proposing changes.

Look for:

- Xcode projects and workspaces.
- Swift Packages.
- App targets, extension targets, widgets, clips, test targets.
- Existing folders such as `Features`, `Core`, `Shared`, `Services`, `Networking`, `DesignSystem`, `Domain`, `Data`, `UI`.
- Navigation entry points.
- Dependency creation and composition root.
- Existing dependency injection patterns.
- Existing tests and preview/demo targets.

Useful commands:

```sh
rg --files
find . -name Package.swift -o -name "*.xcodeproj" -o -name "*.xcworkspace"
rg -n "protocol .*Repository|class .*ViewModel|struct .*View|actor |@MainActor|URLSession|Observable|@Observable|ObservableObject"
```

### Step 2: Identify Features

Infer features from user journeys, not only from folders.

For each potential feature, collect evidence:

- Screens/views.
- ViewModels/presenters/controllers.
- Domain models.
- Repositories/services.
- API endpoints or persistence tables.
- Tests.
- Navigation routes.
- Shared dependencies.

Classify each candidate as:

- **Feature**: a user-facing capability or workflow.
- **Core**: reusable technical capability used by multiple features.
- **Design/UI Shared**: reusable UI components, design tokens, styling.
- **Integration**: networking, storage, analytics, auth provider, SDK wrapper.
- **Ambiguous**: needs discussion before moving.

Output a table:

```text
Candidate | Type | Evidence | Current Location | Proposed Module | Confidence | Notes
```

### Step 3: Map Dependencies

Build a dependency map from the current code.

Mark:

- Feature-to-feature dependencies.
- Feature-to-core dependencies.
- Shared mutable state.
- Concrete infrastructure used directly by UI.
- Cycles or likely cycles.
- Places where a protocol boundary would improve testability.

Use a simple graph:

```text
App
 -> AuthFeature
 -> ProductFeature
 -> CartFeature

ProductFeature
 -> Core/Networking
 -> Core/DesignSystem
```

Flag dependency smells:

- UI creates `URLSession`, database, or SDK clients directly.
- Feature A imports Feature B just to use one model.
- Shared folders contain unrelated business logic.
- Global singletons hold mutable state.
- Protocols exist but are not useful for testing or boundaries.

### Step 4: Propose Architecture Options

Propose at least two options.

#### Option A: Package Per Feature

Prefer this for small and medium projects.

```text
App
Core
  DesignSystem
  Networking
  Persistence
  Foundation
Features
  AuthFeature
  ProductFeature
  CartFeature
```

Inside each feature package, use folders rather than more packages:

```text
ProductFeature
  Domain
    Product.swift
    ProductRepository.swift
  Data
    RemoteProductRepository.swift
    ProductDTO.swift
  UI
    ProductListView.swift
    ProductListViewModel.swift
  Tests
```

#### Option B: Domain/Data/UI Split

Use this only for large or heavily shared domains.

```text
ProductDomain
  Product
  ProductRepository

ProductData
  RemoteProductRepository
  DTOs

ProductUI
  ProductListView
  ProductListViewModel
```

Recommend this when:

- The domain is reused by several features or apps.
- Build times are painful.
- Teams own separate UI/data/domain parts.
- Multiple data implementations exist.
- Feature-to-feature imports are causing coupling.

Do not recommend this for every feature by default.

### Step 5: Define Composition Root

The app target should create concrete dependencies and inject protocols into features.

Example:

```swift
@MainActor
final class AppDependencies {
    private let apiClient: any APIClient
    private let productRepository: any ProductRepository
    private let cartStore: any CartStore

    init() {
        let apiClient = URLSessionAPIClient()
        self.apiClient = apiClient
        self.productRepository = RemoteProductRepository(apiClient: apiClient)
        self.cartStore = InMemoryCartStore()
    }

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(repository: productRepository)
    }
}
```

Prefer dependency injection by initializer. Do not introduce a DI framework unless the project already uses one and it is clearly justified.

### Step 6: Swift Concurrency Rules

For modern Swift:

- ViewModels that own UI state should usually be `@MainActor`.
- Networking should not be main-actor isolated.
- Shared mutable state should be isolated with an `actor`, `@MainActor`, or another clear isolation domain.
- Value models should be immutable and `Sendable` when they cross concurrency boundaries.
- Avoid `Task.detached` unless there is a specific reason.
- Prefer async/await and structured concurrency.

Flag unsafe patterns:

- Mutable global state.
- Non-Sendable objects crossing async boundaries.
- UI state mutated off MainActor.
- Locks/semaphores in async code.

### Step 7: Migration Plan

Return a phased migration plan.

Each phase should be small enough to build and test independently.

Example:

```text
Phase 1: Extract Core/Networking
Phase 2: Extract DesignSystem
Phase 3: Extract first feature package
Phase 4: Move feature tests into package
Phase 5: Remove direct infrastructure creation from feature UI
```

For each phase include:

- Files/modules to move.
- New package targets.
- Dependency changes.
- Risks.
- Validation command.

### Step 8: Output Format

Produce:

1. Current architecture summary.
2. Feature inventory table.
3. Dependency graph.
4. Recommended target architecture.
5. Why this option is the right size for this codebase.
6. Migration plan.
7. Open questions.

Keep the recommendation pragmatic. If package-per-feature is enough, say so. If a domain/data/UI split is justified only for specific domains, name those domains and explain why.

Do not modify files until the user approves the architecture plan.

## Decision Heuristics

Use these heuristics when deciding module boundaries:

```text
Create a separate package when:
- It has a clear owner and responsibility.
- It is reused by multiple modules.
- It changes at a different rate from its consumers.
- It improves build caching or parallel compilation.
- It can be tested independently.

Keep as folders inside one package when:
- The feature is small.
- The split is only conceptual.
- No other module needs the internals.
- More packages would reduce readability.
- The team is still discovering boundaries.
```

## Example Recommendation

For a medium app, prefer:

```text
Core
  Networking
  DesignSystem
  Persistence

Features
  AuthFeature
  ProductFeature
  CartFeature
```

With internal folders:

```text
ProductFeature
  Domain
  Data
  UI
```

Do not split into:

```text
ProductDomain
ProductData
ProductUI
```

unless `ProductDomain` is genuinely shared or build/ownership pressure justifies it.
