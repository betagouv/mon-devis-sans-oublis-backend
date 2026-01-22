# Lecture des PDF

`QuoteReader` lit le devis brut puis extrait les informations du devis de manière naïve en se basant sur le texte du PDF et via des solutions LLM avec croisement de données d'annuaires publics de la rénovation.

La lecture des PDF originaux et la récupération du texte sont faciles via une librairie Ruby, mais uniquement le texte brut.

Pour les images, nous utilisons des solutions [OCR](./ocr.md).

# Extraction des données

L'extraction des données pertinentes via RegExp s'est avérée trop limitée.

Nous utilisons désormais des modèles textuels (Mistral, Llama) mais avec un besoin de limiter les données privées.
Les modèles VLM (Vision-Language Model) pour la lecture d'images/PDF et l'extraction ne sont pas encore au point.
