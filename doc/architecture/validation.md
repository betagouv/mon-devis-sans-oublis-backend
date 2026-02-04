# Validation

La validation des devis s'effectue via les classes `QuoteValidator` qui contrôlent un ensemble de règles et renvoient les erreurs correspondantes par domaine.

**Validation par document :**
- Informations administratives : présence, validité et cohérence (SIRET / RGE si indiqué)
- Caractéristiques techniques des gestes : présence, validité et cohérence
  - Le SIRET est utilisé pour rechercher un certificat RGE correspondant au type de geste

**Validation par dossier :**
- Cohérence des informations entre les documents lorsqu'elles sont présentes

**Note technique :** Le moteur Publi.code (issu du projet MesAidesReno) a été testé mais s'est révélé inadapté. Conçu pour les calculs numériques et les montants, il ne répond pas à nos besoins de validation de présence de champs et de vérification de plages de valeurs.

## Forcer un devis à valide

```
quote_check_id = "76c35e1c-4d8d-479d-a62a-4f36511a5041"
QuoteCheck.find(quote_check_id).update!(validation_errors: nil, validation_error_edits: nil)
```
