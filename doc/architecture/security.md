# Sécurité

Au-delà du code et des bibliothèques, des points de vigilance particuliers sont associés au projet.

## Sécurisation des données

Les devis contenant des informations personnelles ou relevant du secret des affaires, il est essentiel d'en limiter la lecture et la rétention.

Les informations d'usage comme les adresses emails sont chiffrées en base de données en suivant les méthodes proposées par le framework Rails.

## Sécurisation des documents

Les documents ne sont actuellement pas sauvegardés ailleurs qu'en base de données afin d'éviter une prolifération malencontreuse.

Seules les informations nécessaires au processus sont conservées en base.

## Fichiers indésirables

En plus de n'autoriser et ne conserver que certains types de documents, nous avons testé une analyse par antivirus ClamAV en parallèle du traitement. Cependant, l'initialisation de ce service est longue.

L'intégration d'un service type ANSSI en API pour garantir l'absence de virus ou de documents illégaux est à envisager.
