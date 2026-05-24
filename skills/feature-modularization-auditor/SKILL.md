---
name: feature-modularization-auditor
description: Analyze an existing iOS Swift or SwiftUI codebase to identify product features, core/shared modules, dependency boundaries, and propose a pragmatic modular architecture using local Swift Packages. Use when the user wants to modularize an iOS app, identify features, reduce coupling, create a Core/Features architecture, or decide between package-per-feature and Domain/Data/UI package splits.
---

# Feature Modularization Auditor

Use this skill to inspect an existing iOS project and propose a modular architecture based on the actual codebase.

Do not start with a generic architecture. Read the repository first, infer the current design, then recommend the smallest useful modularization.

## Workflow

### 1. Inspect The Project

Find:

- Xcode projects, workspaces, Swift Packages, app targets, extensions, widgets, clips, and test targets.
- Existing folders such as `Features`, `Core`, `Shared`, `Services`, `Networking`, `DesignSystem`, `Domain`, `Data`, `UI`.
- Navigation entry points.
- Dependency creation and composition root.
- Existing dependency injection patterns.
- Existing tests and previews.

Useful commands:

```sh
rg --files
find . -name Package.swift -o -name "*.xcodeproj" -o -name "*.xcworkspace"
rg -n "protocol .*Repository|class .*ViewModel|struct .*View|actor |@MainActor|URLSession|Observable|@Observable|ObservableObject"
```

### 2. Identify Features

Infer features from user journeys, not only folders.

For each candidate feature, collect evidence:

- Screens/views/controllers.
- ViewModels/presenters.
- Domain models.
- Repositories/services.
- API endpoints or persistence tables.
- Tests.
- Navigation routes.

Classify candidates as:

- `Feature`: user-facing workflow or capability.
- `Core`: reusable technical capability.
- `Design/UI Shared`: reusable UI components, design tokens, styling.
- `Integration`: networking, storage, analytics, SDK wrapper.
- `Ambiguous`: needs discussion before moving.

Output:

```text
Candidate | Type | Evidence | Current Location | Proposed Module | Confidence | Notes
```

### 3. Map Dependencies

Build a dependency map.

Flag:

- Feature-to-feature dependencies.
- Feature-to-core dependencies.
- Shared mutable state.
- Concrete infrastructure used directly by UI.
- Cycles or likely cycles.
- Places where a protocol boundary would improve testability.

Use this format:

```text
App
 -> AuthFeature
 -> ProductFeature
 -> CartFeature

ProductFeature
 -> Core/Networking
 -> Core/DesignSystem
```

### 4. Recommend Architecture

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

Inside each feature package, use folders:

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

#### Option B: Domain/Data/UI Packages

Use only for large or heavily shared domains.

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

Recommend this only when:

- The domain is reused by several features or apps.
- Build times are painful.
- Teams own separate UI/data/domain parts.
- Multiple data implementations exist.
- Feature-to-feature imports are causing coupling.

Do not recommend this for every feature by default.

### 5. Composition Root

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

Prefer initializer injection. Do not introduce a DI framework unless the project already uses one and it is clearly justified.

### 6. Swift Concurrency Checks

Check:

- ViewModels owning UI state are `@MainActor`.
- Networking is not main-actor isolated.
- Shared mutable state is isolated by `actor`, `@MainActor`, or another clear isolation domain.
- Value models crossing concurrency boundaries are immutable and `Sendable`.
- No unnecessary `Task.detached`.
- Async code uses structured concurrency.

Flag:

- Mutable global state.
- Non-Sendable objects crossing async boundaries.
- UI state mutated off MainActor.
- Locks or semaphores in async code.

### 7. Migration Plan

Return a phased plan. Each phase must be buildable and testable independently.

For each phase include:

- Files/modules to move.
- New package targets.
- Dependency changes.
- Risks.
- Validation command.

Example:

```text
Phase 1: Extract Core/Networking
Phase 2: Extract DesignSystem
Phase 3: Extract first feature package
Phase 4: Move feature tests into package
Phase 5: Remove direct infrastructure creation from feature UI
```

## Output Format

Produce:

1. Current architecture summary.
2. Feature inventory table.
3. Dependency graph.
4. Recommended target architecture.
5. Why this option is the right size for this codebase.
6. Migration plan.
7. Open questions.

Do not modify files until the user approves the architecture plan.

## Decision Heuristics

Create a separate package when:

- It has a clear owner and responsibility.
- It is reused by multiple modules.
- It changes at a different rate from consumers.
- It improves build caching or parallel compilation.
- It can be tested independently.

Keep folders inside one package when:

- The feature is small.
- The split is only conceptual.
- No other module needs the internals.
- More packages would reduce readability.
- The team is still discovering boundaries.
