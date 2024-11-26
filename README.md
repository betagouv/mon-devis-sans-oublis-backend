# Mon Devis Sans Oublis

![Capture d’écran 2024-07-09 à 12 02 42](https://github.com/betagouv/rails-template/assets/107635/51592c9e-3f74-4384-9561-354c7085b16b)

## Introduction

Ce repo est le code source pour faire tourner la plateforme [Mon Devis Sans Oublis](https://mon-devis-sans-oublis.beta.gouv.fr/) (MDSO) basé sur certains services et outils choisis :

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

La base de données est configurée avec PostgreSQL.

## Démarrage

```shell
docker-compose up
```

## Environnement

Tout l'environnement est configuré pour et depuis [Docker](https://www.docker.com/). Des
commandes utiles sont fournies dans le [Makefile](./Makefile).

## Intégration continue

Une cinématique [GitHub Action](https://github.com/betagouv/mondevissansoublis/tree/main/.github/workflows) est founie qui lance :

- le linting via Rubocop ;
- les tests unitaires ia RSpec ;
- les tests d'intégration.

Cette cinématique commence d'abord par construire l'image Docker
qu'elle transmet ensuite aux trois étapes ci-dessus, ce qui évite de
répéter trois fois l'installation et la configuration du projet sans
sacrifier le parallèlisme de ces étapes.
