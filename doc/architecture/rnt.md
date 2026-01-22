# RNT

Nous intégrons le RNT, via une sous librairie interne dans `lib/rnt` et les classes `Rnt::Schema` et `RntValidatorService`.

Le format XML du RNT nécessite d'être transformé et découpé en schéma JSON pour être utilisé par les LLMs.

## Pour mettre à jour

1. Suivez les instructions de `lib/rnt`
2. Puis exécutez `bundle exec rake doc:rnt_prompts`
3. Testez
4. Commitez et déployez
