# Metabase

L'instance Metabase tourne sur une application extérieure dédié avec sa propre base de données.

Déploiement et mise à jour via https://github.com/betagouv/metabase-scalingo?tab=readme-ov-file#updating-metabase-on-scalingo

`scalingo --app mon-devis-sans-oublis-metabase deploy https://github.com/Scalingo/metabase-scalingo/archive/refs/heads/master.tar.gz`

Et si besoin forcer la `METABASE_VERSION` par exemple avec `0.56.13`.

## Vue d'ensemble du processus

Le back-end dispose d'un système d'export automatisé qui permet de copier et anonymiser les données de production vers une base de données dédiée à Metabase pour les analyses et tableaux de bord.

Les données sont exportées dans un schéma dédié `mdso_analytics` pour une organisation claire dans Metabase.

## Architecture du processus

```
DB Source (Production) 
    ↓ (anonymisation)
Schéma temporaire export_anonymized
    ↓ (export CSV)
Fichiers CSV temporaires 
    ↓ (import)
DB Metabase → Schéma mdso_analytics
```

## Scripts d'anonymisation

Le processus d'anonymisation est géré par **6 scripts** situés dans le dossier `db/scripts` :

### Script principal

- **`export-db-metabase.sh`** : Script bash d'orchestration complète

### Scripts SQL

- **`1-anonymize-data.sql`** : Création des tables avec données anonymisées dans un schéma temporaire
- **`2-export-anonymized-data.sql`** : Export des données anonymisées vers fichiers CSV
- **`3-cleanup-metabase.sql`** : Nettoyage et recréation du schéma `mdso_analytics`
- **`4-import-csv-to-metabase.sql`** : Import des CSV vers le schéma `mdso_analytics`
- **`5-cleanup-anonymized-source-data.sql`** : Suppression du schéma temporaire dans la DB source

## Variables d'environnement requises

L'export nécessite ces variables d'environnement sur l'application backend :

| Variable | Description | Source | Requis |
|----------|-------------|---------|---------|
| `DATABASE_URL` | URL de la base de données backend | Automatiquement configurée par Scalingo | ✅ |
| `METABASE_DATA_DB_URL` | URL de la base de données Metabase | À configurer manuellement | ✅ |
| `ENABLE_METABASE_EXPORT` | Active/désactive l'export automatique | `true` ou `false` | ✅ |

### Configuration de l'activation/désactivation

```bash
# Activer l'export (recommandé pour la production)
scalingo --app mon-devis-sans-oublis-backend-prod env-set ENABLE_METABASE_EXPORT="true"

# Désactiver l'export (recommandé pour staging/dev)
scalingo --app mon-devis-sans-oublis-backend-staging env-set ENABLE_METABASE_EXPORT="false"
```

**Comportement** :

- Si `ENABLE_METABASE_EXPORT=true` : L'export s'exécute normalement
- Si `ENABLE_METABASE_EXPORT=false` ou non définie : L'export se termine proprement sans erreur
- Message explicite dans les logs pour indiquer l'état (activé/désactivé)

### Configuration de la variable Metabase

```bash
# 1. Récupérer l'URL de la DB Metabase
scalingo --app mon-devis-metabase env | grep DATABASE_URL

# 2. Configurer cette URL sur l'app backend
scalingo --app mon-devis-sans-oublis-backend-staging env-set \
  METABASE_DATA_DB_URL="postgresql://user:password@host:port/database"

# 3. Vérifier la configuration
scalingo --app mon-devis-sans-oublis-backend-staging env | grep DATABASE
```

## Données exportées et anonymisation

### Tables exportées

1. **`quote_checks`** - Analyses de devis principales
2. **`quotes_cases`** - Dossiers/cas de rénovation  
3. **`quote_check_feedbacks`** - Retours utilisateurs
4. **`quote_error_edits`** - Historique des corrections

### Anonymisation appliquée

Pour respecter la confidentialité, les données sensibles sont automatiquement anonymisées :

| Type de données | Anonymisation |
|-----------------|---------------|
| **Contenu des devis** | Remplacé par "Contenu anonymisé pour export Metabase" |
| **Commentaires utilisateurs** | Remplacés par "Commentaire anonymisé" |
| **Emails utilisateurs** | Remplacés par `email-anonymise@example.com` |
| **Texte OCR/PDF** | Exclu de l'export |

Les **données analytiques** (dates, statuts, codes d'erreur, métriques, profils utilisateurs) sont **conservées** pour permettre les analyses.

## Organisation dans Metabase

Les données sont importées dans le schéma `mdso_analytics` avec la structure :

- `mdso_analytics.quote_checks`
- `mdso_analytics.quotes_cases`
- `mdso_analytics.quote_check_feedbacks`
- `mdso_analytics.quote_error_edits`

## Sécurité et nettoyage

- **Fichiers CSV temporaires** : Automatiquement supprimés après chaque exécution
- **Schéma temporaire** : Nettoyé après export
- **Protection Git** : Fichiers `.csv` exclus via `.gitignore`
- **Gestion d'erreur** : Nettoyage automatique même en cas d'échec

## Automatisation

L'export est automatisé via un CRON (défini dans `cron.json`) qui s'exécute **tous les matins à 9h** pour maintenir les données Metabase à jour avec les dernières données anonymisées.

**Important** : Le CRON ne s'exécute que si `ENABLE_METABASE_EXPORT=true`.

## Exécution manuelle

```bash
# Pré-requis : Vérifier que les variables sont configurées
scalingo --app mon-devis-sans-oublis-backend-staging env | grep -E "(METABASE_DATA_DB_URL|ENABLE_METABASE_EXPORT)"

# Lancement de l'export
scalingo --app mon-devis-sans-oublis-backend-staging run db/scripts/export-db-metabase.sh
```

## Surveillance et logs

```bash
# Voir les tâches programmées
scalingo --app mon-devis-sans-oublis-backend-staging cron-tasks

# Consulter les logs d'exécution
scalingo --app mon-devis-sans-oublis-backend-staging logs --filter cron

# Vérifier les logs d'export dans la DB
psql $DATABASE_URL -c "SELECT * FROM export_logs ORDER BY created_at DESC LIMIT 10;"
```
