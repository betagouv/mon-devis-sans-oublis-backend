## API

- Au format REST JSON
- Protégée via authentification HTTP Basic avec Bearer hashé
- Voir le fichier de documentation de l'API au format OpenAPI Swagger et l'interface bac à sable interactive sur `/api-docs`
- Régénération et mise à jour de la documentation à partir des spécifications tests via `make doc`

### API Documentation

Nous utilisons Rswag en Ruby pour générer la documentation de notre API MDSO au format OpenAPI.

Elle est disponible dans le dossier `swagger`, avec une version interne à MDSO et une pour les partenaires avec accès API Key.

La documentation se met à jour via la commande `make doc` qui fait appel au schéma des types situé dans `spec/swagger_helper.rb` et aux tests `spec/requests/*+doc_spec.rb`.

### API Accès

- Ajouter ou modifier la variable d'environnement de type `MDSO_API_KEY_FOR_[PARTNER]` (exemple : `MDSO_API_KEY_FOR_AMI`)
  via le dashboard Scalingo, onglet Environnement, dans le contexte souhaité (`staging` / `production`),
  avec une valeur générée via `rails secret` par exemple
- Redémarrer l'application via le dashboard Scalingo, onglet Ressources
- Vérifier sur le back office MDSO, onglet "API Keys", la présence de l'accès
- Tester si besoin via le playground de la documentation API du contexte correspondant
