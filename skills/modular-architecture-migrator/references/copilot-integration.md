# Copilot Integration Reference

Copilot does not automatically discover Codex skills. To reuse this workflow in Copilot, create a repository instruction file or reusable prompt.

## Repository Instructions

Suggested path:

```text
.github/copilot-instructions.md
```

Suggested content:

```markdown
# Modular Architecture Migration Instructions

When working on this repository, migrate architecture toward this target:

- App target is the composition root.
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
```

## Copilot Chat Prompt

```markdown
Analyze this Swift/SwiftUI project and migrate it toward a modular App/Core/Features architecture.

First, inspect the repository. Identify:

- app target and composition root;
- user-facing features;
- core/shared modules;
- feature-to-feature imports;
- concrete dependency creation;
- models or protocols that should move to Core;
- tests and validation commands.

Then produce:

1. Current architecture summary.
2. Feature inventory table.
3. Dependency graph.
4. Target architecture proposal.
5. Buildable migration phases.
6. Phase 1 implementation plan.

Do not apply generic Clean Architecture blindly. Prefer the smallest change that improves dependency clarity and still compiles.
```

## Implementation Prompt

Use after the plan is accepted:

```markdown
Implement the next approved migration phase.

Rules:

- keep behavior unchanged;
- use initializer dependency injection;
- keep the app target as composition root;
- avoid feature-to-feature imports;
- use compatibility shims when they reduce risk;
- run focused tests;
- run the app build if package graph or app integration changed;
- report changed files, validation results, and remaining risks.
```

