# Traitement des images via reconnaissance de caractères (OCR)

Certains fichiers déposés sont sous format d'images directes ou intégrées dans des PDFs.

Nous avons testé différentes solutions plus ou moins anciennes et éprouvées via des classes de type `QuoteReader::Image`.

Initialement, nous avons intégré Tesseract et Surya (Python), solutions historiques qui se sont avérées compliquées à configurer pour notre usage.

Puis nous avons benchmarké les services VLM de Mistral OCR, Albert OCR et Llama sans succès probant, notamment sur les tableaux.

Enfin, nous avons hébergé des solutions modernes open source alliant machine learning et intelligence artificielle via le projet dédié [mon-devis-sans-oublis-backend-ocr](https://github.com/MTES-MCT/mon-devis-sans-oublis-backend-ocr).

Marker est actuellement la solution que nous avons retenue.

Nous attendons la sortie du projet DocumentIA pour déporter ce besoin.

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
