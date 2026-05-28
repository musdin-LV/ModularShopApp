# Modular Architecture Migration Instructions

When working on this repository, migrate architecture toward the current ModularShopLab target:

- The app target is the composition root.
- `AppDependencies` creates concrete dependencies and injects them.
- `AppCapabilities` describes runtime availability; it does not create features.
- Feature packages own user-facing workflows.
- Core packages own stable shared contracts and technical building blocks.
- Use initializer injection. Do not introduce a DI framework unless explicitly requested.
- Avoid feature-to-feature imports. If several features need the same model or contract, extract it to `Core`.
- Keep `Domain`, `Data`, and `UI` as folders inside a feature package until separate packages are justified.
- Every migration phase must compile independently.

Before editing:

1. Inspect files and imports.
2. Identify features from user journeys.
3. Map current dependencies.
4. Propose a buildable migration phase.
5. Implement only the approved phase.
6. Run focused tests and an app build when integration changes.

Prefer this target shape:

```text
App Target
  AppDependencies
  AppCapabilities
  AppRootView / navigation

Core
  DesignSystem
  Networking
  FeatureFlags
  Shared domain modules
  Observability
  Persistence adapters when shared

Features
  AuthFeature
  ProductFeature
  ProductShowroomFeature
  CartFeature
  FavoritesFeature
  ClientFeature
  PaymentFeature
```

Migration report format:

1. What changed.
2. Why it moves the architecture toward the target.
3. Validation results.
4. Remaining risks or next migration phase.

