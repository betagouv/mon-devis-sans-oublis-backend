# Mon Devis Sans Oublis (MDSO) - Backend

Plateforme d'analyse de conformité de devis pour accélérer la rénovation énergétique des logements en simplifiant l'instruction des dossiers d'aide.

🔗 **[Accéder à la plateforme](https://mon-devis-sans-oublis.beta.gouv.fr/)**

## Technologies sous-jacentes utilisées

- [Ruby on Rails](https://rubyonrails.org/) version 8 comme boîte à outils et socle technique applicatif
- Le [DSFR](https://www.systeme-de-design.gouv.fr/) pour réutiliser les éléments graphiques officiels via la [librairie de composants DSFR](https://github.com/betagouv/dsfr-view-components)
- PostgreSQL comme base de données pour stocker les données
- Des solutions de LLM pour interroger les devis, via la boîte à outils [LangChain](https://rubydoc.info/gems/langchainrb) :
  - Albert API d'Etalab
  - Mistral.ai : données publiques et/ou anonymisées
  - Ollama : un modèle Llama local
- L'API Data de l'ADEME pour croiser les données d'entreprises qualifiées
- Des annuaires officiels de professionnels pour croiser des données
- ~~[Publi.codes](https://publi.codes/) pour un moteur de validation basé sur des règles~~ (plus utilisé pour le moment)
- Sentry pour monitorer et être alerté en cas d'erreur
- Matomo pour mesurer et comprendre l'usage via des analytics
- RSpec comme framework de tests
- Rubocop (RSpec et Rails) pour le linting
- Docker pour avoir un environnement de développement
- ClamAV pour scanner les fichiers déposés

### Tâches asynchrones

Elles sont listées dans la base de données PostgreSQL via la librairie `good_job`.

Un panneau de suivi est disponible sur [/mdso_good_job/](http://localhost:3000/mdso_good_job/) sous mot de passe hors développement.

## Prérequis

- **Git** pour cloner le repository
- **Docker Desktop** (recommandé, pour l'exécution avec Docker)

Si vous n'utilisez pas Docker :

- **Ruby** 3.x (voir `.ruby-version`)
- **Node.js** >= 18 (voir `package.json`)
- **PostgreSQL** 16 (voir `docker-compose.yml`)

## Installation

Clonez le repository et installez les dépendances :

```bash
git clone https://github.com/MTES-MCT/mon-devis-sans-oublis-backend.git
cd mon-devis-sans-oublis-backend
docker compose up
```

## Configuration de l'environnement

### Variables d'environnement requises

Configurez les variables d'environnement selon votre méthode d'exécution :

#### Pour l'exécution avec Node.js

1. Copiez le fichier `.env.example` en `.env.local` :

```bash
cp .env.example .env.local
```

2. Éditez le fichier `.env.local` avec les valeurs réelles pour votre environnement de développement.

⚠️ **Important** : Ne laissez jamais de variables d'environnement vides (ex: `VARIABLE=`). Si vous n'avez pas besoin d'une variable, commentez-la avec `#` ou supprimez la ligne complètement.

#### Pour l'exécution avec Docker

1. Copiez le fichier `.env.example` en `.env.docker` :

```bash
cp .env.example .env.docker
```

2. Éditez le fichier `.env.docker` avec les valeurs appropriées pour l'environnement Docker.

⚠️ **Important** : Ne laissez jamais de variables d'environnement vides (ex: `VARIABLE=`). Si vous n'avez pas besoin d'une variable, commentez-la avec `#` ou supprimez la ligne complètement.

### Variables d'environnement principales

| Variable                       | Description                           | Exemple                                                  | Requis    |
| ------------------------------ | ------------------------------------- | -------------------------------------------------------- | --------- |
| `ADEME_SKIP_SSL_VERIFICATION`                     | Ne pas vérifier la connexion SSL avec l'API ADEME             | `false`                            | Optionnel    |
| `ADMIN_EMAILS`                     | Emails ProConnect pouvant accéder au Back Office             | `toto@gouv.fr,tata@gouv.fr`                            | Optionnel    |
| `ALBERT_API_KEY`                     |              | `longueClé`                            | Requis    |
| `ALBERT_MODEL`                     | Modèle Albert utilisé par défaut si disponible            | `neuralmagic/Meta-Llama-3.1-70B-Instruct-FP8`                            | Optionnel    |
| `APPLICATION_HOST`                     | Host du backend pour générer des liens et la connexion OAuth            | `http://localhost:3000`, `https://api.mon-devis-sans-oublis.beta.gouv.fr`                            | Requis    |
| `APP_ENV`                     | Environnement applicatif, différent du RAILS_ENV technique           | `development`, `staging`, `production`                            | Requis    |
| `BREVO_API_KEY`                     | Pour envoi de mails             | `longueClé`                            | Optionnel    |
| `BREVO_SMTP_USER_NAME`                     |              | `longueClé`                            | Optionnel    |
| `BREVO_SMTP_USER_PASSWORD`                     |              | `longueClé`                            | Optionnel    |
| `DATABASE_URL`                     | URI de connexion à la base PostgreSQL             | `postgresql://postgres:dummy@localhost:5433/development`, `$SCALINGO_POSTGRESQL_URL`                            | Requis    |
| `DEFAULT_EMAIL_FROM`                     |              | `toto@gouv.fr`                            | Optionnel    |
| `FRONTEND_APPLICATION_HOST`                     | Host du frontend pour autoriser API            | `http://localhost:3001`, `https://mon-devis-sans-oublis.beta.gouv.fr`                            | Optionnel    |
| `GOOD_JOB_PASSWORD`                     | Mot de passe accès au Back Office Jobs            | `secret`                            | Requis    |
| `GOOD_JOB_USERNAME`                     | Utilisateur accès au Back Office Jobs            | `secret`                            | Requis    |
| `INBOUND_FORWARDING_MAIL`                     | Mail vers lequel sont redirigés les emails entrant non traités            | `toto@gouv.fr`                            | Optionnel    |
| `INBOUND_MAIL_DOMAIN`                     | Domaine de(s) email(s) de réception (vérifié sous Brevo et avec DNS MX) pour utiliser `devis@mail.domain.gouv.fr` par exemple            | `mail.domain.gouv.fr`                            | Optionnel    |
| `INBOUND_WEBHOOK_HOST`                     | Domaine pour webhook email différent du courant            | `sub.domain.gouv.fr`                            | Optionnel    |
| `MATOMO_SITE_ID`                     |             | `123`                            | Optionnel    |
| `MATOMO_TOKEN_AUTH`                     |             | `hash`                            | Optionnel    |
| `MDSO_API_KEY_FOR_MDSO`                     | Clé API pour frontend            | `hash` via `rake secret`                           | Optionnel    |
| `MDSO_API_KEY_FOR_PARTNER1`                     | Clé API pour PARTNER1            | `hash` via `rake secret`                           | Optionnel    |
| `MDSO_API_KEY_FOR_PARTNER2`                     | Clé API pour PARTNER2            | `hash` via `rake secret`                           | Optionnel    |
| `MDSO_API_PASSWORD`                     | Ancienne clé API pour frontend            | `hash` via `rake secret`                           | Optionnel    |
| `MDSO_OCR`                     | Système d'OCR à utiliser par défaut            | `MdsoOcrMarker` ou voir `Rails.application.config.ocrs_configured` | Optionnel    |
| `MDSO_OCR_API_KEY`                     | Clé API du système OCR MDSO            |                            | Optionnel    |
| `MDSO_OCR_HOST`                     | Host du système OCR MDSO            |                            | Optionnel    |
| `MDSO_OCR_MODEL`                     | Modèle du système OCR MDSO utilisé par défaut si disponible            |                            | Optionnel    |
| `MDSO_QUOTE_FILE_MAX_SIZE`                     | Taille du fichier maximum en MB, 50 par défaut            |                            | Optionnel    |
| `MDSO_SITE_PASSWORD`                     | Ancienne clé accès au Back Office            | `hash` via `rake secret`                           | Optionnel    |
| `MISTRAL_API_KEY`                     |              | `longueClé`                            | Requis    |
| `MISTRAL_MODEL`                     | Modèle Mistral utilisé par défaut si disponible            | `mistral-large-latest`                            | Optionnel    |
| `OCRABLE_UNDER_CARACTERS_COUNT`                     | Limite de caractères en deça de laquelle on tente l'OCR automatiquement           |                            | Optionnel    |
| `PRIVATE_DATA_QA_DEFAULT_LLM`                     | LLM utilisé pour extraire les données privées par défaut si disponible            | `mistral`                            | Optionnel    |
| `PRIVATE_DATA_QA_DEFAULT_MODEL`                     | Modèle utilisé pour extraire les données privées par défaut si disponible            | `mistral-large-latest`                            | Optionnel    |
| `PROCONNECT_CLIENT_ID`                     |             | `hash`                            | Optionnel    |
| `PROCONNECT_CLIENT_SECRET`                     |             | `hash`                            | Optionnel    |
| `PROCONNECT_DOMAIN`                     |             | `https://auth.agentconnect.gouv.fr/api/v2`, `https://fca.integ01.dev-agentconnect.fr/api/v2`                            | Optionnel    |
| `QUOTE_CHECK_EMAIL_RECIPIENTS`       | Emails pour être informé des dépôts | `toto@gouv.fr,tata@gouv.fr`                              | Optionnel |
| `RAILS_ENV`                     | Environnement global du framework             | `production` ou `development` en local                            | Optionnel    |
| `RAILS_INBOUND_EMAIL_PASSWORD`                     | Secret pour authentifier les appels emails             | via `bin/rails secret`                            | Optionnel    |
| `SENTRY_DSN`       | DSN Sentry pour le tracking d'erreurs | `https://xxx@sentry.io/xxx`                              | Optionnel |
| `SENTRY_ENVIRONMENT`       | Environnement Sentry pour le tracking d'erreurs | `$APP_ENV`                              | Optionnel |
| `SENTRY_LOGS_ENABLED`       | Activer l'envoi de logs vers Sentry | `false`                              | Optionnel |
| `WORKS_DATA_QA_DEFAULT_LLM`                     | LLM utilisé pour extraire les données travaux par défaut si disponible            | `mistral`                            | Optionnel    |
| `WORKS_DATA_QA_DEFAULT_MODEL`                     | Modèle utilisé pour extraire les données travaux par défaut si disponible            | `mistral-large-latest`                            | Optionnel    |

### Configuration des environnements Scalingo

Scalingo est notre hébergeur type PaaS applicatif :

#### Staging

```bash
APPLICATION_HOST=https://api.mon-devis-sans-oublis.beta.gouv.fr
APP_ENV=staging
DATABASE_URL=$SCALINGO_POSTGRESQL_URL
FRONTEND_APPLICATION_HOST=https://staging.mon-devis-sans-oublis.beta.gouv.fr
# SCALINGO_POSTGRESQL_URL=générer par Scalingo
```

#### Production

```bash
APPLICATION_HOST=https://api.staging.mon-devis-sans-oublis.beta.gouv.fr
APP_ENV=production
DATABASE_URL=$SCALINGO_POSTGRESQL_URL
FRONTEND_APPLICATION_HOST=https://mon-devis-sans-oublis.beta.gouv.fr
# SCALINGO_POSTGRESQL_URL=générer par Scalingo
```

## Code

Nous suivons les recommandations et les conventions du framework Ruby on Rails et de la communauté.
Nous choisissons des librairies (gem) adaptées et éprouvées par l'écosystème.

- Dossier `lib` : pour les parties isolées qui pourraient être externalisées, comme la communication avec des services externes
- Dossier `app/services` : pour organiser la logique métier propre et interne à notre projet

## Tests et Intégration continue

Une cinématique [GitHub Action](https://github.com/betagouv/mondevissansoublis/tree/main/.github/workflows) est fournie qui lance :

- Le linting via Rubocop
- Les tests unitaires via RSpec
- Les tests d'intégration

Cette cinématique commence d'abord par construire l'image Docker
qu'elle transmet ensuite aux trois étapes ci-dessus, ce qui évite de
répéter trois fois l'installation et la configuration du projet sans
sacrifier le parallèlisme de ces étapes.

## Architecture et fonctionnement interne

Nous avons fait des [choix stratégiques](./doc/strategy.md) et pris des orientations au fur et à mesure.

Actuellement le cycle principal de vérification d'un ou des documents fonctionne ainsi :

1. Récupération du ou des documents, avec informations contextuelles renseignées dans un objet `QuoteCheck` ou `QuotesCase` (si ampleur / plusieurs documents) :
    - Via notre interface web en Next.js, projet [mon-devis-sans-oublis-frontend](https://github.com/betagouv/mon-devis-sans-oublis-frontend)
    - Ou via notre [API](./doc/architecture/api.md) pour les partenaires configurés comme notre interface
    - Ou via courriel sur notre adresse dédiée, voir [mailing](./doc/architecture/mailing.md)
2. Ensuite vient la [lecture](./doc/architecture/reading.md) de chaque document en brut
  via [lecture d'images (OCR)](./doc/architecture/ocr.md) si celui-ci est une image
3. [Anonymisation des données](./doc/architecture/anonymization.md) à caractères privés et commerciaux avant de traiter le contenu
4. [Extraction structurée du contenu du document](./doc/architecture/reading.md) avec les données qui nous sont pertinentes
5. [Validation](./doc/architecture/validation.md) des valeurs extraites en appliquant les règles :
    - Vérification [RGE et API Ademe](./doc/architecture/rge.md)
    - En parallèle (pas encore intégré au retour) validation sur le web service [RNT](./doc/architecture/rnt.md)

D'autres briques techniques sont utilisées de manière connexe :

- [Back Office](./doc/architecture/backoffice.md) pour notre suivi interne
- Mises en œuvre de [sécurité](./doc/architecture/security.md) particulières
- Suivi analytique de l'usage via [Metabase](./doc/architecture/metabase.md)

## Usage

### Tester un fichier devis en local

`docker compose exec web rake 'quote_checks:create[tmp/devis_tests/DC004200PAC-Aireau+Chauffe eau thermo.pdf]' | less`

#### Re-vérifier un devis en base

```
quote_check_id = "b9705194-02aa-4db7-bc38-5fc2dcb6ce58"
QuoteCheckCheckJob.perform_later(quote_check_id)
```
