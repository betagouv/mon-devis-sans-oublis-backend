# Stratégie produit et technique

Nous sommes partis sur le besoin initial de lecture et d'analyse de devis selon des règles établies pour afficher un résultat de pré-validation.

## Utilisation des services d'intelligence artificielle

Dans le cadre de ce projet débuté en 2025 et de la philosophie beta.gouv, nous avons fait le choix d'utiliser les nouveaux services d'intelligence artificielle pour développer au plus vite. Ce choix avant-gardiste dans un écosystème encore en évolution nous a confronté à plusieurs questionnements et choix détaillés ci-dessous.

## Décomposition du problème

Nous avons fait le choix de décomposer le processus de bout en bout en différentes briques successives indépendantes à savoir :

1. la lecture du document,
2. son anonymisation,
3. l'extraction d'un maximum de données utiles,
4. la validation de ces données.

Sachant que des solutions de type VLM et RAG basées sur de nouveaux modèles sont disponibles et permettent de tout regrouper en une seule brique-étape.
Cependant lors de nos tests, cela n'a pas été concluant et nous avons donc mis de côté ces options.

## Approche totale VS spécialisée

Nous avons opté pour une extraction et validation quasi-totale, en séparant simplement les informations administratives de celles relatives aux gestes travaux.
Compte tenu des limitations contextuelles et de précision des modèles LLM, nous avons commencé à explorer la spécialisation de chaque étape y compris dans les gestes en eux-mêmes.

Les devis séparant clairement les structures administratives VS travaux, et même ligne par ligne pour différents types de travaux, nous pourrions découper l'analyse de bout en bout pour chaque partie en parallèle.

## Manque de fidélisation des usagers

Le choix d'un formulaire d'upload puis d'une page résultat à partager après attente de l'analyse peut freiner les usagers et ne les incite pas à revenir car l'analyse se fait document par document, sans suivi supplémentaire.

Nous avons envisagé un espace membre selon le profil d'usager dont nous avons différencié le parcours et le résultat.

## Architecture synchrone vs asynchrone

Notre choix de découper par étapes techniques nous freine pour aller vers un mode plus asynchrone et en stream (flux tendu) comme sur les chats LLM grand public.
Nous pouvons intégrer les modes stream des fournisseurs et passer la partie correspondante de la validation mais il faut adapter l'interface frontend avec des WebSockets.

Nous sommes partis sur une architecture backend avec queue de job workers asynchrones et API classique pour frontend, provoquant certains goulots suivant la charge en plus de coûts d'infrastructure fixes à (re)dimensionner.

Une alternative serait d'implémenter une architecture s'adaptant purement à l'usage via de multiples fonctions enchaînées (Function as a Service) comme Lambda.

Nous avons proposé une analyse par envoi d'email direct et retour des résultats par email mais sans grand usage pour le moment.

## Boucle de retour utilisateur

Compte tenu de la fiabilité non totale dans les résultats de la solution (lecture ou validation) nous avons laissé la possibilité d'éditer les résultats avant partage selon le profil initial. Ces corrections manuelles sont enregistrées en base de données mais ne sont pas réutilisées pour un ré-entraînement, pas possible avec notre choix de service IA sur étagère et modèles généraux.

## Gestion agentique

Le fait d'avoir basé notre solution sur plusieurs étapes mettant en œuvre des LLM non déterministes et en ligne a provoqué plusieurs écueils :
- des indisponibilités suivant les fournisseurs
- des évolutions incontrôlées des modèles
- des délais de réponses trop longs
- le besoin d'anonymiser des données

Depuis notre développement, des frameworks et outils pour mieux encadrer les usages agentiques et les workflows IA sont apparus et sont à envisager.
Techniquement pour Ruby, la boîte à outils RubyLLM permet de nouvelles briques d'assurance et d'organisation.

## Choix écosystème Ruby

Nous avons choisi Ruby par habitude, avec un besoin de type SaaS / backend API classique.
Cependant les technologies IA s'orientent majoritairement vers Python qui possède plus d'adapteurs et de documentation sur l'écosystème IA.

## Configuration et adaptation IA

Le choix des modèles et des prompts nous challenge constamment, même si des études sont sorties et les bonnes pratiques se partagent.
Nous avons mis en place un système d'évaluation de la fiabilité de notre processus via un petit jeu de données.
Mais les documents et devis sont très hétérogènes, les modèles et prompts réagissent donc différemment selon la structure (tableaux ou non, multi-lignes) et contenu, rendant la configuration compliquée.

Nous avons testé l'option offerte par les services LLM de retour selon un Schéma (JSON) structuré mais cela peut perturber le retour si mal décrit ou sans exemple.

## Définition d'un Référentiel

Nous avons établi un référentiel et des règles nous-même en Ruby, en attendant le Référentiel Numérique des travaux (RNT).
Nous y avons associé des erreurs et messages spécifiques documentés.

Les tests faits dans les LLM avec le schéma plus complet XML du RNT ne sont pas encore concluants, car besoin de transcription en JSON pour les LLM, mais aussi trop large pour certains services. Nous l'avons intégré mais en parallèle sans en retourner les résultats à l'heure actuelle.

## Coût

Avec l'utilisation de services en ligne nous avions peur de ne pas contrôler les coûts.
Cependant les coûts de ces services à l'usage sont largement inférieurs à une solution que nous aurions à entraîner et faire tourner sur nos propres serveurs.

Nous avons l'exemple avec les services OCRs qui nécessitent des serveurs avec configuration de carte graphique.

## Suivi de l'usage

Nous utilisons Matomo et un back office interne ainsi qu'un Metabase pour suivre l'usage de notre plateforme.
