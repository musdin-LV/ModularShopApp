# ModularShopLab

ModularShopLab est un laboratoire d'architecture SwiftUI pour explorer une app retail modulaire.

Le projet cherche a montrer comment decouper une application en features autonomes, comment partager des briques communes sans creer de dependances circulaires, et comment composer l'application finale depuis un point unique.

## Philosophie

L'architecture suit une idee simple :

> L'app compose, les features declarent leurs besoins, le Core partage les contrats stables, et les integrations externes restent des details d'implementation.

Concretement, une feature ne doit pas savoir si elle utilise une implementation remote, mock, locale ou Firebase. Elle expose des entrees publiques, declare les protocoles ou dependances dont elle a besoin, puis l'app target choisit les implementations concretes.

Cette approche permet de garder :

- des features testables independamment ;
- un graphe de dependances lisible ;
- des frontieres explicites entre UI, domaine, data et infrastructure ;
- des experiences differentes selon la plateforme, par exemple `ProductFeature` sur iPhone et `ProductShowroomFeature` sur iPad.

## Separation Des Couches

Le projet est organise autour de trois grandes zones.

### App Target

`ModularShopLab` est le point de composition de l'application.

Il contient notamment :

- `AppDependencies`, qui cree les instances concretes ;
- `AppCapabilities`, qui decrit les fonctionnalites disponibles selon la plateforme et les feature flags ;
- `AppRootView`, `MainTabs` et `IPadMainView`, qui assemblent l'experience utilisateur.

L'app target peut importer les features, car c'est elle qui les assemble. En revanche, les features ne doivent pas importer l'app.

### Features

Chaque package dans `Features/` represente une capacite utilisateur :

- `ProductFeature` pour le parcours produit iPhone ;
- `ProductShowroomFeature` pour l'experience showroom iPad ;
- `CartFeature`, `FavoritesFeature`, `ClientFeature`, `PaymentFeature`, etc.

Une feature peut contenir plusieurs couches internes :

- `UI` : vues SwiftUI, view models, coordinators ;
- `Domain` : modeles, protocoles, use cases, regles metier ;
- `Data` : implementations concretes, DTOs, mapping, persistence locale.

Les features doivent rester le plus autonomes possible. Quand plusieurs features ont besoin du meme modele ou contrat, on extrait ce partage dans `Core` plutot que de faire importer une feature par une autre.

Exemple : `Product`, `ProductRepository` et `SearchProductsUseCase` vivent dans `Core/ProductCatalog`, car ils sont utilises par plusieurs experiences produit.

### Core

`Core/` contient les briques partagees et stables :

- `DesignSystem` pour les composants et tokens UI communs ;
- `Networking` pour `APIClient` et les requetes HTTP ;
- `FeatureFlags` pour les flags et `AppCapabilities` ;
- `ProductCatalog` pour le domaine produit partage ;
- `StoreContext` pour le contexte magasin/employe ;
- `Observability` pour les logs et integrations analytics/crash.

Le Core ne doit pas connaitre les features. Il fournit des contrats ou des outils reutilisables.

## Injection De Dependance

L'injection de dependance est volontairement simple : elle se fait principalement par initialiseur.

`AppDependencies` joue le role de composition root :

```swift
@MainActor
@Observable
final class AppDependencies {
    private let apiClient: any APIClient
    private let productRepository: any ProductRepository
    private let favoriteStore: any FavoriteStore

    init(configuration: AppConfiguration = .current()) {
        let apiClient = URLSessionAPIClient()
        self.apiClient = apiClient

        switch configuration {
        case .remote:
            self.productRepository = RemoteProductRepository(apiClient: apiClient)
        case .mock:
            self.productRepository = MockProductRepository()
        }

        self.favoriteStore = InMemoryFavoriteStore()
    }

    func makeProductListViewModel() -> ProductListViewModel {
        ProductListViewModel(repository: productRepository)
    }
}
```

Les features ne creent pas leurs dependances concretes. Elles recoivent uniquement ce dont elles ont besoin.

Pour les features plus riches, le projet utilise des objets de dependances dedies, comme `ClientFeatureDependencies` :

```swift
public struct ClientFeatureDependencies: Sendable {
    private let repository: any ClientRepository
    private let recentClientStore: any RecentClientStore

    @MainActor
    public func makeSearchViewModel() -> ClientSearchViewModel {
        ClientSearchViewModel(
            repository: repository,
            recentClientStore: recentClientStore
        )
    }
}
```

Cela permet a l'app de composer la feature depuis l'exterieur, tout en gardant les details de construction internes a la feature.

## Regles A Retenir

- Une feature declare ses besoins, l'app choisit les implementations.
- Une feature ne doit pas importer une autre feature uniquement pour reutiliser un modele.
- Les modeles et contrats partages vont dans `Core`.
- Les view models qui possedent de l'etat UI sont `@MainActor`.
- Les implementations techniques restent dans `Data` ou dans les modules `Core`.
- Les integrations externes sont cachees derriere des protocoles ou services injectes.

## Documentation

Pour aller plus loin :

- [Current Architecture Overview](docs/architecture/current-architecture-overview.md)
- [Feature Modularization Audit](docs/architecture/feature-modularization-audit.md)
- [iPad / iPhone Retail Specifics](docs/architecture/ipad-iphone-retail-specifics.md)
- [SwiftData Client Cache](docs/architecture/swiftdata-client-cache.md)

## Skill De Migration

Le repo contient aussi un skill pour aider un agent IA a migrer un projet Swift ou SwiftUI depuis une architecture existante vers cette architecture cible.

- [Modular Architecture Migrator](skills/modular-architecture-migrator/SKILL.md)
- [Copilot instructions](.github/copilot-instructions.md)

Ce skill guide l'agent pour identifier les features, cartographier les dependances, proposer un plan par phases, puis implementer la migration progressivement avec validation a chaque etape.

### Installation Dans Codex

Le skill est versionne dans le repo, mais pour qu'il soit disponible globalement dans Codex, il faut le copier dans le dossier des skills Codex :

```sh
mkdir -p ~/.codex/skills
cp -R skills/modular-architecture-migrator ~/.codex/skills/
```

Une fois installe, il peut etre appele naturellement dans une conversation, par exemple :

```text
Utilise le skill modular-architecture-migrator pour analyser ce projet et proposer une migration vers l'architecture App/Core/Features.
```

Le skill chargera d'abord son workflow principal, puis ses references seulement si elles sont utiles :

- `references/target-architecture.md` pour les regles de l'architecture cible ;
- `references/copilot-integration.md` pour generer ou adapter des instructions Copilot.

### Utilisation Avec Copilot

Copilot ne charge pas automatiquement les skills Codex. Pour l'utiliser avec Copilot, le repo fournit deja :

```text
.github/copilot-instructions.md
```

GitHub Copilot peut utiliser ce fichier comme instructions de repository. Pour un autre projet, il suffit de copier ce fichier dans le repo cible, puis d'adapter les noms de modules si besoin.

Pour une utilisation ponctuelle dans Copilot Chat, copier le prompt depuis :

```text
skills/modular-architecture-migrator/references/copilot-integration.md
```
