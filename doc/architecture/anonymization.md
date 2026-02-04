## Contexte et besoin d'anonymisation

L'utilisation de solutions IA en ligne (Mistral, etc.) pour l'analyse des devis nécessite une anonymisation rigoureuse des données privées et commerciales contenues dans ces documents.

Les champs extraits sont listés dans notre schéma [swagger/v1/quote_check_private_data_qa_attributes.json](https://github.com/MTES-MCT/mon-devis-sans-oublis-backend/blob/main/swagger/v1/quote_check_private_data_qa_attributes.json) tels que ceux pour le `client` (nom, adresse, mail, tel) et le `pro` (siret, assurance, adresse, mail, nom, rge ...).

Notre première approche repose sur des expressions régulières (regex) pour leur simplicité de mise en œuvre. Cependant, cette solution présente des limites importantes :
- **Maintenance complexe** : les regex deviennent difficiles à maintenir à mesure que les cas d'usage se multiplient
- **Non exhaustivité** : notamment pour la détection des noms propres qui peuvent prendre des formes très variées
- **Fragilité** : sensibilité aux variations de format et aux cas particuliers

Des alternatives existent et mériteraient d'être évaluées :
- **Outils dédiés** : solutions spécialisées dans l'anonymisation de documents (Presidio, ARX Data Anonymizer, etc.)
- **Modèles LLM** : des modèles de reconnaissance d'entités nommées (NER) ou d'anonymisation, bien que leur intégration dans notre stack reste à définir

#### Débugguer anonymisation devis

```
quote_check_id = "47db654b-a9fb-453b-b36f-b0c362279233"
quote_check = QuoteCheck.find(quote_check_id)

file_text = quote_check.file_text || quote_check.text

quote_reader = QuoteReader::Global.new(
  quote_check.file.content,
  quote_check.file.content_type,
  quote_file: quote_check.file
)

private_attributes = quote_check.private_data_qa_attributes || {}
private_extended_attributes = TrackingHash.deep_merge_if_absent(
  private_attributes,
  QuoteDataExtender.new(private_attributes).extended_attributes
)

# From quote_reader.read(file_text:)
anonymized_text = QuoteReader::Anonymizer.new(file_text).anonymized_text(private_extended_attributes)
```
