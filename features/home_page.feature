# language: fr

# Note : les IDEs et leurs plugins Cucumber sont censés pouvoir gérer
# l'internationalisation et donc les mots-clés en français aussi.

Fonctionnalité: La page d'accueil me salue
  Scénario:
    Quand je me rends sur la page d'accueil
    Alors la page contient "Ministère de la transition écologique"
    Et la page contient "Mon Devis Sans Oublis"
