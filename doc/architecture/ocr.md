# Traitement des images via reconnaissance de caractères (OCR)

Certains fichiers déposés sont sous format d'images directes ou intégrées dans des PDFs.

Nous tentons de lire le PDF supposé bien formé au format texte mais si nous ne lisons rien ou trop peu nous tentons un système d'analyse d'image.

Ainsi en amont de l'analyse nous appelons un service de lecture en synchrone pour récupérer le texte complet / lu au format brut.

Nous avons testé différentes solutions plus ou moins anciennes et éprouvées via des classes de type `QuoteReader::Image`.

Initialement, nous avons intégré Tesseract et Surya (Python), solutions historiques qui se sont avérées compliquées à configurer pour notre usage.

Puis nous avons benchmarké les services VLM de Mistral OCR, Albert OCR et Llama sans succès probant, voir notre Notion pour le benchmark. Notez que les solutions en service et modèles open source évoluent très vites.

Nous avons beaucoup de difficultés sur les contenus mixes image / texte (logo, labels, croquis, images des items) et les tableaux (texte éparse, que prendre sur la même ligne ? séparer les colonnes ?).

Nous nous sommes basés sur un retour texte total brut mais les solutions peuvent retourner des structures contextualisées header, tableaux, footer (conditions générales) notament sous format markdown que nous n'avons pas exploité.

Enfin, nous avons hébergé des solutions modernes open source alliant machine learning et intelligence artificielle via le projet dédié [mon-devis-sans-oublis-backend-ocr](https://github.com/MTES-MCT/mon-devis-sans-oublis-backend-ocr). Cela nous permet de maitriser la chaîne, les données, et versions mais nécessite des ressources spécifiques (carte graphique GPU) avec coût d'une centaine d'euros par mois.

[Marker](https://github.com/datalab-to/marker) est actuellement la solution que nous avons retenue et utilisons.

Nous attendons la sortie du projet [DocumentIA](https://beta.gouv.fr/startups/document-ia.html) pour déporter ce besoin vers ce service souverain.

# Configurer un nouveau service OCR

- Vérifier la disponibilité du service via `QuoteReader::Image::MdsoOcr.new("", "").models`
- Ajouter une classe dédiée de type `QuoteReader::Image::MdsoOcrMarker`
- Ajouter le nom de la classe dans `config/custom.rb`

# Pdf to images

Pour transformer les PDF en images de prévisualisation dans le back office, nous utilisons :
  - La librairie Poppler `pdftoppm` (natif)
  - La gem MiniMagick (IM) `mini_magick` avec ImageMagick 6.9 (comme sur Scalingo) (natif)

# Installation de tesseract sous Mac OSX

`brew install tesseract tesseract-lang`

```sh
mkdir -p /opt/homebrew/share/tessdata
cd /opt/homebrew/share/tessdata
curl -O https://github.com/tesseract-ocr/tessdata_best/raw/main/fra.traineddata
# check that you really download the file and it's not empty
```
