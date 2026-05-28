---
name: modular-architecture-migrator
description: Migrate an existing iOS Swift or SwiftUI project from any architecture toward a modular App/Core/Features architecture with clear layers, initializer dependency injection, feature dependencies objects, and buildable migration phases. Use when the user wants an agent to identify features, propose a migration plan, refactor packages, reduce feature-to-feature coupling, introduce a composition root, or implement the architecture incrementally.
---

# Modular Architecture Migrator

Use this skill to move an existing Swift or SwiftUI codebase toward a pragmatic modular architecture:

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
  CartFeature
  ClientFeature
  ...
```

The goal is not to force Clean Architecture everywhere. The goal is to expose feature boundaries, remove accidental coupling, keep the app target as the composition root, and migrate in phases that compile.

## When To Use

Use this skill when the user asks to:

- modularize an iOS app;
- identify features in an existing project;
- move from MVC, MVVM, VIPER, Clean Architecture, Redux/TCA, or mixed architecture to local Swift packages;
- introduce `AppDependencies`, `AppCapabilities`, feature dependencies, or initializer dependency injection;
- remove feature-to-feature imports;
- extract shared models into `Core`;
- implement the migration, not only describe it.

For an audit-only request, use `feature-modularization-auditor` if available. For a migration request, use this skill.

## Core Rules

- Read the repository before proposing changes.
- Infer features from user journeys, not only folders.
- Keep the first migration small enough to compile.
- Preserve behavior unless the user explicitly asks for redesign.
- Prefer initializer injection over a DI framework.
- Do not introduce a DI container unless the project already has one and it is clearly justified.
- The app target creates concrete implementations.
- Features declare needs and consume dependencies.
- Shared domain contracts used by several features move to `Core`.
- Do not make feature A import feature B only to reuse one model.
- Keep `Domain`, `Data`, and `UI` as folders inside a feature package until separate packages are truly justified.

## Workflow

### 1. Inspect

Collect evidence before making claims:

```sh
rg --files
find . -name Package.swift -o -name "*.xcodeproj" -o -name "*.xcworkspace"
rg -n "struct .*View|class .*ViewModel|@Observable|ObservableObject|protocol .*Repository|actor |URLSession|NavigationStack|TabView|NavigationSplitView"
rg -n "import .*Feature|import .*Core|AppDependencies|Dependencies|Container|Resolver|Factory|EnvironmentKey"
```

Identify:

- app targets and navigation roots;
- existing modules and package graph;
- screens and user journeys;
- repositories, stores, services, clients, SDK wrappers;
- shared models;
- concrete dependency creation;
- tests and previews.

### 2. Classify

Classify candidates:

```text
Candidate | Type | Evidence | Current Location | Target Module | Confidence | Notes
```

Types:

- `App`: composition, runtime config, navigation shell.
- `Feature`: user-facing workflow.
- `Core`: stable shared contract or technical building block.
- `Integration`: external SDK/API/persistence adapter.
- `Ambiguous`: needs discussion before moving.

### 3. Map Coupling

Output a dependency map:

```text
App
 -> ProductFeature
 -> CartFeature
 -> Core/Networking

CartFeature
 -> ProductFeature  // smell if only Product is needed
```

Flag:

- feature-to-feature imports;
- UI creating concrete infrastructure;
- shared mutable state without an isolation domain;
- global singletons;
- domain models trapped inside one feature but used by others;
- protocols that are either missing or too broad.

### 4. Propose Target Architecture

Recommend the smallest useful target:

- `AppDependencies` as composition root.
- `AppCapabilities` for runtime feature availability.
- `Core/*` modules for shared technical or domain contracts.
- `Features/*Feature` packages for vertical user capabilities.
- `FeatureDependencies` objects only when a feature has several dependencies or factories.

Read `references/target-architecture.md` when you need concrete examples.

### 5. Plan Buildable Phases

Each phase must include:

- intent;
- files/packages to add or move;
- dependency graph change;
- expected behavior change, ideally none;
- validation command.

Prefer this order:

1. Extract stable Core modules.
2. Move shared models/contracts out of features.
3. Introduce or clean up `AppDependencies`.
4. Introduce feature dependencies objects where useful.
5. Extract one feature package at a time.
6. Move tests next to each package.
7. Remove compatibility shims when all imports are migrated.

### 6. Implement

When the user wants implementation, migrate one phase at a time:

- edit package manifests;
- move or add files;
- update imports;
- keep public APIs small;
- preserve compatibility with typealiases or forwarding initializers when that lowers risk;
- run focused tests after each phase;
- run the app build after integration changes.

Use this validation ladder:

```sh
swift test
xcodebuild -scheme <AppScheme> -destination generic/platform=iOS CODE_SIGNING_ALLOWED=NO build
```

Adapt commands to the project.

### 7. Report

Report in this order:

1. What changed.
2. Why it moves the architecture toward the target.
3. Validation results.
4. Remaining risks or next migration phase.

## Copilot Usage

Copilot does not automatically load Codex skills. To use this workflow with Copilot, copy the relevant sections into:

- repository instructions such as `.github/copilot-instructions.md`;
- a reusable prompt file;
- a Copilot Chat prompt.

Read `references/copilot-integration.md` when generating Copilot-ready instructions.

