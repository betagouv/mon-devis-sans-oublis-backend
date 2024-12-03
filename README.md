# Mon Devis Sans Oublis

![Capture d’écran 2024-07-09 à 12 02 42](https://github.com/betagouv/rails-template/assets/107635/51592c9e-3f74-4384-9561-354c7085b16b)

## Introduction

Ce repo est le code source pour faire tourner la plateforme [Mon Devis Sans Oublis](https://mon-devis-sans-oublis.beta.gouv.fr/) (MDSO) basé sur certains services et outils choisis :

**Le projet est encore en tout début de phase de construction et donc sujet à évolutions à travers des cyclse courts.**

* [Ruby on Rails](https://rubyonrails.org/) version 7 comme boîte à outil et socle technique applicatif ;
* le [DSFR](https://www.systeme-de-design.gouv.fr/) pour réutiliser les éléments graphiques officiels via la [librairie de
composants DSFR](https://github.com/betagouv/dsfr-view-components)
* PostgreSQL comme base de données pour stocker les données ;
* Mistral.ai comme solution de LLM pour interroger les devis ;
* des annuaires officiels de professionnels pour croiser des données ;
* ~~[Publi.codes](https://publi.codes/) pour un moteur de validation basé sur des règles~~ (plus utilisé pour le moment) ;
* Sentry pour monitorer et être alerté en cas d'erreur ;
* Matomo pour mesurer et comprendre l'usage via des analytics ;
* RSpec comme framework de tests ;
* Cucumber et Capybara pour les tests BDD ;
* Rubocop (RSpec et Rails) pour le linting ;
* Docker pour avoir un environnement de développement.

## Moteur et fonctionnement interne / Architecture

Les fichiers devis sont traités par le `QuoteChecksController` qui les envoient aux services:

- `QuoteReader` lisant le devis brut puis extractant les information du devis de manière naïve en se basant sur le texte du PDF et via solutions LLM avec croisement de données d'annuaires publiques de la rénovation
- puis ces attributs de devis sont vérifier par le `QuoteValdiator` qui controlle un ensemble de règles et renvoit les erreurs correspondantes

### Tester un devis en local

`docker compose exec web rake 'quote_checks:create[tmp/devis_tests/DC004200PAC-Aireau+Chauffe eau thermo.pdf]' | less`

## API

via header `Accept` à la valeur `application/json` pour forcer le retour au format JSON et non classique HTML

- GET `/profils` pour lister les profils disponibles
- POST `/[:profil]/devis/verifier` avec paramètre `quote_file` contenant le fichier
le type de retour avec erreurs retournées est:
```
{
    "valid": false,
    "errors": [
        "file_reading_error",
        "devis_manquant",
        "pro_raison_sociale_manquant",
        "pro_forme_juridique_manquant",
        "tva_manquant",
        "capital_manquant",
        "siret_manquant",
        "client_prenom_manquant",
        "client_nom_manquant"
    ]
}
``` 

## Démarrage

```shell
docker-compose up
```

ou si vous l'installez directement (non recommandé)

```shell
DATABASE_URL='postgresql://postgres:dummy@localhost:5433' bin/rails server -b 0.0.0.0
```

## Environnement

Tout l'environnement est configuré pour et depuis [Docker](https://www.docker.com/). Des
commandes utiles sont fournies dans le [Makefile](./Makefile).

## Mails

[Mail previews](http://localhost:3000/rails/mailers/)

## Intégration continue

Une cinématique [GitHub Action](https://github.com/betagouv/mondevissansoublis/tree/main/.github/workflows) est founie qui lance :

- le linting via Rubocop ;
- les tests unitaires ia RSpec ;
- les tests d'intégration.

Cette cinématique commence d'abord par construire l'image Docker
qu'elle transmet ensuite aux trois étapes ci-dessus, ce qui évite de
répéter trois fois l'installation et la configuration du projet sans
sacrifier le parallèlisme de ces étapes.
