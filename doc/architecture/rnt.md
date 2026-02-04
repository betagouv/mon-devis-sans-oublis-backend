# RNT

Dans le soucis de rigueur des contrôles et informations demandés nous sommes associés à la création du (Référentiel Numerique de Travaux)[https://gitlab.com/referentiel-numerique-travaux/referentiel-numerique-travaux] du (CSTB)[https://www.cstb.fr/] pour harmoniser les contrôles. Partis sur notre propre schéma et validations nous avons intégré le service RNT (encore en parallèle le temps des tests pour l'instant, sans implacation pour l'usager). 

## Intégration

Nous intégrons le RNT, via une sous librairie interne dans `lib/rnt` et les classes `Rnt::Schema` et `RntValidatorService`.

Le format XML du RNT nécessite d'être transformé et découpé en schéma JSON pour être utilisé par les LLMs.

1. (en amont manuel pour l'instant, et commité) Téléchargement du dernier schéma XML du RNT
2. (en amont manuel pour l'instant, et commité) Transformation du schéma XML en JSON, et sous-découpage selon types de gestes travaux
3. Pour un nouveau devis, nous extrayons les attributs RNT au format JSON via LLM
4. Nous transformons ces attributs de JSON en XML via LLM aussi (format text en copiant une partie du gros schéma officiel)
5. Nous interrogeons en synchrone le Web Service du RNT pour validation. Il peut nous rendre directement une erreur de format et/ou valeur XML, ou bien si valide au schéma, effectue une passe de validations plus fonctionnelles et contextualisées.
6. Nous rendons les erreurs telles quelles (pour l'instant masquée à l'utilisateur, le temps de la synergie avec notre schéma et nos validations)

Le schéma complet et strict du RNT ne permet pas une analyse rapide et flexibles dans les erreurs (erreur non bloquante) pour l'usager. 

## Pour mettre à jour

1. Suivez les instructions de `lib/rnt`
2. Puis exécutez `bundle exec rake doc:rnt_prompts`
3. Testez
4. Commitez et déployez
